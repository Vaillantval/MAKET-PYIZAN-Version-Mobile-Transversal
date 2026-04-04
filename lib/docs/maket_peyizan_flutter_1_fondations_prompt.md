# PROMPT CLAUDE CODE — Makèt Peyizan Mobile
# Flutter — Partie 1 : Fondations, Architecture, Auth, Offline Engine

---

## CONTEXTE DU PROJET

Tu vas créer l'application mobile **Makèt Peyizan** en Flutter/Dart.
C'est une marketplace agricole haïtienne connectée à une API Django REST.

**API Base URL :** `https://maketpeyizan.up.railway.app` (configurable via .env)

**4 rôles utilisateurs avec navigation distincte :**
- `acheteur`    → BottomNav : Accueil, Catalogue, Panier, Commandes, Profil
- `producteur`  → BottomNav : Dashboard, Commandes, Catalogue, Collectes, Profil
- `collecteur`  → BottomNav : Collectes, Profil
- `superadmin`  → NavigationDrawer admin complet

**Palette de couleurs officielle :**
```dart
// Tirée du logo Makèt Peyizan
static const Color vertFonce  = Color(0xFF1A6B2F);
static const Color vertVif    = Color(0xFF27AE60);
static const Color vertMenthe = Color(0xFFE8F8EE);
static const Color jaune      = Color(0xFFE8D800);
static const Color jauneClair = Color(0xFFFDFBE8);
static const Color noir       = Color(0xFF1A1A1A);
static const Color grisClair  = Color(0xFFF4F6F9);
```

**Spécificités importantes :**
1. Mode hors-ligne AVANCÉ — tout fonctionne sans internet avec sync différée
2. Dashboard Superadmin mobile complet (même niveau que web)
3. Notifications push FCM avec topics par rôle
4. Paiement MonCash via WebView
5. Sélecteur géographique cascade (département → commune → section)

---

## ÉTAPE 1 — STRUCTURE DU PROJET

Crée la structure complète suivante :

```
maket_peyizan/
├── lib/
│   ├── main.dart
│   ├── app.dart                          → MaterialApp + ThemeData
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_constants.dart        → URLs, timeouts, clés storage
│   │   ├── api/
│   │   │   ├── api_client.dart           → Dio + intercepteurs JWT
│   │   │   ├── api_endpoints.dart        → toutes les URLs
│   │   │   └── api_response.dart         → modèle réponse { success, data, error }
│   │   ├── storage/
│   │   │   ├── secure_storage.dart       → tokens JWT
│   │   │   └── local_storage.dart        → SharedPreferences wrapper
│   │   ├── offline/
│   │   │   ├── offline_manager.dart      → gestionnaire principal
│   │   │   ├── sync_queue.dart           → file d'attente des actions
│   │   │   ├── cache_manager.dart        → cache des données
│   │   │   └── connectivity_service.dart → état réseau
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── image_utils.dart          → imageUrl() helper
│   │       ├── date_utils.dart
│   │       └── format_utils.dart         → HTG formatter
│   │
│   ├── models/
│   │   ├── user.dart
│   │   ├── producteur.dart
│   │   ├── acheteur.dart
│   │   ├── produit.dart
│   │   ├── categorie.dart
│   │   ├── commande.dart
│   │   ├── panier.dart
│   │   ├── paiement.dart
│   │   ├── voucher.dart
│   │   ├── collecte.dart
│   │   ├── adresse.dart
│   │   └── geo.dart
│   │
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── connectivity_provider.dart
│   │   └── sync_provider.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── splash_screen.dart
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── pending_validation_screen.dart
│   │   │   ├── widgets/
│   │   │   │   └── auth_text_field.dart
│   │   │   └── auth_service.dart
│   │   │
│   │   ├── acheteur/              → Phase 2
│   │   ├── producteur/            → Phase 3
│   │   ├── collecteur/            → Phase 3
│   │   └── admin/                 → Phase 4
│   │
│   └── router/
│       └── app_router.dart        → go_router complet
│
├── pubspec.yaml
├── .env                           → BASE_URL, etc.
└── android/
    └── app/
        └── google-services.json   → Firebase (placeholder)
```

---

## ÉTAPE 2 — `pubspec.yaml`

```yaml
name: maket_peyizan
description: Marketplace agricole haïtienne

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # HTTP & API
  dio: ^5.7.0
  pretty_dio_logger: ^1.3.1

  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.0.0

  # Storage
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.4

  # Models
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Images
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
  shimmer: ^3.0.0

  # Connectivity & Offline
  connectivity_plus: ^6.0.5
  internet_connection_checker_plus: ^2.5.1

  # Firebase
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.4

  # Paiement MonCash
  webview_flutter: ^4.10.0

  # UI
  flutter_svg: ^2.0.10
  lottie: ^3.1.2
  flutter_staggered_animations: ^1.1.1
  intl: ^0.19.0
  timeago: ^3.7.0

  # Utilities
  equatable: ^2.0.5
  uuid: ^4.5.1
  logger: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.3
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
    - .env
  fonts:
    - family: PlayfairDisplay
      fonts:
        - asset: assets/fonts/PlayfairDisplay-Bold.ttf
          weight: 700
        - asset: assets/fonts/PlayfairDisplay-Black.ttf
          weight: 900
    - family: DMSans
      fonts:
        - asset: assets/fonts/DMSans-Regular.ttf
        - asset: assets/fonts/DMSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/DMSans-Bold.ttf
          weight: 700
```

---

## ÉTAPE 3 — Constantes et Thème

### `lib/core/constants/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Palette officielle Makèt Peyizan
  static const Color vertFonce  = Color(0xFF1A6B2F);
  static const Color vertVif    = Color(0xFF27AE60);
  static const Color vertMoyen  = Color(0xFF2ECC71);
  static const Color vertMenthe = Color(0xFFE8F8EE);
  static const Color jaune      = Color(0xFFE8D800);
  static const Color jauneClair = Color(0xFFFDFBE8);
  static const Color blanc      = Color(0xFFFFFFFF);
  static const Color noir       = Color(0xFF1A1A1A);
  static const Color grisClair  = Color(0xFFF4F6F9);
  static const Color grisTexte  = Color(0xFF555555);
  static const Color rouge      = Color(0xFFE74C3C);
  static const Color orange     = Color(0xFFE67E22);
  static const Color bleu       = Color(0xFF2980B9);

  // Statuts commandes
  static const Color statutAttente   = Color(0xFFF39C12);
  static const Color statutConfirmee = Color(0xFF3498DB);
  static const Color statutLivree    = Color(0xFF27AE60);
  static const Color statutAnnulee   = Color(0xFFE74C3C);
}
```

---

### `lib/core/constants/app_constants.dart`

```dart
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
```

---

### `lib/core/constants/app_endpoints.dart`

```dart
class AppEndpoints {
  static const String baseUrl = AppConstants.baseUrl;

  // Auth
  static const String register       = '/api/auth/register/';
  static const String login          = '/api/auth/login/';
  static const String logout         = '/api/auth/logout/';
  static const String tokenRefresh   = '/api/auth/token/refresh/';
  static const String me             = '/api/auth/me/';
  static const String changePassword = '/api/auth/change-password/';
  static const String fcmToken       = '/api/auth/fcm-token/';

  // Adresses
  static const String adresses       = '/api/auth/adresses/';
  static String adresseDetail(int id) => '/api/auth/adresses/$id/';
  static String adresseDefault(int id) => '/api/auth/adresses/$id/default/';

  // Commandes acheteur
  static const String mesCommandes      = '/api/auth/commandes/';
  static String maCommande(String num)  => '/api/auth/commandes/$num/';

  // Dashboard producteur
  static const String producteurStats    = '/api/auth/producteur/stats/';
  static const String producteurProfil   = '/api/auth/producteur/profil/';
  static const String producteurCommandes = '/api/auth/producteur/commandes/';
  static String producteurCommande(String num) =>
      '/api/auth/producteur/commandes/$num/';
  static String producteurCommandeStatut(String num) =>
      '/api/auth/producteur/commandes/$num/statut/';

  // Catalogue
  static const String produits      = '/api/products/';
  static const String categories    = '/api/products/categories/';
  static String produitDetail(String slug) => '/api/products/public/$slug/';
  static const String mesProduits   = '/api/products/mes-produits/';
  static String monProduit(String slug) => '/api/products/mes-produits/$slug/';

  // Panier
  static const String panier        = '/api/orders/panier/';
  static const String panierAjouter = '/api/orders/panier/ajouter/';
  static String panierModifier(String slug) =>
      '/api/orders/panier/modifier/$slug/';
  static String panierRetirer(String slug) =>
      '/api/orders/panier/retirer/$slug/';
  static const String panierVider   = '/api/orders/panier/vider/';
  static const String commander     = '/api/orders/commander/';

  // Paiements
  static const String initierPaiement  = '/api/payments/initier/';
  static const String soumettrePreuve  = '/api/payments/preuve/';
  static const String verifierPaiement = '/api/payments/verifier/';
  static const String mesPaiements     = '/api/payments/mes-paiements/';
  static const String validerVoucher   = '/api/payments/voucher/valider/';
  static const String mesVouchers      = '/api/payments/voucher/mes-vouchers/';

  // Collectes
  static const String mesParticipations = '/api/collectes/mes-participations/';
  static String confirmerParticipation(int id) =>
      '/api/collectes/participations/$id/confirmer/';

  // Géographie
  static const String departements   = '/api/geo/departements/';
  static const String communes       = '/api/geo/communes/';
  static const String sections       = '/api/geo/sections/';
  static const String geoArbre       = '/api/geo/arbre/';
  static const String geoRecherche   = '/api/geo/recherche/';

  // Admin
  static const String adminStats     = '/api/admin/stats/';
  static const String adminOptions   = '/api/admin/options/';
  static const String adminUsers     = '/api/admin/users/';
  static const String adminProducteurs = '/api/admin/producteurs/';
  static const String adminCommandes = '/api/admin/commandes/';
  static const String adminPaiements = '/api/admin/paiements/';
  static const String adminCatalogue = '/api/admin/catalogue/';
  static const String adminStocks    = '/api/admin/stocks/lots/';
  static const String adminAlertes   = '/api/admin/stocks/alertes/';
  static const String adminCollectes = '/api/admin/collectes/';

  // Système
  static const String healthCheck    = '/health/';
  static const String faq            = '/faq/';
  static const String contact        = '/contact/';
}
```

---

### `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.vertVif,
      primary:   AppColors.vertFonce,
      secondary: AppColors.jaune,
    ),
    fontFamily: 'DMSans',
    scaffoldBackgroundColor: AppColors.grisClair,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.vertFonce,
      foregroundColor: AppColors.blanc,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.blanc,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.vertVif,
        foregroundColor: AppColors.blanc,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.blanc,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.vertVif, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 14,
      ),
    ),

    cardTheme: CardTheme(
      color: AppColors.blanc,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.blanc,
      selectedItemColor: AppColors.vertFonce,
      unselectedItemColor: Color(0xFF999999),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
```

---

## ÉTAPE 4 — Modèles Freezed

### `lib/models/user.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int    id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    @Default('') String telephone,
    String? photo,
    @Default(false) bool isVerified,
    @Default(false) bool isSuperuser,
    @Default(false) bool isStaff,
    String? profilProducteurStatut,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

---

### `lib/models/produit.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'produit.freezed.dart';
part 'produit.g.dart';

@freezed
class Produit with _$Produit {
  const factory Produit({
    required int    id,
    required String nom,
    required String slug,
    @Default('') String variete,
    @Default('') String description,
    required String prixUnitaire,
    String? prixGros,
    required String uniteVente,
    required String uniteVenteLabel,
    @Default(1) int quantiteMinCommande,
    @Default(0) int stockReel,
    @Default(false) bool isFeatured,
    String? imagePrincipale,
    Map<String, dynamic>? categorie,
    Map<String, dynamic>? producteur,
    @Default('') String origine,
    @Default('') String saison,
    String? createdAt,
  }) = _Produit;

  factory Produit.fromJson(Map<String, dynamic> json) =>
      _$ProduitFromJson(json);
}
```

---

### `lib/models/commande.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'commande.freezed.dart';
part 'commande.g.dart';

@freezed
class Commande with _$Commande {
  const factory Commande({
    required String numeroCommande,
    required String producteur,
    required String total,
    required String statut,
    required String statutLabel,
    required String statutPaiement,
    @Default('') String methodePaiement,
    String? modeLivraison,
    String? adresseLivraison,
    String? notesAcheteur,
    String? createdAt,
    @Default([]) List<Map<String, dynamic>> details,
  }) = _Commande;

  factory Commande.fromJson(Map<String, dynamic> json) =>
      _$CommandeFromJson(json);
}
```

---

### `lib/models/panier.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'panier.freezed.dart';
part 'panier.g.dart';

@freezed
class LignePanier with _$LignePanier {
  const factory LignePanier({
    required int    id,
    required String slug,
    required String nom,
    required int    quantite,
    required String prixUnitaire,
    required double sousTotal,
    required String uniteVente,
    required int    producteurId,
    required String producteurNom,
    String? image,
    @Default(0) int stockReel,
  }) = _LignePanier;

  factory LignePanier.fromJson(Map<String, dynamic> json) =>
      _$LignePanierFromJson(json);
}

@freezed
class Panier with _$Panier {
  const factory Panier({
    @Default([]) List<LignePanier> items,
    @Default(0.0) double total,
    @Default(0) int nbArticles,
    @Default(0) int nbItems,
    @Default([]) List<Map<String, dynamic>> producteurs,
  }) = _Panier;

  factory Panier.fromJson(Map<String, dynamic> json) =>
      _$PanierFromJson(json);
}
```

---

### `lib/models/adresse.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'adresse.freezed.dart';
part 'adresse.g.dart';

@freezed
class Adresse with _$Adresse {
  const factory Adresse({
    required int    id,
    required String rue,
    required String commune,
    required String departement,
    @Default('') String sectionCommunale,
    @Default('') String telephone,
    @Default('') String instructions,
    @Default(false) bool isDefault,
  }) = _Adresse;

  factory Adresse.fromJson(Map<String, dynamic> json) =>
      _$AdresseFromJson(json);
}
```

---

## ÉTAPE 5 — Client API (Dio + JWT)

### `lib/core/api/api_response.dart`

```dart
class ApiResponse<T> {
  final bool    success;
  final T?      data;
  final String? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data:    fromData != null && json['data'] != null
                 ? fromData(json['data'])
                 : json['data'] as T?,
      error:   json['error']?.toString(),
    );
  }

  bool get isSuccess => success && error == null;
}
```

---

### `lib/core/api/api_client.dart`

```dart
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
      // Logger (debug uniquement)
      PrettyDioLogger(
        requestHeader: false,
        requestBody:   true,
        responseBody:  true,
        error:         true,
        compact:       true,
      ),
      // JWT intercepteur
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError:   _onError,
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
```

---

## ÉTAPE 6 — Secure Storage

### `lib/core/storage/secure_storage.dart`

```dart
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

  Future<void> clearAll() async => _storage.deleteAll();
}
```

---

### `lib/core/storage/local_storage.dart`

```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageProvider = Provider<LocalStorage>(
  (_) => throw UnimplementedError('Init in main.dart'),
);

class LocalStorage {
  final SharedPreferences _prefs;
  LocalStorage(this._prefs);

  // JSON helpers
  Future<void> setJson(String key, Map<String, dynamic> value) async =>
      _prefs.setString(key, jsonEncode(value));

  Map<String, dynamic>? getJson(String key) {
    final s = _prefs.getString(key);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<void> setJsonList(String key, List<dynamic> value) async =>
      _prefs.setString(key, jsonEncode(value));

  List<dynamic>? getJsonList(String key) {
    final s = _prefs.getString(key);
    if (s == null) return null;
    return jsonDecode(s) as List<dynamic>;
  }

  Future<void> setString(String key, String value) async =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<void> setInt(String key, int value) async =>
      _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setTimestamp(String key) async =>
      _prefs.setString(key, DateTime.now().toIso8601String());

  DateTime? getTimestamp(String key) {
    final s = _prefs.getString(key);
    return s != null ? DateTime.tryParse(s) : null;
  }

  bool isCacheValid(String timestampKey, Duration ttl) {
    final ts = getTimestamp(timestampKey);
    if (ts == null) return false;
    return DateTime.now().difference(ts) < ttl;
  }

  Future<void> remove(String key) async => _prefs.remove(key);
  Future<void> clear() async => _prefs.clear();
}
```

---

## ÉTAPE 7 — Offline Engine (le cœur du mode hors-ligne)

### `lib/core/offline/connectivity_service.dart`

```dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityService().onStatusChange;
});

final isOnlineProvider = Provider<bool>((ref) {
  final conn = ref.watch(connectivityProvider);
  return conn.when(
    data:    (online) => online,
    loading: () => false,
    error:   (_, __) => false,
  );
});

class ConnectivityService {
  static final ConnectivityService _instance =
      ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivity    = Connectivity();
  final _checker         = InternetConnection();
  final _controller      = StreamController<bool>.broadcast();
  bool _currentStatus    = false;

  Stream<bool> get onStatusChange => _controller.stream;
  bool get isOnline => _currentStatus;

  Future<void> initialize() async {
    // Vérifier l'état initial
    _currentStatus = await _checker.hasInternetAccess;
    _controller.add(_currentStatus);

    // Écouter les changements de connectivité
    _connectivity.onConnectivityChanged.listen((_) async {
      final online = await _checker.hasInternetAccess;
      if (online != _currentStatus) {
        _currentStatus = online;
        _controller.add(online);
      }
    });

    // Vérifier périodiquement
    Timer.periodic(const Duration(seconds: 30), (_) async {
      final online = await _checker.hasInternetAccess;
      if (online != _currentStatus) {
        _currentStatus = online;
        _controller.add(online);
      }
    });
  }
}
```

---

### `lib/core/offline/sync_queue.dart`

```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(ref.read(localStorageProvider));
});

/// Type d'action en attente de synchronisation
enum SyncActionType {
  panierAjouter,
  panierModifier,
  panierRetirer,
  panierVider,
  commander,
  confirmerCommande,
  soumettrePreuve,
  confirmerParticipation,
  updateProfil,
  createProduit,
  updateProduit,
  deleteProduit,
  contactMessage,
}

class SyncAction {
  final String         id;
  final SyncActionType type;
  final String         endpoint;
  final String         method;     // POST, PATCH, DELETE
  final Map<String, dynamic> payload;
  final int            retries;
  final DateTime       createdAt;
  final String?        localId;    // ID local pour l'UI avant sync

  SyncAction({
    required this.type,
    required this.endpoint,
    required this.method,
    required this.payload,
    this.localId,
    String? id,
    this.retries = 0,
    DateTime? createdAt,
  })  : id        = id        ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id':        id,
    'type':      type.name,
    'endpoint':  endpoint,
    'method':    method,
    'payload':   payload,
    'retries':   retries,
    'createdAt': createdAt.toIso8601String(),
    'localId':   localId,
  };

  factory SyncAction.fromJson(Map<String, dynamic> json) => SyncAction(
    id:       json['id'] as String,
    type:     SyncActionType.values.firstWhere(
                (e) => e.name == json['type'],
                orElse: () => SyncActionType.commander,
              ),
    endpoint: json['endpoint'] as String,
    method:   json['method'] as String,
    payload:  Map<String, dynamic>.from(json['payload'] as Map),
    retries:  json['retries'] as int? ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String),
    localId:  json['localId'] as String?,
  );

  SyncAction copyWith({int? retries}) => SyncAction(
    id:        id,
    type:      type,
    endpoint:  endpoint,
    method:    method,
    payload:   payload,
    retries:   retries ?? this.retries,
    createdAt: createdAt,
    localId:   localId,
  );
}

class SyncQueue {
  final LocalStorage _storage;
  static const String _key = AppConstants.keySyncQueue;

  SyncQueue(this._storage);

  List<SyncAction> getAll() {
    final list = _storage.getJsonList(_key);
    if (list == null) return [];
    return list
        .map((e) => SyncAction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(SyncAction action) async {
    final queue = getAll();
    queue.add(action);
    await _save(queue);
  }

  Future<void> remove(String id) async {
    final queue = getAll().where((a) => a.id != id).toList();
    await _save(queue);
  }

  Future<void> incrementRetry(String id) async {
    final queue = getAll().map((a) {
      if (a.id == id) return a.copyWith(retries: a.retries + 1);
      return a;
    }).toList();
    await _save(queue);
  }

  Future<void> clear() async => _storage.remove(_key);

  int get pendingCount => getAll().length;

  Future<void> _save(List<SyncAction> queue) async =>
      _storage.setJsonList(_key, queue.map((a) => a.toJson()).toList());
}
```

---

### `lib/core/offline/cache_manager.dart`

```dart
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
```

---

### `lib/core/offline/offline_manager.dart`

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../constants/app_constants.dart';
import 'sync_queue.dart';
import 'connectivity_service.dart';
import 'cache_manager.dart';
import 'package:dio/dio.dart';

final offlineManagerProvider = Provider<OfflineManager>((ref) {
  return OfflineManager(
    ref.read(apiClientProvider),
    ref.read(syncQueueProvider),
    ref.read(cacheManagerProvider),
    ConnectivityService(),
  );
});

class OfflineManager {
  final ApiClient          _api;
  final SyncQueue          _queue;
  final CacheManager       _cache;
  final ConnectivityService _connectivity;
  Timer? _syncTimer;
  bool   _isSyncing = false;

  OfflineManager(
    this._api,
    this._queue,
    this._cache,
    this._connectivity,
  );

  void initialize() {
    // Écouter les changements de connectivité
    _connectivity.onStatusChange.listen((online) {
      if (online) _triggerSync();
    });

    // Sync périodique si en ligne
    _syncTimer = Timer.periodic(AppConstants.syncInterval, (_) {
      if (_connectivity.isOnline) _triggerSync();
    });
  }

  void dispose() => _syncTimer?.cancel();

  // ── Exécuter une action (online ou offline) ────────────────────

  /// Execute immédiatement si online, sinon met en queue
  Future<OfflineResult> execute(SyncAction action) async {
    if (_connectivity.isOnline) {
      try {
        final response = await _executeAction(action);
        return OfflineResult.success(response.data);
      } catch (e) {
        // En cas d'erreur réseau, mettre en queue
        if (_isNetworkError(e)) {
          await _queue.add(action);
          return OfflineResult.queued(action.id);
        }
        return OfflineResult.error(e.toString());
      }
    } else {
      await _queue.add(action);
      return OfflineResult.queued(action.id);
    }
  }

  // ── Synchronisation ────────────────────────────────────────────

  Future<SyncResult> syncAll() async {
    if (!_connectivity.isOnline || _isSyncing) {
      return SyncResult(synced: 0, failed: 0, pending: _queue.pendingCount);
    }

    _isSyncing = true;
    int synced = 0;
    int failed = 0;

    final actions = _queue.getAll();

    for (final action in actions) {
      if (action.retries >= AppConstants.maxSyncRetries) {
        await _queue.remove(action.id);
        failed++;
        continue;
      }

      try {
        await _executeAction(action);
        await _queue.remove(action.id);
        synced++;
      } catch (e) {
        if (_isNetworkError(e)) {
          // Remettre en queue avec retry++
          await _queue.incrementRetry(action.id);
          break; // Arrêter si problème réseau
        } else {
          // Erreur métier (ex: stock épuisé) → supprimer de la queue
          await _queue.remove(action.id);
          failed++;
        }
      }
    }

    _isSyncing = false;

    return SyncResult(
      synced:  synced,
      failed:  failed,
      pending: _queue.pendingCount,
    );
  }

  void _triggerSync() {
    if (!_isSyncing) syncAll();
  }

  Future<Response> _executeAction(SyncAction action) async {
    switch (action.method.toUpperCase()) {
      case 'POST':
        return _api.post(action.endpoint, data: action.payload);
      case 'PATCH':
        return _api.patch(action.endpoint, data: action.payload);
      case 'DELETE':
        return _api.delete(action.endpoint);
      default:
        throw Exception('Méthode inconnue : ${action.method}');
    }
  }

  bool _isNetworkError(dynamic e) =>
      e is DioException &&
      (e.type == DioExceptionType.connectionTimeout ||
       e.type == DioExceptionType.receiveTimeout    ||
       e.type == DioExceptionType.connectionError);

  int get pendingCount => _queue.pendingCount;

  CacheManager get cache => _cache;
}

// ── Résultats ──────────────────────────────────────────────────

class OfflineResult {
  final bool    isSuccess;
  final bool    isQueued;
  final dynamic data;
  final String? error;
  final String? queueId;

  const OfflineResult._({
    required this.isSuccess,
    required this.isQueued,
    this.data,
    this.error,
    this.queueId,
  });

  factory OfflineResult.success(dynamic data) => OfflineResult._(
    isSuccess: true, isQueued: false, data: data,
  );

  factory OfflineResult.queued(String queueId) => OfflineResult._(
    isSuccess: true, isQueued: true, queueId: queueId,
  );

  factory OfflineResult.error(String error) => OfflineResult._(
    isSuccess: false, isQueued: false, error: error,
  );
}

class SyncResult {
  final int synced;
  final int failed;
  final int pending;
  SyncResult({required this.synced, required this.failed, required this.pending});
}
```

---

## ÉTAPE 8 — Providers Auth

### `lib/providers/auth_provider.dart`

```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import '../core/offline/cache_manager.dart';
import '../models/user.dart';

// État d'authentification
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User?      user;
  final String?    error;
  final bool       isLoading;

  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User?       user,
    String?     error,
    bool?       isLoading,
  }) => AuthState(
    status:    status    ?? this.status,
    user:      user      ?? this.user,
    error:     error,
    isLoading: isLoading ?? this.isLoading,
  );
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(apiClientProvider),
    ref.read(secureStorageProvider),
    ref.read(cacheManagerProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient      _api;
  final SecureStorage  _storage;
  final CacheManager   _cache;

  AuthNotifier(this._api, this._storage, this._cache)
      : super(const AuthState(status: AuthStatus.unknown)) {
    _checkAuth();
  }

  // Vérifier si l'utilisateur est déjà connecté au démarrage
  Future<void> _checkAuth() async {
    final isLogged = await _storage.isLoggedIn();
    if (!isLogged) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    // Charger le profil depuis le cache
    final cachedUser = _cache.getUser();
    if (cachedUser != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user:   User.fromJson(cachedUser),
      );
    }

    // Rafraîchir depuis l'API si en ligne
    try {
      final response = await _api.get(AppEndpoints.me);
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final user = User.fromJson(
          data['data'] as Map<String, dynamic>
        );
        await _cache.saveUser(data['data'] as Map<String, dynamic>);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user:   user,
        );
      }
    } catch (_) {
      // Pas de réseau → utiliser le cache
      if (cachedUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(
        AppEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final d = data['data'] as Map<String, dynamic>;
        await _storage.saveAccessToken(d['access']  as String);
        await _storage.saveRefreshToken(d['refresh'] as String);

        final user = User.fromJson(d['user'] as Map<String, dynamic>);
        await _storage.saveUserRole(user.role);
        await _storage.saveUserId(user.id);
        await _cache.saveUser(d['user'] as Map<String, dynamic>);

        state = state.copyWith(
          status:    AuthStatus.authenticated,
          user:      user,
          isLoading: false,
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error:     data['error']?.toString() ?? 'Erreur de connexion',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     'Vérifiez votre connexion internet.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String lastName,
    String telephone = '',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(
        AppEndpoints.register,
        data: {
          'username':   username,
          'email':      email,
          'password':   password,
          'role':       role,
          'first_name': firstName,
          'last_name':  lastName,
          'telephone':  telephone,
        },
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final d    = data['data'] as Map<String, dynamic>;
        await _storage.saveAccessToken(d['access']  as String);
        await _storage.saveRefreshToken(d['refresh'] as String);

        final user = User.fromJson(d['user'] as Map<String, dynamic>);
        await _storage.saveUserRole(user.role);
        await _storage.saveUserId(user.id);
        await _cache.saveUser(d['user'] as Map<String, dynamic>);

        state = state.copyWith(
          status:    AuthStatus.authenticated,
          user:      user,
          isLoading: false,
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error:     data['error']?.toString(),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final refresh = await _storage.getRefreshToken();
    try {
      await _api.post(AppEndpoints.logout, data: {'refresh': refresh});
    } catch (_) {}
    await _storage.clearAll();
    await _cache.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  bool get isProducteurEnAttente =>
      state.user?.role == 'producteur' &&
      state.user?.profilProducteurStatut == 'en_attente';
}
```

---

## ÉTAPE 9 — Navigation (go_router)

### `lib/router/app_router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/pending_validation_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final status  = authState.status;
      final path    = state.matchedLocation;
      final isAuth  = ['/login', '/register', '/splash'].contains(path);

      if (status == AuthStatus.unknown) {
        return path == '/splash' ? null : '/splash';
      }

      if (status == AuthStatus.unauthenticated) {
        return isAuth ? null : '/login';
      }

      // Connecté
      if (isAuth) {
        // Rediriger selon le rôle
        return _homeRouteForRole(authState.user?.role ?? 'acheteur');
      }

      // Producteur en attente → écran dédié
      final notifier = ref.read(authProvider.notifier);
      if (notifier.isProducteurEnAttente &&
          path != '/producteur/en-attente') {
        return '/producteur/en-attente';
      }

      return null;
    },
    routes: [
      GoRoute(
        path:    '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path:    '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path:    '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path:    '/producteur/en-attente',
        builder: (_, __) => const PendingValidationScreen(),
      ),

      // ── Acheteur ──────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => AcheteurShell(child: child),
        routes: [
          GoRoute(path: '/acheteur/accueil',    builder: (_, __) => const Placeholder()),
          GoRoute(path: '/acheteur/catalogue',  builder: (_, __) => const Placeholder()),
          GoRoute(path: '/acheteur/panier',     builder: (_, __) => const Placeholder()),
          GoRoute(path: '/acheteur/commandes',  builder: (_, __) => const Placeholder()),
          GoRoute(path: '/acheteur/profil',     builder: (_, __) => const Placeholder()),
        ],
      ),

      // ── Producteur ────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => ProducteurShell(child: child),
        routes: [
          GoRoute(path: '/producteur/dashboard', builder: (_, __) => const Placeholder()),
          GoRoute(path: '/producteur/commandes', builder: (_, __) => const Placeholder()),
          GoRoute(path: '/producteur/catalogue', builder: (_, __) => const Placeholder()),
          GoRoute(path: '/producteur/collectes', builder: (_, __) => const Placeholder()),
          GoRoute(path: '/producteur/profil',    builder: (_, __) => const Placeholder()),
        ],
      ),

      // ── Collecteur ────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => CollecteurShell(child: child),
        routes: [
          GoRoute(path: '/collecteur/collectes', builder: (_, __) => const Placeholder()),
          GoRoute(path: '/collecteur/profil',    builder: (_, __) => const Placeholder()),
        ],
      ),

      // ── Admin ─────────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin/dashboard',   builder: (_, __) => const Placeholder()),
          GoRoute(path: '/admin/producteurs', builder: (_, __) => const Placeholder()),
          GoRoute(path: '/admin/commandes',   builder: (_, __) => const Placeholder()),
          GoRoute(path: '/admin/paiements',   builder: (_, __) => const Placeholder()),
          GoRoute(path: '/admin/catalogue',   builder: (_, __) => const Placeholder()),
          GoRoute(path: '/admin/stocks',      builder: (_, __) => const Placeholder()),
          GoRoute(path: '/admin/collectes',   builder: (_, __) => const Placeholder()),
          GoRoute(path: '/admin/utilisateurs', builder: (_, __) => const Placeholder()),
        ],
      ),
    ],
  );
});

String _homeRouteForRole(String role) {
  switch (role) {
    case 'producteur':  return '/producteur/dashboard';
    case 'collecteur':  return '/collecteur/collectes';
    case 'superadmin':
    case 'admin':       return '/admin/dashboard';
    default:            return '/acheteur/accueil';
  }
}

// ── Shells (BottomNavigation par rôle) ────────────────────────

class AcheteurShell extends ConsumerWidget {
  final Widget child;
  const AcheteurShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNav(context, [
        const _NavItem(icon: Icons.home_outlined,      label: 'Accueil',   route: '/acheteur/accueil'),
        const _NavItem(icon: Icons.store_outlined,     label: 'Catalogue', route: '/acheteur/catalogue'),
        const _NavItem(icon: Icons.shopping_cart_outlined, label: 'Panier',route: '/acheteur/panier'),
        const _NavItem(icon: Icons.receipt_outlined,   label: 'Commandes', route: '/acheteur/commandes'),
        const _NavItem(icon: Icons.person_outline,     label: 'Profil',    route: '/acheteur/profil'),
      ]),
    );
  }
}

class ProducteurShell extends ConsumerWidget {
  final Widget child;
  const ProducteurShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNav(context, [
        const _NavItem(icon: Icons.dashboard_outlined,  label: 'Dashboard',  route: '/producteur/dashboard'),
        const _NavItem(icon: Icons.receipt_outlined,    label: 'Commandes',  route: '/producteur/commandes'),
        const _NavItem(icon: Icons.inventory_outlined,  label: 'Catalogue',  route: '/producteur/catalogue'),
        const _NavItem(icon: Icons.local_shipping_outlined, label: 'Collectes', route: '/producteur/collectes'),
        const _NavItem(icon: Icons.person_outline,      label: 'Profil',     route: '/producteur/profil'),
      ]),
    );
  }
}

class CollecteurShell extends ConsumerWidget {
  final Widget child;
  const CollecteurShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNav(context, [
        const _NavItem(icon: Icons.local_shipping_outlined, label: 'Collectes', route: '/collecteur/collectes'),
        const _NavItem(icon: Icons.person_outline,          label: 'Profil',    route: '/collecteur/profil'),
      ]),
    );
  }
}

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Makèt Peyizan Admin')),
      drawer: _buildAdminDrawer(context),
      body: child,
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1A6B2F)),
            child: Text('Admin', style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          for (final item in [
            const _NavItem(icon: Icons.bar_chart, label: 'Dashboard', route: '/admin/dashboard'),
            const _NavItem(icon: Icons.people,    label: 'Producteurs', route: '/admin/producteurs'),
            const _NavItem(icon: Icons.receipt,   label: 'Commandes', route: '/admin/commandes'),
            const _NavItem(icon: Icons.payment,   label: 'Paiements', route: '/admin/paiements'),
            const _NavItem(icon: Icons.inventory, label: 'Catalogue', route: '/admin/catalogue'),
            const _NavItem(icon: Icons.warehouse, label: 'Stocks', route: '/admin/stocks'),
            const _NavItem(icon: Icons.local_shipping, label: 'Collectes', route: '/admin/collectes'),
            const _NavItem(icon: Icons.manage_accounts, label: 'Utilisateurs', route: '/admin/utilisateurs'),
          ])
            ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              onTap: () {
                Navigator.pop(context);
                context.go(item.route);
              },
            ),
        ],
      ),
    );
  }
}

// Helper navigation
Widget _buildBottomNav(BuildContext context, List<_NavItem> items) {
  final location = GoRouterState.of(context).matchedLocation;
  final currentIndex = items.indexWhere(
    (i) => location.startsWith(i.route),
  ).clamp(0, items.length - 1);

  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: (i) => context.go(items[i].route),
    items: items.map((i) => BottomNavigationBarItem(
      icon:  Icon(i.icon),
      label: i.label,
    )).toList(),
  );
}

class _NavItem {
  final IconData icon;
  final String   label;
  final String   route;
  const _NavItem({required this.icon, required this.label, required this.route});
}
```

---

## ÉTAPE 10 — Écrans Auth

### `lib/features/auth/screens/splash_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../router/app_router.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>    _fadeAnim;
  late Animation<double>    _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // go_router gère la redirection automatiquement
    return Scaffold(
      backgroundColor: AppColors.vertFonce,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width:  100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.jaune,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    size:  60,
                    color: AppColors.vertFonce,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Makèt Peyizan',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize:   32,
                    fontWeight: FontWeight.w900,
                    color:      AppColors.blanc,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sòti nan jaden rive lakay',
                  style: TextStyle(
                    fontSize: 14,
                    color:    AppColors.blanc.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  color: AppColors.jaune,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### `lib/features/auth/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(authProvider).error ?? 'Erreur de connexion'
          ),
          backgroundColor: AppColors.rouge,
        ),
      );
    }
    // La redirection est gérée par go_router
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo + Titre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width:  80,
                        height: 80,
                        decoration: BoxDecoration(
                          color:        AppColors.vertFonce,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          size:  48,
                          color: AppColors.jaune,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Makèt Peyizan',
                        style: TextStyle(
                          fontFamily:  'PlayfairDisplay',
                          fontSize:    28,
                          fontWeight:  FontWeight.w900,
                          color:       AppColors.vertFonce,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Titre section
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize:   22,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.noir,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(
                    fontSize: 14,
                    color:    AppColors.grisTexte,
                  ),
                ),
                const SizedBox(height: 28),

                // Email
                TextFormField(
                  controller:  _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText:   'Email',
                    prefixIcon:  Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v?.isEmpty == true
                      ? 'Email requis' : null,
                ),
                const SizedBox(height: 16),

                // Mot de passe
                TextFormField(
                  controller:  _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText:   'Mot de passe',
                    prefixIcon:  const Icon(Icons.lock_outline),
                    suffixIcon:  IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v?.isEmpty == true
                      ? 'Mot de passe requis' : null,
                ),
                const SizedBox(height: 28),

                // Bouton connexion
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width:  20,
                          child:  CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Se connecter'),
                ),
                const SizedBox(height: 16),

                // Lien inscription
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text(
                      'Pas de compte ? S\'inscrire',
                      style: TextStyle(color: AppColors.vertVif),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### `lib/features/auth/screens/register_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _usernameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _telCtrl       = TextEditingController();
  String _role         = 'acheteur';
  bool   _obscure      = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).register(
      username:   _usernameCtrl.text.trim(),
      email:      _emailCtrl.text.trim(),
      password:   _passwordCtrl.text,
      role:       _role,
      firstName:  _firstNameCtrl.text.trim(),
      lastName:   _lastNameCtrl.text.trim(),
      telephone:  _telCtrl.text.trim(),
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(authProvider).error ?? 'Erreur d\'inscription'
          ),
          backgroundColor: AppColors.rouge,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: AppColors.vertFonce,
        foregroundColor: AppColors.blanc,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sélecteur de rôle
                const Text(
                  'Je suis...',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _RoleChip(
                      label:     '🛒 Acheteur',
                      value:     'acheteur',
                      selected:  _role == 'acheteur',
                      onTap:     () => setState(() => _role = 'acheteur'),
                    ),
                    const SizedBox(width: 12),
                    _RoleChip(
                      label:     '🌾 Producteur',
                      value:     'producteur',
                      selected:  _role == 'producteur',
                      onTap:     () => setState(() => _role = 'producteur'),
                    ),
                  ],
                ),

                if (_role == 'producteur')
                  Container(
                    margin:  const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:        AppColors.jauneClair,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.jaune),
                    ),
                    child: const Text(
                      '⚠️ Votre compte producteur sera en attente de validation par notre équipe.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),

                const SizedBox(height: 24),

                // Champs
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText:  'Nom d\'utilisateur',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText:  'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v?.contains('@') == false
                      ? 'Email invalide' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller:   _telCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText:  'Téléphone (+509...)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller:  _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText:  'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) < 8
                      ? 'Min. 8 caractères' : null,
                ),
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  child: isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2,
                          ),
                        )
                      : const Text('S\'inscrire'),
                ),

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Déjà un compte ? Se connecter',
                      style: TextStyle(color: AppColors.vertVif),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String  label;
  final String  value;
  final bool    selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:        selected ? AppColors.vertFonce : AppColors.blanc,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(
            color: selected ? AppColors.vertFonce : const Color(0xFFDDDDDD),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:      selected ? AppColors.blanc : AppColors.noir,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
```

---

### `lib/features/auth/screens/pending_validation_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

class PendingValidationScreen extends ConsumerWidget {
  const PendingValidationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.vertMenthe,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                size:  80,
                color: AppColors.vertFonce,
              ),
              const SizedBox(height: 24),
              Text(
                'Bonjour ${user?.firstName ?? ''} !',
                style: const TextStyle(
                  fontFamily:  'PlayfairDisplay',
                  fontSize:    28,
                  fontWeight:  FontWeight.w900,
                  color:       AppColors.vertFonce,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Votre compte producteur est en attente de validation.',
                style: TextStyle(fontSize: 16, color: AppColors.grisTexte),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Notre équipe va examiner votre profil et vous enverrez une notification dès l\'approbation.',
                style: TextStyle(fontSize: 14, color: AppColors.grisTexte),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                icon:     const Icon(Icons.refresh),
                label:    const Text('Vérifier le statut'),
                onPressed: () =>
                    ref.read(authProvider.notifier)._checkAuth(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.vertFonce,
                  side: const BorderSide(color: AppColors.vertFonce),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.read(authProvider.notifier).logout(),
                child: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: AppColors.rouge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## ÉTAPE 11 — `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/offline/connectivity_service.dart';
import 'core/offline/offline_manager.dart';
import 'core/storage/local_storage.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await Hive.initFlutter();

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Firebase (commenté si google-services.json absent)
  // await Firebase.initializeApp();

  // Connectivité
  await ConnectivityService().initialize();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(LocalStorage(prefs)),
      ],
      child: const MaketPeyizanApp(),
    ),
  );
}
```

---

## ÉTAPE 12 — `lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

class MaketPeyizanApp extends ConsumerWidget {
  const MaketPeyizanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title:           'Makèt Peyizan',
      theme:           AppTheme.lightTheme,
      routerConfig:    router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('ht'),     // Haïtien créole
      ],
      locale: const Locale('fr', 'FR'),
    );
  }
}
```

---

## ÉTAPE 13 — Utilitaires

### `lib/core/utils/image_utils.dart`

```dart
import '../constants/app_constants.dart';

class ImageUtils {
  /// Construit l'URL absolue d'une image servie par le backend.
  static String imageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http')) return relativePath;
    return '${AppConstants.baseUrl}$relativePath';
  }

  /// Placeholder local selon le type de contenu
  static String placeholder(String type) {
    switch (type) {
      case 'produit':     return 'assets/images/placeholder_produit.png';
      case 'producteur':  return 'assets/images/placeholder_user.png';
      default:            return 'assets/images/placeholder.png';
    }
  }
}
```

---

### `lib/core/utils/format_utils.dart`

```dart
import 'package:intl/intl.dart';

class FormatUtils {
  static final _htgFormatter = NumberFormat.currency(
    locale: 'fr_HT',
    symbol: 'HTG ',
    decimalDigits: 2,
  );

  static String htg(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0;
    return _htgFormatter.format(value);
  }

  static String date(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy', 'fr_FR').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String dateHeure(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}
```

---

## ÉTAPE 14 — Widget indicateur offline

### `lib/core/offline/offline_banner.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'connectivity_service.dart';
import 'sync_queue.dart';

/// Bannière à afficher en haut des écrans quand offline
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline     = ref.watch(isOnlineProvider);
    final syncQueue    = ref.read(syncQueueProvider);
    final pendingCount = syncQueue.pendingCount;

    if (isOnline) {
      // Si en ligne mais actions en attente → bannière verte
      if (pendingCount > 0) {
        return Container(
          color:   AppColors.vertVif,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.sync, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Synchronisation de $pendingCount action(s)...',
                style: const TextStyle(
                  color: Colors.white, fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // Hors ligne
    return Container(
      color:   AppColors.orange,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pendingCount > 0
                  ? 'Hors ligne — $pendingCount action(s) en attente de sync'
                  : 'Hors ligne — Mode lecture seule',
              style: const TextStyle(
                color: Colors.white, fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ÉTAPE 15 — Commandes finales

```bash
# 1. Créer le projet Flutter
flutter create maket_peyizan --org ht.maketpeyizan

# 2. Remplacer le contenu par les fichiers ci-dessus

# 3. Créer les dossiers assets
mkdir -p assets/images assets/icons assets/animations assets/fonts

# 4. Télécharger les fonts
# PlayfairDisplay et DMSans depuis Google Fonts

# 5. Créer les placeholders d'assets
touch assets/images/placeholder.png
touch assets/images/placeholder_produit.png
touch assets/images/placeholder_user.png

# 6. Installer les dépendances
flutter pub get

# 7. Générer les fichiers Freezed + JSON
flutter pub run build_runner build --delete-conflicting-outputs

# 8. Vérifier
flutter analyze
flutter run
```

---

## RÉSUMÉ — Ce que ce prompt met en place

| Composant | Détail |
|---|---|
| **Structure** | Architecture feature-first complète |
| **Thème** | Palette officielle Makèt Peyizan + fonts PlayfairDisplay/DMSans |
| **API Client** | Dio + intercepteur JWT auto-refresh |
| **Offline Engine** | ConnectivityService + SyncQueue + CacheManager + OfflineManager |
| **Sync différée** | Queue persistante Hive, retry automatique à la reconnexion |
| **Auth** | Riverpod StateNotifier + login/register/logout + cache user |
| **Navigation** | go_router + 4 shells (Acheteur, Producteur, Collecteur, Admin) |
| **Écrans auth** | Splash, Login, Register, PendingValidation |
| **Indicateur offline** | Bannière orange/verte selon l'état réseau |
| **Utilitaires** | imageUrl(), FormatUtils.htg(), dates |

**Prochaine étape → Prompt 2 : App Acheteur**
(Catalogue, Recherche, Panier, Commander, Paiements, Profil)
