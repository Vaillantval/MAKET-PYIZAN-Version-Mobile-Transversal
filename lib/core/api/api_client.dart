import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(secureStorageProvider));
});

class ApiClient {
  late final Dio _dio;
  final SecureStorage _storage;

  ApiClient(this._storage) {
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
      // Logger (debug uniquement)
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

    // Terminal POS : joindre le device_uid du terminal à toutes les requêtes
    final role = await _storage.getUserRole();
    if (role == 'pos_operator') {
      final deviceUid = await _storage.getString(AppConstants.keyPosDeviceUid);
      if (deviceUid != null && deviceUid.isNotEmpty) {
        options.headers['X-POS-Device'] = deviceUid;
      }
    }

    handler.next(options);
  }

  // Rafraîchir le token si 401
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Relancer la requête originale
        final token = await _storage.getAccessToken();
        error.requestOptions.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await _dio.fetch(error.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {}
      }
      // Refresh échoué → déconnexion
      await _storage.clearTokens();
    }
    handler.next(error);
  }

  Future<bool> _refreshToken() async {
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
