import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import '../../providers/auth_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    ref.read(secureStorageProvider),
    // Lu à l'appel seulement (authProvider dépend lui-même de ce client)
    onSessionExpiree: () => ref.read(authProvider.notifier).sessionExpiree(),
  );
});

class ApiClient {
  late final Dio _dio;
  final SecureStorage _storage;
  /// Appelé quand le serveur refuse le renouvellement du jeton (compte
  /// supprimé, jeton révoqué) : l'app doit repasser en déconnecté.
  final void Function()? onSessionExpiree;

  ApiClient(this._storage, {this.onSessionExpiree}) {
    _dio = Dio(
      BaseOptions(
        baseUrl:        AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      // JWT + device POS : doit tourner avant le logger, sinon celui-ci
      // affiche les headers tels qu'ils étaient AVANT ajout (Authorization
      // et X-POS-Device y semblent alors toujours absents, même quand ils
      // sont correctement envoyés).
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError:   _onError,
      ),
      // Logger (debug uniquement : en release il écrirait jetons et
      // données personnelles dans le logcat)
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody:   true,
          responseBody:  true,
          error:         true,
          compact:       true,
        ),
    ]);
  }

  // Ajouter le token à chaque requête
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Terminal POS : joindre le device_uid à toutes les routes /api/pos/*
    // (403 HEADER_MANQUANT sinon), et à tout appel d'un opérateur de caisse
    final role = await _storage.getUserRole();
    if (role == 'pos_operator' || options.uri.path.startsWith('/api/pos/')) {
      // Créé au besoin : un premier appel de caisse peut précéder
      // posDeviceUidProvider (403 HEADER_MANQUANT sinon)
      options.headers['X-POS-Device'] = _storage.deviceUidPos();
    }

    // Espace entreprise : désigner l'entreprise sur laquelle on agit
    final entrepriseId = _storage.getEntrepriseActiveId();
    if (entrepriseId != null &&
        _cibleEntreprise(options.uri.path, _storage.getEntrepriseActiveRole())) {
      options.headers['X-Entreprise'] = '$entrepriseId';
    }

    handler.next(options);
  }

  // Endpoints qui agissent pour une entreprise (sans l'en-tête, le backend
  // ne sait choisir que si le compte n'appartient qu'à une seule).
  static const _prefixesEntreprise = [
    '/api/auth/producteur/',
    '/api/products/mes-produits/',
    '/api/collectes/',
  ];

  // Avec X-Entreprise, ces endpoints basculent sur le portefeuille de
  // l'entreprise — réservé à ses propriétaires (403 pour un gestionnaire).
  // Les autres opérations wallet (recharge, paiement, bons…) restent
  // toujours personnelles côté backend.
  static const _walletEntreprise = [
    '/api/wallet/',
    '/api/wallet/transactions/',
    '/api/wallet/retrait/',
    '/api/wallet/retraits/',
  ];

  static bool _cibleEntreprise(String path, String? role) {
    if (_prefixesEntreprise.any(path.startsWith)) return true;
    return role == 'proprietaire' && _walletEntreprise.contains(path);
  }

  // Rafraîchir le token si 401
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final path = error.requestOptions.uri.path;
    if (error.response?.statusCode == 401 &&
        !path.endsWith('/api/auth/token/refresh/') &&
        !path.endsWith('/api/auth/login/')) {
      // Jeton déjà renouvelé par une autre requête depuis l'envoi de
      // celle-ci : simplement la relancer avec le nouveau
      final envoye = (error.requestOptions.headers['Authorization'] as String?)
          ?.replaceFirst('Bearer ', '');
      final actuel = await _storage.getAccessToken();
      final bool? refreshed = (actuel != null && actuel != envoye)
          ? true
          : await _rafraichirUneFois();
      if (refreshed == true) {
        // Relancer la requête originale
        final token = await _storage.getAccessToken();
        error.requestOptions.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await _dio.fetch(error.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {}
      }
      // Jeton refusé par le serveur → déconnexion. Échec réseau (null) :
      // garder la session, la requête échoue simplement (mode hors ligne)
      if (refreshed == false) {
        await _storage.clearTokens();
        onSessionExpiree?.call();
      }
    }
    handler.next(error);
  }

  /// Un seul renouvellement à la fois. Le backend fait tourner le jeton de
  /// rafraîchissement et invalide l'ancien (ROTATE + BLACKLIST) : quand
  /// plusieurs requêtes expirent ensemble (ouverture de l'app le lendemain),
  /// des renouvellements parallèles présentaient tous le même jeton, les
  /// suivants étaient refusés et l'app déconnectait l'utilisateur.
  Future<bool?>? _refreshEnCours;

  /// true : renouvelé ; false : refusé par le serveur ; null : réseau.
  Future<bool?> _rafraichirUneFois() =>
      _refreshEnCours ??= _refreshToken().whenComplete(() => _refreshEnCours = null);

  Future<bool?> _refreshToken() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null) return false;

    try {
      final response = await _dio.post(
        '/api/auth/token/refresh/',
        data: {'refresh': refresh},
        options: Options(
          headers: {'Authorization': null}, // sans token
        ),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['access'] != null) {
        await _storage.saveAccessToken(data['access'] as String);
        if (data['refresh'] != null) {
          await _storage.saveRefreshToken(data['refresh'] as String);
        }
        return true;
      }
    } on DioException catch (e) {
      // Réponse du serveur (401/400 : jeton expiré ou révoqué) → refus ;
      // pas de réponse (hors ligne, délai dépassé) → indéterminé
      return e.response == null ? null : false;
    } catch (_) {}
    return false;
  }

  // ── Méthodes HTTP ──────────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.post(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response> patch(
    String path, {
    dynamic data,
    Options? options,
  }) => _dio.patch(path, data: data, options: options);

  Future<Response> delete(
    String path, {
    Options? options,
  }) => _dio.delete(path, options: options);

  // Multipart (upload photos)
  Future<Response> postMultipart(
    String path,
    FormData formData,
  ) => _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
}
