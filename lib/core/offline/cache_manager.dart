import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager(ref.read(localStorageProvider));
});

class CacheManager {
  final LocalStorage _storage;
  CacheManager(this._storage);

  // ── Catalogue ──────────────────────────────────────────────────

  Future<void> saveCatalogue(List<dynamic> produits) async {
    await _storage.setJsonList(AppConstants.keyCatalogCache, produits);
    await _storage.setTimestamp('${AppConstants.keyCatalogCache}_ts');
  }

  List<dynamic>? getCatalogue() {
    if (!isCatalogueValid()) return null;
    return _storage.getJsonList(AppConstants.keyCatalogCache);
  }

  bool isCatalogueValid() => _storage.isCacheValid(
    '${AppConstants.keyCatalogCache}_ts',
    AppConstants.catalogCacheTTL,
  );

  // ── Géographie ─────────────────────────────────────────────────

  Future<void> saveGeo(Map<String, dynamic> data) async {
    await _storage.setJson(AppConstants.keyGeoCache, data);
    await _storage.setTimestamp('${AppConstants.keyGeoCache}_ts');
  }

  Map<String, dynamic>? getGeo() {
    if (!isGeoValid()) return null;
    return _storage.getJson(AppConstants.keyGeoCache);
  }

  bool isGeoValid() => _storage.isCacheValid(
    '${AppConstants.keyGeoCache}_ts',
    AppConstants.geoCacheTTL,
  );

  // ── Utilisateur ────────────────────────────────────────────────

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.setJson(AppConstants.keyUserData, user);
    await _storage.setTimestamp('${AppConstants.keyUserData}_ts');
  }

  Map<String, dynamic>? getUser() =>
      _storage.getJson(AppConstants.keyUserData);

  // ── Données génériques avec clé ────────────────────────────────

  Future<void> saveData(String key, dynamic data, {Duration? ttl}) async {
    if (data is List) {
      await _storage.setJsonList(key, data);
    } else if (data is Map<String, dynamic>) {
      await _storage.setJson(key, data);
    }
    await _storage.setTimestamp('${key}_ts');
  }

  dynamic getData(String key, {Duration? ttl}) {
    final effectiveTtl = ttl ?? const Duration(hours: 1);
    if (!_storage.isCacheValid('${key}_ts', effectiveTtl)) return null;
    return _storage.getJsonList(key) ?? _storage.getJson(key);
  }

  Future<void> invalidate(String key) async {
    await _storage.remove(key);
    await _storage.remove('${key}_ts');
  }

  Future<void> clearAll() async => _storage.clear();
}
