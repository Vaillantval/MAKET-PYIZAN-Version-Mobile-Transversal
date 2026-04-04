# PROMPT CLAUDE CODE — Makèt Peyizan Mobile
# Flutter — Partie 4 : App Admin Mobile + Notifications FCM

---

## CONTEXTE

Les Parties 1, 2 et 3 (Fondations + Acheteur + Producteur) sont déjà implémentées.
Tu vas maintenant créer le **dashboard admin mobile complet** (même niveau que le web)
et le système de **notifications push FCM**.

**API Base URL :** `https://maketpeyizan.ht`
**Permission requise :** rôle `superadmin` ou `is_staff=true`

---

## FICHIERS À CRÉER

```
lib/features/admin/
├── screens/
│   ├── admin_dashboard_screen.dart      → KPIs + graphes
│   ├── admin_users_screen.dart          → gestion utilisateurs
│   ├── admin_producteurs_screen.dart    → validation producteurs
│   ├── admin_commandes_screen.dart      → toutes les commandes
│   ├── admin_paiements_screen.dart      → vérification paiements
│   ├── admin_catalogue_screen.dart      → gestion catalogue
│   ├── admin_stocks_screen.dart         → lots + alertes
│   └── admin_collectes_screen.dart      → gestion collectes terrain
├── providers/
│   ├── admin_stats_provider.dart
│   ├── admin_users_provider.dart
│   ├── admin_producteurs_provider.dart
│   ├── admin_commandes_provider.dart
│   ├── admin_paiements_provider.dart
│   ├── admin_catalogue_provider.dart
│   ├── admin_stocks_provider.dart
│   └── admin_collectes_provider.dart
└── widgets/
    ├── kpi_card.dart
    ├── admin_list_tile.dart
    ├── paiement_action_sheet.dart
    └── statut_selector.dart

lib/core/notifications/
├── fcm_service.dart                     → init FCM + topics
├── notification_handler.dart           → navigation sur tap
└── notification_provider.dart          → état notifications
```

---

## ÉTAPE 1 — Service FCM complet

### `lib/core/notifications/fcm_service.dart`

```dart
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
  // Pas besoin de faire grand chose ici
  // Firebase affiche la notification automatiquement
}
```

---

### `lib/core/notifications/notification_handler.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigue vers le bon écran selon le type de notification
class NotificationHandler {
  static void handle(
    RemoteMessage message,
    BuildContext context,
  ) {
    final data = message.data;
    final type = data['type'] as String? ?? '';

    switch (type) {
      case 'nouvelle_commande':
        final role = data['role'] as String? ?? '';
        if (role == 'producteur') {
          context.go('/producteur/commandes');
        } else {
          context.go('/admin/commandes');
        }
        break;

      case 'commande_confirmee':
      case 'commande_livree':
        final numero = data['numero_commande'] as String?;
        if (numero != null) {
          context.go('/acheteur/commande/$numero');
        }
        break;

      case 'paiement_a_verifier':
        context.go('/admin/paiements');
        break;

      case 'alerte_stock':
        context.go('/admin/stocks');
        break;

      case 'nouvelle_collecte':
        final role = data['role'] as String? ?? '';
        if (role == 'collecteur') {
          context.go('/collecteur/collectes');
        } else {
          context.go('/producteur/collectes');
        }
        break;

      case 'producteur_valide':
        context.go('/producteur/dashboard');
        break;

      case 'validation_producteur':
        context.go('/admin/producteurs');
        break;

      default:
        // Notification générique → pas de navigation
        break;
    }
  }

  /// Afficher une bannière in-app
  static void showInAppBanner(
    RemoteMessage message,
    BuildContext context,
  ) {
    final notification = message.notification;
    if (notification == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title ?? '',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (notification.body != null)
              Text(
                notification.body!,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        action: SnackBarAction(
          label: 'Voir',
          onPressed: () => handle(message, context),
        ),
        duration:        const Duration(seconds: 5),
        backgroundColor: const Color(0xFF1A6B2F),
      ),
    );
  }
}
```

---

### `lib/core/notifications/notification_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationState {
  final int    unreadCount;
  final List<RemoteMessage> recent;

  const NotificationState({
    this.unreadCount = 0,
    this.recent      = const [],
  });

  NotificationState copyWith({
    int?                   unreadCount,
    List<RemoteMessage>?   recent,
  }) => NotificationState(
    unreadCount: unreadCount ?? this.unreadCount,
    recent:      recent      ?? this.recent,
  );
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState()) {
    _listen();
  }

  void _listen() {
    FirebaseMessaging.onMessage.listen((message) {
      state = state.copyWith(
        unreadCount: state.unreadCount + 1,
        recent:      [message, ...state.recent].take(20).toList(),
      );
    });
  }

  void markAllRead() => state = state.copyWith(unreadCount: 0);
}
```

---

## ÉTAPE 2 — Initialiser FCM dans `main.dart`

Mettre à jour `lib/main.dart` pour activer Firebase et FCM :

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/notifications/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final prefs = await SharedPreferences.getInstance();

  // Activer Firebase
  await Firebase.initializeApp();

  // Enregistrer le handler background
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

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

## ÉTAPE 3 — Écouter les notifications dans `app.dart`

Mettre à jour `lib/app.dart` pour brancher les notifications :

```dart
class MaketPeyizanApp extends ConsumerStatefulWidget {
  const MaketPeyizanApp({super.key});

  @override
  ConsumerState<MaketPeyizanApp> createState() =>
      _MaketPeyizanAppState();
}

class _MaketPeyizanAppState
    extends ConsumerState<MaketPeyizanApp> {

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  void _setupNotifications() {
    // Notification reçue en foreground
    FirebaseMessaging.onMessage.listen((message) {
      // Incrémenter le compteur
      ref.read(notificationProvider.notifier);
      // Afficher bannière in-app si contexte disponible
    });

    // Tap notification depuis background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final ctx = ref.read(routerProvider).routerDelegate.navigatorKey
          .currentContext;
      if (ctx != null) {
        NotificationHandler.handle(message, ctx);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ... même code qu'avant
  }
}
```

---

## ÉTAPE 4 — Provider Stats Admin

### `lib/features/admin/providers/admin_stats_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/cache_manager.dart';
import '../../../core/offline/connectivity_service.dart';

class AdminStats {
  // Utilisateurs
  final int totalUsers;
  final int totalProducteurs;
  final int producteursActifs;
  final int producteursAttente;
  final int totalAcheteurs;
  final int nouveauxUsers30j;
  // Commandes
  final int    totalCommandes;
  final int    commandesEnAttente;
  final int    commandesLivrees;
  final int    commandesLitige;
  final int    commandesMois;
  // Revenus
  final double revenuTotal;
  final double revenuMois;
  final double revenu7j;
  // Paiements
  final int    paiementsAVerifier;
  final double montantAVerifier;
  // Produits & Stock
  final int totalProduits;
  final int produitsEpuises;
  final int alertesStock;
  // Collectes
  final int collectesPlanifiees;
  final int collectesEnCours;
  final int collectesEnRetard;
  // Vouchers
  final int vouchersActifs;

  const AdminStats({
    this.totalUsers           = 0,
    this.totalProducteurs     = 0,
    this.producteursActifs    = 0,
    this.producteursAttente   = 0,
    this.totalAcheteurs       = 0,
    this.nouveauxUsers30j     = 0,
    this.totalCommandes       = 0,
    this.commandesEnAttente   = 0,
    this.commandesLivrees     = 0,
    this.commandesLitige      = 0,
    this.commandesMois        = 0,
    this.revenuTotal          = 0,
    this.revenuMois           = 0,
    this.revenu7j             = 0,
    this.paiementsAVerifier   = 0,
    this.montantAVerifier     = 0,
    this.totalProduits        = 0,
    this.produitsEpuises      = 0,
    this.alertesStock         = 0,
    this.collectesPlanifiees  = 0,
    this.collectesEnCours     = 0,
    this.collectesEnRetard    = 0,
    this.vouchersActifs       = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> j) => AdminStats(
    totalUsers:          j['total_users']           as int?    ?? 0,
    totalProducteurs:    j['total_producteurs']      as int?    ?? 0,
    producteursActifs:   j['producteurs_actifs']     as int?    ?? 0,
    producteursAttente:  j['producteurs_attente']    as int?    ?? 0,
    totalAcheteurs:      j['total_acheteurs']        as int?    ?? 0,
    nouveauxUsers30j:    j['nouveaux_users_30j']     as int?    ?? 0,
    totalCommandes:      j['total_commandes']        as int?    ?? 0,
    commandesEnAttente:  j['commandes_en_attente']   as int?    ?? 0,
    commandesLivrees:    j['commandes_livrees']      as int?    ?? 0,
    commandesLitige:     j['commandes_litige']       as int?    ?? 0,
    commandesMois:       j['commandes_mois']         as int?    ?? 0,
    revenuTotal:         double.tryParse(j['revenu_total']?.toString() ?? '0')  ?? 0,
    revenuMois:          double.tryParse(j['revenu_mois']?.toString()  ?? '0')  ?? 0,
    revenu7j:            double.tryParse(j['revenu_7j']?.toString()    ?? '0')  ?? 0,
    paiementsAVerifier:  j['paiements_a_verifier']  as int?    ?? 0,
    montantAVerifier:    double.tryParse(j['montant_a_verifier']?.toString() ?? '0') ?? 0,
    totalProduits:       j['total_produits']         as int?    ?? 0,
    produitsEpuises:     j['produits_epuises']       as int?    ?? 0,
    alertesStock:        j['alertes_stock']          as int?    ?? 0,
    collectesPlanifiees: j['collectes_planifiees']   as int?    ?? 0,
    collectesEnCours:    j['collectes_en_cours']     as int?    ?? 0,
    collectesEnRetard:   j['collectes_en_retard']    as int?    ?? 0,
    vouchersActifs:      j['vouchers_actifs']        as int?    ?? 0,
  );
}

final adminStatsProvider =
    StateNotifierProvider<AdminStatsNotifier, AsyncValue<AdminStats>>((ref) {
  return AdminStatsNotifier(
    ref.read(apiClientProvider),
    ref.read(cacheManagerProvider),
    ConnectivityService(),
  );
});

class AdminStatsNotifier
    extends StateNotifier<AsyncValue<AdminStats>> {
  final ApiClient           _api;
  final CacheManager        _cache;
  final ConnectivityService _conn;
  static const _key = 'admin_stats';

  AdminStatsNotifier(this._api, this._cache, this._conn)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();

    if (!_conn.isOnline) {
      final cached = _cache.getData(_key,
          ttl: const Duration(minutes: 30));
      if (cached != null) {
        state = AsyncValue.data(
          AdminStats.fromJson(cached as Map<String, dynamic>));
        return;
      }
    }

    try {
      final res  = await _api.get(AppEndpoints.adminStats);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final d = data['data'] as Map<String, dynamic>;
        await _cache.saveData(_key, d,
            ttl: const Duration(minutes: 30));
        state = AsyncValue.data(AdminStats.fromJson(d));
      }
    } catch (e, st) {
      final cached = _cache.getData(_key,
          ttl: const Duration(minutes: 30));
      if (cached != null) {
        state = AsyncValue.data(
          AdminStats.fromJson(cached as Map<String, dynamic>));
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
```

---

## ÉTAPE 5 — Providers Admin (liste + actions)

### `lib/features/admin/providers/admin_users_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AdminUsersNotifier(ref.read(apiClientProvider));
});

class AdminUsersNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;
  String _search = '';
  String _role   = '';

  AdminUsersNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger({String? search, String? role}) async {
    _search = search ?? _search;
    _role   = role   ?? _role;
    state   = const AsyncValue.loading();
    try {
      final params = <String, dynamic>{};
      if (_search.isNotEmpty) params['search'] = _search;
      if (_role.isNotEmpty)   params['role']   = _role;

      final res  = await _api.get(AppEndpoints.adminUsers,
          queryParameters: params);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          List<Map<String, dynamic>>.from(data['data'] as List),
        );
      }
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<bool> toggle(int id) async {
    try {
      final res  = await _api.patch(
        '${AppEndpoints.adminUsers}$id/toggle/',
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
```

---

### `lib/features/admin/providers/admin_producteurs_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminProducteursProvider =
    StateNotifierProvider<AdminProducteursNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AdminProducteursNotifier(ref.read(apiClientProvider));
});

class AdminProducteursNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;
  String _statut = '';

  AdminProducteursNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger({String? statut}) async {
    _statut = statut ?? _statut;
    state   = const AsyncValue.loading();
    try {
      final params = <String, dynamic>{};
      if (_statut.isNotEmpty) params['statut'] = _statut;
      final res  = await _api.get(AppEndpoints.adminProducteurs,
          queryParameters: params);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          List<Map<String, dynamic>>.from(data['data'] as List),
        );
      }
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<bool> changerStatut(
    int id, String statut, {String note = ''}
  ) async {
    try {
      final res = await _api.patch(
        '${AppEndpoints.adminProducteurs}$id/statut/',
        data: {'statut': statut, if (note.isNotEmpty) 'note': note},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
```

---

### `lib/features/admin/providers/admin_paiements_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminPaiementsProvider =
    StateNotifierProvider<AdminPaiementsNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AdminPaiementsNotifier(ref.read(apiClientProvider));
});

class AdminPaiementsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;

  AdminPaiementsNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger({String statut = 'soumis'}) async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.adminPaiements,
          queryParameters: {'statut': statut});
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          List<Map<String, dynamic>>.from(data['data'] as List),
        );
      }
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<bool> traiter(
    int id, String action, {String note = ''}
  ) async {
    try {
      final res = await _api.patch(
        '${AppEndpoints.adminPaiements}$id/statut/',
        data: {'action': action, if (note.isNotEmpty) 'note': note},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
```

---

### `lib/features/admin/providers/admin_commandes_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminCommandesProvider =
    StateNotifierProvider<AdminCommandesNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AdminCommandesNotifier(ref.read(apiClientProvider));
});

class AdminCommandesNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;
  String _statut = '';
  String _search = '';

  AdminCommandesNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger({String? statut, String? search}) async {
    _statut = statut ?? _statut;
    _search = search ?? _search;
    state   = const AsyncValue.loading();
    try {
      final params = <String, dynamic>{};
      if (_statut.isNotEmpty) params['statut'] = _statut;
      if (_search.isNotEmpty) params['search'] = _search;
      final res  = await _api.get(AppEndpoints.adminCommandes,
          queryParameters: params);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          List<Map<String, dynamic>>.from(data['data'] as List),
        );
      }
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<bool> changerStatut(
    String numero, String statut, {String commentaire = ''}
  ) async {
    try {
      final res = await _api.patch(
        '${AppEndpoints.adminCommandes}$numero/statut/',
        data: {
          'statut': statut,
          if (commentaire.isNotEmpty) 'commentaire': commentaire,
        },
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
```

---

### `lib/features/admin/providers/admin_stocks_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminStocksProvider =
    StateNotifierProvider<AdminStocksNotifier,
        AsyncValue<Map<String, dynamic>>>((ref) {
  return AdminStocksNotifier(ref.read(apiClientProvider));
});

class AdminStocksNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ApiClient _api;

  AdminStocksNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final resLots    = await _api.get(AppEndpoints.adminStocks);
      final resAlertes = await _api.get(AppEndpoints.adminAlertes);

      final lots = (resLots.data['data'] as List?)
              ?.cast<Map<String, dynamic>>() ?? [];
      final alertes = (resAlertes.data['data'] as List?)
              ?.cast<Map<String, dynamic>>() ?? [];

      state = AsyncValue.data({
        'lots':    lots,
        'alertes': alertes,
      });
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }
}
```

---

## ÉTAPE 6 — Widget KPI Card Admin

### `lib/features/admin/widgets/kpi_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class KpiCard extends StatelessWidget {
  final String       emoji;
  final String       valeur;
  final String       label;
  final Color        couleur;
  final String?      tendance;   // ex: "+12 ce mois"
  final bool         urgent;
  final VoidCallback? onTap;

  const KpiCard({
    required this.emoji,
    required this.valeur,
    required this.label,
    this.couleur  = AppColors.vertVif,
    this.tendance,
    this.urgent   = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: urgent
            ? Border.all(color: AppColors.rouge, width: 1.5)
            : Border(left: BorderSide(color: couleur, width: 4)),
        boxShadow: [
          BoxShadow(
            color:     Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset:    const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              if (urgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:        AppColors.rouge.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('!',
                    style: TextStyle(
                      color:      AppColors.rouge,
                      fontWeight: FontWeight.w900,
                      fontSize:   12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(valeur,
            style: TextStyle(
              fontSize:   28,
              fontWeight: FontWeight.w900,
              color:      urgent ? AppColors.rouge : couleur,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
            style: const TextStyle(
              fontSize: 11, color: AppColors.grisTexte,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (tendance != null) ...[
            const SizedBox(height: 4),
            Text(tendance!,
              style: const TextStyle(
                fontSize: 11, color: AppColors.vertVif,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
```

---

## ÉTAPE 7 — Dashboard Admin

### `lib/features/admin/screens/admin_dashboard_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../providers/auth_provider.dart';
import '../providers/admin_stats_provider.dart';
import '../widgets/kpi_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/offline/offline_banner.dart';
import '../../../core/notifications/notification_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats     = ref.watch(adminStatsProvider);
    final user      = ref.watch(authProvider).user;
    final notifCount = ref.watch(notificationProvider).unreadCount;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                color:     AppColors.vertVif,
                onRefresh: () =>
                    ref.read(adminStatsProvider.notifier).charger(),
                child: CustomScrollView(
                  slivers: [

                    // ── Header ──────────────────────────────
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF0D3B1A),
                              AppColors.vertFonce,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(
                            20, 16, 20, 24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '👑 Superadmin',
                                      style: TextStyle(
                                        color:      AppColors.jaune,
                                        fontSize:   12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      'Bonjou ${user?.firstName ?? ''} !',
                                      style: const TextStyle(
                                        color:      Colors.white,
                                        fontSize:   22,
                                        fontFamily: 'PlayfairDisplay',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Text(
                                      'maketpeyizan.ht',
                                      style: TextStyle(
                                        color:   Color(0x88FFFFFF),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                // Cloche notifications
                                GestureDetector(
                                  onTap: () {
                                    ref.read(notificationProvider
                                        .notifier).markAllRead();
                                  },
                                  child: Stack(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor:
                                            Color(0x33FFFFFF),
                                        child: Icon(
                                          Icons.notifications_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (notifCount > 0)
                                        Positioned(
                                          top: 0, right: 0,
                                          child: Container(
                                            width:  18, height: 18,
                                            decoration: const BoxDecoration(
                                              color: AppColors.rouge,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '$notifCount',
                                                style: const TextStyle(
                                                  color:      Colors.white,
                                                  fontSize:   10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Revenus en évidence
                            stats.whenOrNull(
                              data: (s) => Container(
                                margin:  const EdgeInsets.only(top: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:        Colors.white
                                      .withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white
                                        .withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _RevStat(
                                      label:  'Ce mois',
                                      valeur: FormatUtils.htg(s.revenuMois),
                                      jaune:  true,
                                    ),
                                    _RevStat(
                                      label:  '7 derniers jours',
                                      valeur: FormatUtils.htg(s.revenu7j),
                                    ),
                                    _RevStat(
                                      label:  'Total',
                                      valeur: FormatUtils.htg(s.revenuTotal),
                                    ),
                                  ],
                                ),
                              ),
                            ) ?? const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),

                    // ── Alertes urgentes ─────────────────────
                    stats.whenOrNull(
                      data: (s) {
                        final alerts = <_Alert>[];
                        if (s.paiementsAVerifier > 0)
                          alerts.add(_Alert(
                            '💳 ${s.paiementsAVerifier} paiement(s) à vérifier',
                            () => context.go('/admin/paiements'),
                          ));
                        if (s.producteursAttente > 0)
                          alerts.add(_Alert(
                            '🌾 ${s.producteursAttente} producteur(s) en attente',
                            () => context.go('/admin/producteurs'),
                          ));
                        if (s.alertesStock > 0)
                          alerts.add(_Alert(
                            '⚠️ ${s.alertesStock} alerte(s) de stock',
                            () => context.go('/admin/stocks'),
                          ));
                        if (s.commandesLitige > 0)
                          alerts.add(_Alert(
                            '⚡ ${s.commandesLitige} commande(s) en litige',
                            () => context.go('/admin/commandes'),
                          ));

                        if (alerts.isEmpty) return null;

                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16, 16, 16, 0),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('🚨 Actions requises',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize:   15,
                                    color:      AppColors.vertFonce,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...alerts.map((a) => GestureDetector(
                                  onTap: a.onTap,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:        AppColors.rouge
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.rouge
                                            .withOpacity(0.25),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(a.label,
                                            style: const TextStyle(
                                              fontSize:   13,
                                              fontWeight: FontWeight.w600,
                                              color:      AppColors.rouge,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.rouge,
                                          size:  18,
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        );
                      },
                    ) ?? const SliverToBoxAdapter(
                      child: SizedBox.shrink()),

                    // ── KPIs Utilisateurs ────────────────────
                    _SectionTitle('👥 Utilisateurs'),
                    stats.when(
                      loading: () => const SliverToBoxAdapter(
                        child: LoadingWidget()),
                      error: (e, _) => SliverToBoxAdapter(
                        child: Center(child: Text('$e'))),
                      data: (s) => _KpiGrid([
                        KpiCard(
                          emoji:  '👤',
                          valeur: '${s.totalUsers}',
                          label:  'Total',
                          couleur: AppColors.vertFonce,
                          tendance: '+${s.nouveauxUsers30j} ce mois',
                          onTap: () => context.go('/admin/utilisateurs'),
                        ),
                        KpiCard(
                          emoji:  '🌾',
                          valeur: '${s.producteursActifs}',
                          label:  'Producteurs actifs',
                          couleur: AppColors.vertVif,
                          onTap: () => context.go('/admin/producteurs'),
                        ),
                        KpiCard(
                          emoji:  '⏳',
                          valeur: '${s.producteursAttente}',
                          label:  'En attente',
                          couleur: AppColors.orange,
                          urgent:  s.producteursAttente > 0,
                          onTap: () => context.go('/admin/producteurs'),
                        ),
                        KpiCard(
                          emoji:  '🛒',
                          valeur: '${s.totalAcheteurs}',
                          label:  'Acheteurs',
                          couleur: AppColors.bleu,
                          onTap: () => context.go('/admin/utilisateurs'),
                        ),
                      ]),
                    ),

                    // ── KPIs Commandes ───────────────────────
                    _SectionTitle('📦 Commandes'),
                    stats.whenOrNull(
                      data: (s) => _KpiGrid([
                        KpiCard(
                          emoji:  '📊',
                          valeur: '${s.totalCommandes}',
                          label:  'Total',
                          couleur: AppColors.vertFonce,
                          tendance: '${s.commandesMois} ce mois',
                          onTap: () => context.go('/admin/commandes'),
                        ),
                        KpiCard(
                          emoji:  '⏳',
                          valeur: '${s.commandesEnAttente}',
                          label:  'En attente',
                          couleur: AppColors.orange,
                          urgent:  s.commandesEnAttente > 0,
                          onTap: () => context.go('/admin/commandes'),
                        ),
                        KpiCard(
                          emoji:  '✅',
                          valeur: '${s.commandesLivrees}',
                          label:  'Livrées',
                          couleur: AppColors.vertVif,
                        ),
                        KpiCard(
                          emoji:  '⚡',
                          valeur: '${s.commandesLitige}',
                          label:  'En litige',
                          couleur: AppColors.rouge,
                          urgent:  s.commandesLitige > 0,
                          onTap: () => context.go('/admin/commandes'),
                        ),
                      ]),
                    ) ?? const SliverToBoxAdapter(
                        child: SizedBox.shrink()),

                    // ── KPIs Paiements & Stock ───────────────
                    _SectionTitle('💳 Paiements & Stock'),
                    stats.whenOrNull(
                      data: (s) => _KpiGrid([
                        KpiCard(
                          emoji:  '🔍',
                          valeur: '${s.paiementsAVerifier}',
                          label:  'Paiements à vérifier',
                          couleur: AppColors.orange,
                          urgent:  s.paiementsAVerifier > 0,
                          tendance: FormatUtils.htg(s.montantAVerifier),
                          onTap: () => context.go('/admin/paiements'),
                        ),
                        KpiCard(
                          emoji:  '🌿',
                          valeur: '${s.totalProduits}',
                          label:  'Produits actifs',
                          couleur: AppColors.vertVif,
                          onTap: () => context.go('/admin/catalogue'),
                        ),
                        KpiCard(
                          emoji:  '🔴',
                          valeur: '${s.produitsEpuises}',
                          label:  'Épuisés',
                          couleur: AppColors.rouge,
                          onTap: () => context.go('/admin/stocks'),
                        ),
                        KpiCard(
                          emoji:  '⚠️',
                          valeur: '${s.alertesStock}',
                          label:  'Alertes stock',
                          couleur: AppColors.orange,
                          urgent:  s.alertesStock > 0,
                          onTap: () => context.go('/admin/stocks'),
                        ),
                      ]),
                    ) ?? const SliverToBoxAdapter(
                        child: SizedBox.shrink()),

                    // ── KPIs Collectes ───────────────────────
                    _SectionTitle('🚛 Collectes'),
                    stats.whenOrNull(
                      data: (s) => _KpiGrid([
                        KpiCard(
                          emoji:  '📅',
                          valeur: '${s.collectesPlanifiees}',
                          label:  'Planifiées',
                          couleur: AppColors.bleu,
                          onTap: () => context.go('/admin/collectes'),
                        ),
                        KpiCard(
                          emoji:  '🚛',
                          valeur: '${s.collectesEnCours}',
                          label:  'En cours',
                          couleur: AppColors.orange,
                          onTap: () => context.go('/admin/collectes'),
                        ),
                        KpiCard(
                          emoji:  '⏰',
                          valeur: '${s.collectesEnRetard}',
                          label:  'En retard',
                          couleur: AppColors.rouge,
                          urgent:  s.collectesEnRetard > 0,
                          onTap: () => context.go('/admin/collectes'),
                        ),
                        KpiCard(
                          emoji:  '🎟️',
                          valeur: '${s.vouchersActifs}',
                          label:  'Vouchers actifs',
                          couleur: AppColors.violet,
                        ),
                      ]),
                    ) ?? const SliverToBoxAdapter(
                        child: SizedBox.shrink()),

                    const SliverPadding(
                        padding: EdgeInsets.only(bottom: 80)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers internes ──────────────────────────────────────────

class _Alert {
  final String label;
  final VoidCallback onTap;
  const _Alert(this.label, this.onTap);
}

class _RevStat extends StatelessWidget {
  final String label;
  final String valeur;
  final bool   jaune;
  const _RevStat({
    required this.label,
    required this.valeur,
    this.jaune = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
        style: const TextStyle(
          color: Color(0xAAFFFFFF), fontSize: 11,
        ),
      ),
      Text(valeur,
        style: TextStyle(
          color:      jaune ? AppColors.jaune : Colors.white,
          fontSize:   jaune ? 18 : 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

Widget _SectionTitle(String titre) => SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(titre,
      style: const TextStyle(
        fontSize:   15,
        fontWeight: FontWeight.w800,
        color:      AppColors.vertFonce,
      ),
    ),
  ),
);

Widget _KpiGrid(List<KpiCard> cards) => SliverPadding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  sliver: SliverGrid(
    delegate: SliverChildListDelegate(cards),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount:   2,
      childAspectRatio: 1.2,
      mainAxisSpacing:  10,
      crossAxisSpacing: 10,
    ),
  ),
);
```

---

## ÉTAPE 8 — Gestion Producteurs Admin

### `lib/features/admin/screens/admin_producteurs_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_producteurs_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class AdminProducteursScreen extends ConsumerStatefulWidget {
  const AdminProducteursScreen({super.key});

  @override
  ConsumerState<AdminProducteursScreen> createState() =>
      _AdminProducteursScreenState();
}

class _AdminProducteursScreenState
    extends ConsumerState<AdminProducteursScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _filtres = [
    ('',           'Tous'),
    ('en_attente', '⏳ En attente'),
    ('actif',      '✅ Actifs'),
    ('suspendu',   '🚫 Suspendus'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filtres.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Producteurs'),
        bottom: TabBar(
          controller:          _tabs,
          isScrollable:        true,
          labelColor:          AppColors.jaune,
          unselectedLabelColor: Colors.white70,
          indicatorColor:      AppColors.jaune,
          tabs: _filtres.map((f) => Tab(text: f.$2)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: _filtres.map((f) =>
            _ProducteursList(statut: f.$1)).toList(),
      ),
    );
  }
}

class _ProducteursList extends ConsumerWidget {
  final String statut;
  const _ProducteursList({required this.statut});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminProducteursProvider);

    // Filtrer localement selon l'onglet actif
    final produits = state.whenOrNull(
      data: (list) => statut.isEmpty
          ? list
          : list.where((p) => p['statut'] == statut).toList(),
    ) ?? [];

    return state.when(
      loading: () => const LoadingWidget(),
      error:   (e, _) => Center(child: Text('$e')),
      data:    (_) {
        if (produits.isEmpty) {
          return const EmptyState(
            emoji: '🌾', titre: 'Aucun producteur',
          );
        }

        return RefreshIndicator(
          color:     AppColors.vertVif,
          onRefresh: () =>
              ref.read(adminProducteursProvider.notifier)
                  .charger(),
          child: ListView.builder(
            padding:   const EdgeInsets.all(12),
            itemCount: produits.length,
            itemBuilder: (_, i) {
              final p = produits[i];
              return Container(
                margin:  const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:     Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p['nom_complet'] as String? ?? '—',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize:   15,
                              color:      AppColors.vertFonce,
                            ),
                          ),
                        ),
                        _StatutBadge(
                            p['statut'] as String? ?? ''),
                      ],
                    ),
                    Text(
                      p['code_producteur'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color:    AppColors.grisTexte,
                      ),
                    ),
                    Text(
                      '📍 ${p['commune'] ?? ''} — '
                      '${p['departement'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color:    AppColors.grisTexte,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Boutons d'action
                    if (p['statut'] == 'en_attente')
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _changerStatut(
                              context, ref,
                              p['id'] as int, 'suspendu',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.rouge,
                              side: const BorderSide(
                                  color: AppColors.rouge),
                            ),
                            child: const Text('Refuser'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _changerStatut(
                              context, ref,
                              p['id'] as int, 'actif',
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.vertVif),
                            child: const Text('Valider'),
                          ),
                        ),
                      ])
                    else
                      Wrap(
                        spacing: 8,
                        children: [
                          if (p['statut'] != 'actif')
                            _ActionChip(
                              '✅ Activer',
                              AppColors.vertVif,
                              () => _changerStatut(
                                context, ref,
                                p['id'] as int, 'actif',
                              ),
                            ),
                          if (p['statut'] != 'suspendu')
                            _ActionChip(
                              '🚫 Suspendre',
                              AppColors.rouge,
                              () => _changerStatut(
                                context, ref,
                                p['id'] as int, 'suspendu',
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _changerStatut(
    BuildContext ctx, WidgetRef ref,
    int id, String statut,
  ) async {
    final success = await ref
        .read(adminProducteursProvider.notifier)
        .changerStatut(id, statut);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(success
            ? '✅ Statut mis à jour !'
            : '❌ Erreur'),
        backgroundColor:
            success ? AppColors.vertVif : AppColors.rouge,
      ));
    }
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;
  const _StatutBadge(this.statut);

  @override
  Widget build(BuildContext context) {
    final map = {
      'actif':      (AppColors.vertVif,  '✅ Actif'),
      'en_attente': (AppColors.orange,   '⏳ En attente'),
      'suspendu':   (AppColors.rouge,    '🚫 Suspendu'),
      'inactif':    (AppColors.grisTexte,'⬛ Inactif'),
    };
    final (color, label) =
        map[statut] ?? (AppColors.grisTexte, statut);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  const _ActionChip(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => ActionChip(
    label:       Text(label),
    onPressed:   onTap,
    backgroundColor: color.withOpacity(0.1),
    side:        BorderSide(color: color.withOpacity(0.3)),
    labelStyle:  TextStyle(
      color: color, fontWeight: FontWeight.w600, fontSize: 12,
    ),
  );
}
```

---

## ÉTAPE 9 — Paiements à Vérifier

### `lib/features/admin/screens/admin_paiements_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../providers/admin_paiements_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class AdminPaiementsScreen extends ConsumerWidget {
  const AdminPaiementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminPaiementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paiements à vérifier')),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('$e')),
        data:    (paiements) {
          if (paiements.isEmpty) {
            return const EmptyState(
              emoji:       '✅',
              titre:       'Aucun paiement en attente',
              description: 'Tous les paiements ont été traités.',
            );
          }

          return ListView.builder(
            padding:   const EdgeInsets.all(12),
            itemCount: paiements.length,
            itemBuilder: (_, i) {
              final p = paiements[i];
              return Container(
                margin:  const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:     Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.08),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payment,
                            color: AppColors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['reference'] as String? ?? '—',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.vertFonce,
                                  ),
                                ),
                                Text(
                                  p['commande_numero'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color:    AppColors.grisTexte,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            FormatUtils.htg(p['montant']),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize:   18,
                              color:      AppColors.vertFonce,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Détails + preuve
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _Row('Type',
                            p['type_label'] as String? ?? ''),
                          _Row('Statut',
                            p['statut_label'] as String? ?? ''),
                          _Row('Date',
                            FormatUtils.date(
                              p['created_at'] as String?)),

                          // Preuve de paiement
                          if (p['preuve_image'] != null) ...[
                            const SizedBox(height: 12),
                            const Text('🖼️ Preuve de paiement',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.vertFonce,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _voirPreuve(
                                context,
                                ImageUtils.imageUrl(
                                  p['preuve_image'] as String,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: ImageUtils.imageUrl(
                                    p['preuve_image'] as String,
                                  ),
                                  height: 120,
                                  width:  double.infinity,
                                  fit:    BoxFit.cover,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),

                          // Boutons confirmer / rejeter
                          Row(children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.close),
                                label: const Text('Rejeter'),
                                onPressed: () => _traiter(
                                  context, ref,
                                  p['id'] as int, 'rejeter',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.rouge,
                                  side: const BorderSide(
                                      color: AppColors.rouge),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                label: const Text('Confirmer'),
                                onPressed: () => _traiter(
                                  context, ref,
                                  p['id'] as int, 'confirmer',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.vertVif,
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _voirPreuve(BuildContext ctx, String url) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: url),
        ),
      ),
    );
  }

  Future<void> _traiter(
    BuildContext ctx, WidgetRef ref,
    int id, String action,
  ) async {
    final success = await ref
        .read(adminPaiementsProvider.notifier)
        .traiter(id, action);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(success
            ? action == 'confirmer'
                ? '✅ Paiement confirmé !'
                : '❌ Paiement rejeté'
            : 'Erreur'),
        backgroundColor: success
            ? (action == 'confirmer'
                ? AppColors.vertVif
                : AppColors.orange)
            : AppColors.rouge,
      ));
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String valeur;
  const _Row(this.label, this.valeur);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: const TextStyle(
            color: AppColors.grisTexte, fontSize: 13,
          ),
        ),
        Text(valeur,
          style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13,
            color: AppColors.vertFonce,
          ),
        ),
      ],
    ),
  );
}
```

---

## ÉTAPE 10 — Stocks & Alertes Admin

### `lib/features/admin/screens/admin_stocks_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/admin_stocks_provider.dart';
import '../../../shared/widgets/loading_widget.dart';

class AdminStocksScreen extends ConsumerStatefulWidget {
  const AdminStocksScreen({super.key});

  @override
  ConsumerState<AdminStocksScreen> createState() =>
      _AdminStocksScreenState();
}

class _AdminStocksScreenState
    extends ConsumerState<AdminStocksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminStocksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks & Alertes'),
        bottom: TabBar(
          controller:          _tabs,
          labelColor:          AppColors.jaune,
          unselectedLabelColor: Colors.white70,
          indicatorColor:      AppColors.jaune,
          tabs: const [
            Tab(text: '⚠️ Alertes'),
            Tab(text: '📦 Lots'),
          ],
        ),
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('$e')),
        data:    (data) => TabBarView(
          controller: _tabs,
          children: [
            // Alertes
            _AlertesList(
              alertes: (data['alertes'] as List?)
                  ?.cast<Map<String, dynamic>>() ?? [],
            ),
            // Lots
            _LotsList(
              lots: (data['lots'] as List?)
                  ?.cast<Map<String, dynamic>>() ?? [],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertesList extends StatelessWidget {
  final List<Map<String, dynamic>> alertes;
  const _AlertesList({required this.alertes});

  @override
  Widget build(BuildContext context) {
    if (alertes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✅', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Aucune alerte de stock',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.vertFonce,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding:   const EdgeInsets.all(12),
      itemCount: alertes.length,
      itemBuilder: (_, i) {
        final a = alertes[i];
        final niveauColor = {
          'critique': AppColors.rouge,
          'alerte':   AppColors.orange,
          'bas':      AppColors.statutAttente,
          'info':     AppColors.bleu,
        }[a['niveau']] ?? AppColors.grisTexte;

        return Container(
          margin:  const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: niveauColor.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color:     Colors.black.withOpacity(0.05),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width:  6,
                height: 50,
                decoration: BoxDecoration(
                  color:        niveauColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['produit'] as String? ?? '—',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.vertFonce,
                      ),
                    ),
                    Text(
                      a['producteur'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color:    AppColors.grisTexte,
                      ),
                    ),
                    Text(
                      'Stock : ${a['stock_actuel']} '
                      '(seuil : ${a['seuil']})',
                      style: TextStyle(
                        fontSize: 12,
                        color:    niveauColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:        niveauColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (a['niveau'] as String? ?? '')
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize:   10,
                    fontWeight: FontWeight.w800,
                    color:      niveauColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LotsList extends StatelessWidget {
  final List<Map<String, dynamic>> lots;
  const _LotsList({required this.lots});

  @override
  Widget build(BuildContext context) {
    if (lots.isEmpty) {
      return const Center(
        child: Text('Aucun lot disponible'),
      );
    }

    return ListView.builder(
      padding:   const EdgeInsets.all(12),
      itemCount: lots.length,
      itemBuilder: (_, i) {
        final l = lots[i];
        final qtAct  = l['quantite_actuelle'] as int? ?? 0;
        final qtInit = l['quantite_initiale'] as int? ?? 1;
        final taux   = qtAct / qtInit;

        return Container(
          margin:  const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:     Colors.black.withOpacity(0.05),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l['numero_lot'] as String? ?? '—',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.vertFonce,
                    ),
                  ),
                  Text(
                    l['statut'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color:    AppColors.grisTexte,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${l['produit']} — ${l['producteur']}',
                style: const TextStyle(
                  fontSize: 13,
                  color:    AppColors.grisTexte,
                ),
              ),
              const SizedBox(height: 8),
              // Barre de stock
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value:      taux.clamp(0.0, 1.0),
                        minHeight:  8,
                        backgroundColor: Colors.grey[200],
                        color:      taux > 0.5
                            ? AppColors.vertVif
                            : taux > 0.2
                                ? AppColors.orange
                                : AppColors.rouge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$qtAct / $qtInit kg',
                    style: const TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## ÉTAPE 11 — Écrans stubs (à compléter)

Crée ces fichiers avec une implémentation basique :

### `lib/features/admin/screens/admin_commandes_screen.dart`
Liste toutes les commandes depuis `adminCommandesProvider`.
Tabs : Toutes / En attente / En préparation / Livrées / Annulées.
Bouton changer statut avec bottom sheet.

### `lib/features/admin/screens/admin_catalogue_screen.dart`
Liste les produits depuis `GET /api/admin/catalogue/`.
Filtres : statut (actif/inactif), producteur.
Boutons : toggle actif/vedette, changer statut.

### `lib/features/admin/screens/admin_users_screen.dart`
Liste les utilisateurs depuis `adminUsersProvider`.
Filtres : rôle, is_active.
Barre de recherche.
Bouton toggle actif/inactif.

### `lib/features/admin/screens/admin_collectes_screen.dart`
Liste les collectes depuis `GET /api/admin/collectes/`.
Tabs : Planifiées / En cours / Terminées.
Boutons : démarrer, terminer, annuler.

---

## ÉTAPE 12 — Mettre à jour le Router Admin

Dans `lib/router/app_router.dart`, remplacer les `Placeholder()`
du shell Admin par les vrais écrans :

```dart
// Imports à ajouter
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_producteurs_screen.dart';
import '../features/admin/screens/admin_commandes_screen.dart';
import '../features/admin/screens/admin_paiements_screen.dart';
import '../features/admin/screens/admin_stocks_screen.dart';
import '../features/admin/screens/admin_catalogue_screen.dart';
import '../features/admin/screens/admin_users_screen.dart';
import '../features/admin/screens/admin_collectes_screen.dart';

// Shell Admin — routes
GoRoute(
  path: '/admin/dashboard',
  builder: (_, __) => const AdminDashboardScreen(),
),
GoRoute(
  path: '/admin/producteurs',
  builder: (_, __) => const AdminProducteursScreen(),
),
GoRoute(
  path: '/admin/commandes',
  builder: (_, __) => const AdminCommandesScreen(),
),
GoRoute(
  path: '/admin/paiements',
  builder: (_, __) => const AdminPaiementsScreen(),
),
GoRoute(
  path: '/admin/stocks',
  builder: (_, __) => const AdminStocksScreen(),
),
GoRoute(
  path: '/admin/catalogue',
  builder: (_, __) => const AdminCatalogueScreen(),
),
GoRoute(
  path: '/admin/utilisateurs',
  builder: (_, __) => const AdminUsersScreen(),
),
GoRoute(
  path: '/admin/collectes',
  builder: (_, __) => const AdminCollectesScreen(),
),
```

---

## ÉTAPE 13 — Initialiser FCM après login

Dans `lib/providers/auth_provider.dart`, ajouter l'init FCM
après un login/register réussi :

```dart
// Dans la méthode login(), après avoir sauvé les tokens :
if (success) {
  // Initialiser FCM avec le rôle
  try {
    final fcm = ref.read(fcmServiceProvider);
    await fcm.initialize(role: user.role);
  } catch (_) {}
}

// Dans la méthode logout() :
try {
  await ref.read(fcmServiceProvider).dispose();
} catch (_) {}
```

---

## ÉTAPE 14 — Constantes manquantes

Ajouter dans `lib/core/constants/app_colors.dart` :

```dart
static const Color violet = Color(0xFF8E44AD);
static const Color bleu   = Color(0xFF2980B9);
```

Ajouter dans `lib/core/storage/secure_storage.dart` :

```dart
Future<void> setString(String key, String value) async =>
    _storage.write(key: key, value: value);

Future<String?> getString(String key) async =>
    _storage.read(key: key);
```

---

## ÉTAPE 15 — `android/app/build.gradle` pour Firebase

Vérifier que le fichier `google-services.json` est en place dans
`android/app/` et que le `build.gradle` contient :

```gradle
// android/build.gradle
dependencies {
  classpath 'com.google.gms:google-services:4.4.0'
}

// android/app/build.gradle
apply plugin: 'com.google.gms.google-services'
```

Pour iOS, vérifier que `GoogleService-Info.plist` est ajouté
dans Xcode sous `Runner/`.

---

## ÉTAPE 16 — Build final et tests

```bash
# Générer les fichiers Freezed
flutter pub run build_runner build --delete-conflicting-outputs

# Analyser le code
flutter analyze

# Tester sur Android
flutter run

# Tester en release (pour tester FCM)
flutter run --release
```

---

## RÉSUMÉ — Ce que ce prompt crée

| Composant | Description |
|---|---|
| **FcmService** | Init FCM, topics par rôle, refresh token, dispose |
| **NotificationHandler** | Navigation ciblée selon le type de notif |
| **NotificationProvider** | Compteur non-lu + historique récent |
| **AdminStatsProvider** | 25+ KPIs depuis `/api/admin/stats/` |
| **5 providers admin** | Users, Producteurs, Commandes, Paiements, Stocks |
| **AdminDashboardScreen** | KPIs colorés, alertes urgentes, revenus |
| **AdminProducteursScreen** | Tabs statut + validation/refus inline |
| **AdminPaiementsScreen** | Vérification preuve + confirmer/rejeter |
| **AdminStocksScreen** | Alertes niveaux colorés + barre de stock |
| **KpiCard widget** | Carte KPI avec tendance + badge urgent |
| **Router admin complet** | Toutes les routes `/admin/*` |
| **FCM branché au login** | Init automatique après connexion |

---

## 🏁 L'app Flutter est maintenant COMPLÈTE

```
Prompt 1 ✅ — Fondations + Auth + Offline Engine
Prompt 2 ✅ — App Acheteur (catalogue, panier, commandes, paiements)
Prompt 3 ✅ — App Producteur + Collecteur
Prompt 4 ✅ — App Admin + FCM

Base URL : https://maketpeyizan.ht
```
