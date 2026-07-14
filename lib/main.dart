import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/offline/connectivity_service.dart';
import 'core/storage/local_storage.dart';
import 'core/storage/secure_storage.dart';
import 'core/storage/pos_local_storage.dart';
import 'core/constants/app_constants.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await Hive.initFlutter();
  final posSessionBox = await Hive.openBox(AppConstants.hivePosSessionBox);
  final posSalesBox   = await Hive.openBox(AppConstants.hivePosSalesBox);

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Firebase — ne doit jamais bloquer le démarrage de l'app (ex: config
  // Android manquante). Sans ça, une exception ici empêche runApp() et
  // l'app reste bloquée indéfiniment sur le splash natif.
  //
  // onBackgroundMessage() n'est volontairement PAS enregistré : le
  // handler associé est un no-op (Firebase affiche déjà la notification
  // automatiquement côté natif), et son seul effet observé est de forcer
  // le plugin à créer un second moteur Flutter en arrière-plan dès le
  // lancement — coûteux, et bloquant le thread principal au point de
  // geler toute l'app sur du matériel bas de gamme (ex: terminaux
  // caisse Sunmi/MediaTek).
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase indisponible, notifications push désactivées : $e');
  }

  // Connectivité — ne doit pas bloquer le démarrage : sur certains réseaux
  // (DNS lent/indisponible), la vérification initiale peut prendre un
  // temps indéterminé. L'état est consommé de façon réactive par
  // isOnlineProvider une fois l'app affichée, pas au boot.
  unawaited(ConnectivityService().initialize());

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(LocalStorage(prefs)),
        secureStorageProvider.overrideWithValue(SecureStorage(prefs)),
        posLocalStorageProvider.overrideWithValue(
          PosLocalStorage(posSessionBox, posSalesBox),
        ),
      ],
      child: const MaketPeyizanApp(),
    ),
  );
}
