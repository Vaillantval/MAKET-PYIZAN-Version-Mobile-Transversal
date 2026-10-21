import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../firebase_init.dart';
import '../storage/secure_storage.dart';
import 'notifications_locales.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    ref.read(apiClientProvider),
    ref.read(secureStorageProvider),
  );
});

/// Jeton FCM de l'appareil, enregistré sur le compte connecté.
///
/// Le backend ne peut pousser une notification qu'aux comptes dont le
/// `fcm_token` est rempli (POST /api/auth/fcm-token/, qui abonne aussi au
/// topic du rôle). [enregistrer] est donc appelé après chaque connexion
/// ET à chaque démarrage avec une session ouverte ; le jeton est renvoyé à
/// chaque rotation (onTokenRefresh).
class FcmService {
  static const _cleJeton = 'fcm_token';

  final ApiClient     _api;
  final SecureStorage _storage;
  StreamSubscription<String>? _rotation;
  bool _envoyeCeLancement = false;

  FcmService(this._api, this._storage);

  /// [uneFoisParLancement] : au rafraîchissement du profil, ne pas renvoyer
  /// le jeton s'il l'a déjà été depuis le démarrage de l'app.
  Future<void> enregistrer({bool uneFoisParLancement = false}) async {
    if (uneFoisParLancement && _envoyeCeLancement) return;
    _envoyeCeLancement = true;
    // Firebase est initialisé sans bloquer le démarrage (voir FirebaseInit)
    if (!await FirebaseInit.ready) return;
    final messaging = FirebaseMessaging.instance;

    await NotificationsLocales.initialiser(); // canal haute importance
    try {
      // Android 13+ : POST_NOTIFICATIONS. Un refus n'empêche pas
      // d'enregistrer le jeton (l'utilisateur peut l'autoriser plus tard).
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Permission notifications : $e');
    }

    try {
      final jeton = await messaging.getToken();
      if (jeton != null) await _envoyer(jeton);
    } catch (e) {
      debugPrint('Jeton FCM indisponible : $e');
    }
    _rotation ??= messaging.onTokenRefresh.listen(_envoyer);
  }

  Future<void> _envoyer(String jeton) async {
    await _storage.setString(_cleJeton, jeton);
    if (await _storage.getAccessToken() == null) return; // pas de compte
    try {
      await _api.post(AppEndpoints.fcmToken, data: {'fcm_token': jeton});
    } catch (e) {
      debugPrint('Enregistrement du jeton FCM refusé : $e');
    }
  }

  /// Jeton à joindre à POST /api/auth/logout/ (le serveur l'efface du
  /// compte et le désabonne des topics).
  Future<String?> jetonActuel() => _storage.getString(_cleJeton);

  /// Après la déconnexion : ne plus suivre les rotations du jeton et en
  /// obtenir un neuf pour le prochain compte.
  Future<void> oublier() async {
    await _rotation?.cancel();
    _rotation = null;
    _envoyeCeLancement = false;
    if (!await FirebaseInit.ready) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }
}
