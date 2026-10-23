import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:maketpeyizan/core/api/api_client.dart';
import 'package:maketpeyizan/core/constants/app_constants.dart';
import 'package:maketpeyizan/core/offline/connectivity_service.dart';
import 'package:maketpeyizan/core/storage/local_storage.dart';
import 'package:maketpeyizan/core/storage/pos_local_storage.dart';
import 'package:maketpeyizan/core/storage/secure_storage.dart';
import 'package:maketpeyizan/core/theme/app_theme.dart';
import 'package:maketpeyizan/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'donnees.dart';

/// Faux client API : renvoie des réponses réalistes (format backend
/// Makèt Peyizan) selon le chemin, sans réseau.
class FakeApi implements ApiClient {
  final Map<String, dynamic> Function(String path) repondre;
  FakeApi(this.repondre);

  Response _r(String path) => Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: repondre(Uri.parse(path).path),
      );

  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async => _r(path);
  @override
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async => _r(path);
  @override
  Future<Response> patch(String path, {dynamic data, Options? options}) async => _r(path);
  @override
  Future<Response> delete(String path, {Options? options}) async => _r(path);
  @override
  Future<Response> postMultipart(String path, FormData formData) async => _r(path);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> chargerPolices() async {
  Future<void> charger(String famille, List<String> fichiers) async {
    final loader = FontLoader(famille);
    for (final f in fichiers) {
      loader.addFont(File(f).readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
    await loader.load();
  }

  await charger('DMSans', [
    'assets/fonts/DMSans-Regular.ttf',
    'assets/fonts/DMSans-Medium.ttf',
    'assets/fonts/DMSans-Bold.ttf',
  ]);
  await charger('PlayfairDisplay', [
    'assets/fonts/PlayfairDisplay-Bold.ttf',
    'assets/fonts/PlayfairDisplay-Black.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  await charger('MaterialIcons',
      ['$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf']);
  await initializeDateFormatting('fr_FR');
}

/// Taille d'écran logique (téléphone courant par défaut).
const telephone = Size(390, 844);
const petitTelephone = Size(320, 640);

/// Monte l'application complète (router réel, shells, redirections),
/// connectée en tant que [utilisateur], puis navigue vers [chemin].
Future<ProviderContainer> monterApp(
  WidgetTester tester, {
  required String chemin,
  Map<String, dynamic>? utilisateur,
  Size taille = telephone,
  int? entrepriseActive,
  String roleEntreprise = 'proprietaire',
  Map<String, Object> prefsEnPlus = const {},
  bool visiteur = false,
  /// Réponses à servir à la place des données factices (ex. réponses
  /// réelles enregistrées par test/live/enregistrer_reponses.dart)
  Map<String, dynamic> Function(String path)? repondre,
}) async {
  tester.view.physicalSize = taille * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final user = utilisateur ?? utilisateurAcheteur;
  final connecte = !visiteur &&
      !['/login', '/register', '/mot-de-passe-oublie'].contains(chemin);
  SharedPreferences.setMockInitialValues({
    if (connecte) AppConstants.keyAccessToken: 'jeton',
    if (connecte) AppConstants.keyRefreshToken: 'jeton',
    AppConstants.keyUserRole: user['role'] as String,
    AppConstants.keyPosOnboardingVu: true,
    if (entrepriseActive != null) AppConstants.keyEntrepriseActive: entrepriseActive,
    if (entrepriseActive != null) AppConstants.keyEntrepriseActiveRole: roleEntreprise,
    ...prefsEnPlus,
  });
  final prefs = await SharedPreferences.getInstance();

  // E/S réelles : hors de la zone fakeAsync du test (sinon blocage)
  final boxes = (await tester.runAsync(() async {
    final dossier = await Directory.systemTemp.createTemp('hive_design');
    Hive.init(dossier.path);
    return [
      await Hive.openBox('${AppConstants.hivePosSessionBox}_${dossier.hashCode}'),
      await Hive.openBox('${AppConstants.hivePosSalesBox}_${dossier.hashCode}'),
    ];
  }))!;
  final sessionBox = boxes[0];
  final ventesBox  = boxes[1];

  final container = ProviderContainer(overrides: [
    localStorageProvider.overrideWithValue(LocalStorage(prefs)),
    secureStorageProvider.overrideWithValue(SecureStorage(prefs)),
    posLocalStorageProvider.overrideWithValue(PosLocalStorage(sessionBox, ventesBox)),
    apiClientProvider.overrideWithValue(
        FakeApi(repondre ?? (p) => reponseFactice(p, user))),
    connectivityProvider.overrideWith((ref) => Stream.value(true)),
  ]);
  addTearDown(container.dispose);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: Consumer(builder: (_, ref, __) => MaterialApp.router(
      theme: AppTheme.lightTheme,
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      locale: const Locale('fr', 'FR'),
    )),
  ));
  await laisserCharger(tester);
  container.read(routerProvider).go(chemin);
  await laisserCharger(tester);
  return container;
}

/// Quelques images (sans pumpAndSettle : indicateurs de chargement infinis).
Future<void> laisserCharger(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Capture pour la revue visuelle, écrite avec `--update-goldens`. Sans ce
/// drapeau, pas de comparaison au pixel près (certains écrans affichent
/// l'heure) : ce sont les erreurs de rendu qui font échouer les tests.
Future<void> capture(WidgetTester tester, String nom) async {
  if (!autoUpdateGoldenFiles) return;
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('captures/$nom.png'));
}
