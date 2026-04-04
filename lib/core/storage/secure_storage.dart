import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final secureStorageProvider = Provider<SecureStorage>((_) => SecureStorage());

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Tokens
  Future<void> saveAccessToken(String token) async =>
      _storage.write(key: AppConstants.keyAccessToken, value: token);

  Future<void> saveRefreshToken(String token) async =>
      _storage.write(key: AppConstants.keyRefreshToken, value: token);

  Future<String?> getAccessToken()  async =>
      _storage.read(key: AppConstants.keyAccessToken);

  Future<String?> getRefreshToken() async =>
      _storage.read(key: AppConstants.keyRefreshToken);

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
  }

  // Données utilisateur
  Future<void> saveUserRole(String role) async =>
      _storage.write(key: AppConstants.keyUserRole, value: role);

  Future<String?> getUserRole() async =>
      _storage.read(key: AppConstants.keyUserRole);

  Future<void> saveUserId(int id) async =>
      _storage.write(key: AppConstants.keyUserId, value: id.toString());

  Future<int?> getUserId() async {
    final v = await _storage.read(key: AppConstants.keyUserId);
    return v != null ? int.tryParse(v) : null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Clé générique (ex: fcm_token)
  Future<void> setString(String key, String value) async =>
      _storage.write(key: key, value: value);

  Future<String?> getString(String key) async =>
      _storage.read(key: key);

  Future<void> clearAll() async => _storage.deleteAll();
}
