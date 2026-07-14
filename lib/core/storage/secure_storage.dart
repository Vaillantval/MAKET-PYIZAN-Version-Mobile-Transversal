import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

final secureStorageProvider = Provider<SecureStorage>(
  (_) => throw UnimplementedError('Init in main.dart'),
);

// Persistance via SharedPreferences plutôt que flutter_secure_storage :
// sur certains terminaux (ex: caisses Sunmi bas de gamme, chipset MediaTek
// MT6761), l'Android Keystore natif reste bloqué indéfiniment au premier
// accès, ce qui gelait l'app dès le démarrage (checkAuth). Les tokens JWT
// sont de toute façon de courte durée de vie, transmis en HTTPS et
// révocables côté backend ; un vrai chiffrement matériel n'apporterait
// pas de garantie supplémentaire ici, seulement un point de blocage.
class SecureStorage {
  final SharedPreferences _prefs;
  SecureStorage(this._prefs);

  // Tokens
  Future<void> saveAccessToken(String token) async =>
      _prefs.setString(AppConstants.keyAccessToken, token);

  Future<void> saveRefreshToken(String token) async =>
      _prefs.setString(AppConstants.keyRefreshToken, token);

  Future<String?> getAccessToken()  async =>
      _prefs.getString(AppConstants.keyAccessToken);

  Future<String?> getRefreshToken() async =>
      _prefs.getString(AppConstants.keyRefreshToken);

  Future<void> clearTokens() async {
    await _prefs.remove(AppConstants.keyAccessToken);
    await _prefs.remove(AppConstants.keyRefreshToken);
  }

  // Données utilisateur
  Future<void> saveUserRole(String role) async =>
      _prefs.setString(AppConstants.keyUserRole, role);

  Future<String?> getUserRole() async =>
      _prefs.getString(AppConstants.keyUserRole);

  Future<void> saveUserId(int id) async =>
      _prefs.setInt(AppConstants.keyUserId, id);

  Future<int?> getUserId() async => _prefs.getInt(AppConstants.keyUserId);

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Clé générique (ex: fcm_token)
  Future<void> setString(String key, String value) async =>
      _prefs.setString(key, value);

  Future<String?> getString(String key) async => _prefs.getString(key);

  Future<void> clearAll() async {
    await _prefs.remove(AppConstants.keyAccessToken);
    await _prefs.remove(AppConstants.keyRefreshToken);
    await _prefs.remove(AppConstants.keyUserRole);
    await _prefs.remove(AppConstants.keyUserId);
  }
}
