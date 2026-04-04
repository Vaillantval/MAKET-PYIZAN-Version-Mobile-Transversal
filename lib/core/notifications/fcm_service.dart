import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../storage/secure_storage.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    ref.read(apiClientProvider),
    ref.read(secureStorageProvider),
  );
});

/// Gestionnaire des notifications push Firebase
class FcmService {
  final ApiClient      _api;
  final SecureStorage  _storage;
  final _messaging     = FirebaseMessaging.instance;

  FcmService(this._api, this._storage);

  /// Initialiser FCM après login
  Future<void> initialize({required String role}) async {
    // Demander la permission
    final settings = await _messaging.requestPermission(
      alert:       true,
      badge:       true,
      sound:       true,
      provisional: false,
    );

    if (settings.authorizationStatus !=
        AuthorizationStatus.authorized) return;

    // Récupérer le token device
    final token = await _messaging.getToken();
    if (token == null) return;

    // Sauvegarder localement
    await _storage.setString('fcm_token', token);

    // Envoyer au backend (s'abonne au topic du rôle)
    try {
      await _api.post(AppEndpoints.fcmToken, data: {
        'fcm_token': token,
      });
    } catch (_) {}

    // Écouter les refreshes de token
    _messaging.onTokenRefresh.listen((newToken) async {
      await _storage.setString('fcm_token', newToken);
      try {
        await _api.post(AppEndpoints.fcmToken, data: {
          'fcm_token': newToken,
        });
      } catch (_) {}
    });
  }

  /// Désinscrire au logout
  Future<void> dispose() async {
    final token = await _storage.getString('fcm_token');
    if (token != null) {
      try {
        final refresh = await _storage.getRefreshToken();
        await _api.post(AppEndpoints.logout, data: {
          'refresh':   refresh ?? '',
          'fcm_token': token,
        });
      } catch (_) {}
    }
    await _messaging.deleteToken();
  }

  /// Message reçu en foreground
  Stream<RemoteMessage> get onForegroundMessage =>
      FirebaseMessaging.onMessage;

  /// Tap sur notification (app en background)
  Stream<RemoteMessage> get onNotificationTap =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Notification initiale (app fermée)
  Future<RemoteMessage?> get initialMessage =>
      _messaging.getInitialMessage();
}

// ── Background handler (doit être top-level) ──────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Firebase affiche la notification automatiquement
}
