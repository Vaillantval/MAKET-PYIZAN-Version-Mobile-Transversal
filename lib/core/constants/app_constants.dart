class AppConstants {
  // API
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://maketpeyizan.up.railway.app',
  );
  static const Duration connectTimeout  = Duration(seconds: 30);
  static const Duration receiveTimeout  = Duration(seconds: 30);

  // Storage keys
  static const String keyAccessToken   = 'access_token';
  static const String keyRefreshToken  = 'refresh_token';
  static const String keyUserRole      = 'user_role';
  static const String keyUserId        = 'user_id';
  static const String keyUserData      = 'user_data';
  static const String keyCatalogCache  = 'catalog_cache';
  static const String keyGeoCache      = 'geo_cache';
  static const String keySyncQueue     = 'sync_queue';
  static const String keyLastSync      = 'last_sync';

  // POS
  static const String keyPosDeviceUid    = 'pos_device_uid';
  static const String keyPosCatalogCache = 'pos_catalog_cache';
  static const String hivePosSessionBox  = 'pos_session';
  static const String hivePosSalesBox    = 'pos_sales';
  static const String keyPosImpressionAuto = 'pos_impression_auto';

  // Cache TTL
  static const Duration catalogCacheTTL  = Duration(hours: 6);
  static const Duration geoCacheTTL      = Duration(hours: 24);
  static const Duration userCacheTTL     = Duration(hours: 1);

  // Pagination
  static const int pageSize = 20;

  // Offline
  static const int maxSyncRetries = 3;
  static const Duration syncInterval = Duration(minutes: 5);
}
