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

  // ── Catalogue POS (ETag — pas de TTL, toujours servi hors ligne) ─

  Future<void> savePosCatalogue(List<dynamic> produits, {String? etag}) async {
    await _storage.setJsonList(AppConstants.keyPosCatalogCache, produits);
    if (etag != null) {
      await _storage.setString('${AppConstants.keyPosCatalogCache}_etag', etag);
    }
  }

  List<dynamic>? getPosCatalogue() =>
      _storage.getJsonList(AppConstants.keyPosCatalogCache);

  String? getPosCatalogueEtag() =>
      _storage.getString('${AppConstants.keyPosCatalogCache}_etag');

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

  // Efface uniquement les clés de CACHE gérées par cette classe — jamais
  // via _storage.clear() (SharedPreferences.clear() efface TOUT le
  // stockage partagé, y compris des clés sans rapport comme le
  // device_uid POS ou le flag d'onboarding : appelé depuis
  // AuthNotifier.logout(), ça désenregistrait le terminal POS à CHAQUE
  // déconnexion, obligeant à le refaire valider par un admin à chaque
  // session opérateur).
  Future<void> clearAll() async {
    for (final key in [
      AppConstants.keyCatalogCache,
      AppConstants.keyPosCatalogCache,
      AppConstants.keyGeoCache,
      AppConstants.keyUserData,
      'dashboard_stats', // producteur/providers/dashboard_provider.dart
      'admin_stats',     // admin/providers/admin_stats_provider.dart
      'categories',      // acheteur/providers/catalogue_provider.dart
    ]) {
      await _storage.remove(key);
      await _storage.remove('${key}_ts');
    }
    await _storage.remove('${AppConstants.keyPosCatalogCache}_etag');
  }
}
