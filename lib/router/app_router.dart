import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/local_storage.dart';
import '../core/offline/offline_banner.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/pending_validation_screen.dart';
import '../features/acheteur/screens/accueil_screen.dart';
import '../features/acheteur/screens/catalogue_screen.dart';
import '../features/acheteur/screens/produit_detail_screen.dart';
import '../features/acheteur/screens/panier_screen.dart';
import '../features/acheteur/screens/checkout_screen.dart';
import '../features/acheteur/screens/paiement_moncash_screen.dart';
import '../features/acheteur/screens/commandes_screen.dart';
import '../features/acheteur/screens/commande_detail_screen.dart';
import '../features/acheteur/screens/profil_screen.dart';
import '../features/acheteur/screens/adresses_screen.dart';
import '../features/acheteur/screens/wallet_screen.dart';
import '../features/acheteur/screens/wallet_recharge_screen.dart';
import '../features/acheteur/screens/wallet_retrait_screen.dart';
import '../features/acheteur/screens/bons_cadeaux_screen.dart';
import '../features/acheteur/screens/wallet_code_paiement_screen.dart';
import '../features/producteur/screens/dashboard_screen.dart' show DashboardProducteurScreen;
import '../features/producteur/screens/commandes_recues_screen.dart';
import '../features/producteur/screens/mes_produits_screen.dart';
import '../features/producteur/screens/collectes_screen.dart' show CollectesProducteurScreen;
import '../features/producteur/screens/profil_producteur_screen.dart';
import '../features/collecteur/screens/collectes_terrain_screen.dart';
import '../features/pos/screens/pos_appairage_screen.dart';
import '../features/pos/screens/pos_vente_screen.dart';
import '../features/pos/screens/pos_session_screen.dart';
import '../features/pos/screens/pos_historique_screen.dart';
import '../features/pos/screens/pos_paiement_screen.dart';
import '../features/pos/screens/pos_profil_screen.dart';
import '../features/pos/widgets/pos_session_banner.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_producteurs_screen.dart';
import '../features/admin/screens/admin_commandes_screen.dart';
import '../features/admin/screens/admin_paiements_screen.dart';
import '../features/admin/screens/admin_stocks_screen.dart';
import '../features/admin/screens/admin_catalogue_screen.dart';
import '../features/admin/screens/admin_users_screen.dart';
import '../features/admin/screens/admin_collectes_screen.dart';

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

      final role = authState.user?.role ?? 'acheteur';

      // Connecté
      if (isAuth) {
        // Rediriger selon le rôle
        return _homeRouteForRole(role);
      }

      // Garde-fou : /pos/* réservé au rôle pos_operator
      if (path.startsWith('/pos/') && role != 'pos_operator') {
        return _homeRouteForRole(role);
      }

      // Producteur en attente → écran dédié
      final notifier = ref.read(authProvider.notifier);
      if (notifier.isProducteurEnAttente &&
          path != '/producteur/en-attente') {
        return '/producteur/en-attente';
      }

      // POS : terminal non appairé → forcer l'écran d'appairage
      if (role == 'pos_operator' && path != '/pos/appairage') {
        final deviceUid = ref
            .read(localStorageProvider)
            .getString(AppConstants.keyPosDeviceUid);
        if (deviceUid == null || deviceUid.isEmpty) {
          return '/pos/appairage';
        }
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
      GoRoute(
        path:    '/pos/appairage',
        builder: (_, __) => const PosAppairageScreen(),
      ),

      // ── Acheteur ──────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => AcheteurShell(child: child),
        routes: [
          GoRoute(path: '/acheteur/accueil',    builder: (_, __) => const AccueilScreen()),
          GoRoute(path: '/acheteur/catalogue',  builder: (_, __) => const CatalogueScreen()),
          GoRoute(
            path: '/acheteur/produit/:slug',
            builder: (_, state) => ProduitDetailScreen(slug: state.pathParameters['slug']!),
          ),
          GoRoute(path: '/acheteur/panier',     builder: (_, __) => const PanierScreen()),
          GoRoute(path: '/acheteur/checkout',   builder: (_, __) => const CheckoutScreen()),
          GoRoute(
            path: '/acheteur/paiement/moncash',
            builder: (_, state) {
              final redirectUrl = state.uri.queryParameters['redirectUrl'] ?? '/acheteur/commandes';
              return PaiementMoncashScreen(redirectUrl: redirectUrl);
            },
          ),
          GoRoute(path: '/acheteur/commandes',  builder: (_, __) => const CommandesScreen()),
          GoRoute(
            path: '/acheteur/commande/:numero',
            builder: (_, state) => CommandeDetailScreen(numero: state.pathParameters['numero']!),
          ),
          GoRoute(path: '/acheteur/profil',     builder: (_, __) => const ProfilScreen()),
          GoRoute(path: '/acheteur/adresses',   builder: (_, __) => const AdressesScreen()),
          // ── Wallet ────────────────────────────────────────
          GoRoute(path: '/acheteur/wallet',          builder: (_, __) => const WalletScreen()),
          GoRoute(path: '/acheteur/wallet/recharge', builder: (_, __) => const WalletRechargeScreen()),
          GoRoute(path: '/acheteur/wallet/retrait',  builder: (_, __) => const WalletRetraitScreen()),
          GoRoute(path: '/acheteur/wallet/bons',     builder: (_, __) => const BonsCadeauxScreen()),
          GoRoute(path: '/acheteur/wallet/code-paiement', builder: (_, __) => const WalletCodePaiementScreen()),
        ],
      ),

      // ── Producteur ────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => ProducteurShell(child: child),
        routes: [
          GoRoute(path: '/producteur/dashboard', builder: (_, __) => const DashboardProducteurScreen()),
          GoRoute(path: '/producteur/commandes', builder: (_, __) => const CommandesRecuesScreen()),
          GoRoute(path: '/producteur/catalogue', builder: (_, __) => const MesProduitsScreen()),
          GoRoute(path: '/producteur/collectes', builder: (_, __) => const CollectesProducteurScreen()),
          GoRoute(path: '/producteur/profil',    builder: (_, __) => const ProfilProducteurScreen()),
        ],
      ),

      // ── Collecteur ────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => CollecteurShell(child: child),
        routes: [
          GoRoute(path: '/collecteur/collectes', builder: (_, __) => const CollectesTerrainScreen()),
          GoRoute(path: '/collecteur/profil',    builder: (_, __) => const Placeholder()),
        ],
      ),

      // ── POS (opérateur comptoir) ────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => PosShell(child: child),
        routes: [
          GoRoute(path: '/pos/vente',      builder: (_, __) => const PosVenteScreen()),
          GoRoute(path: '/pos/paiement',   builder: (_, __) => const PosPaiementScreen()),
          GoRoute(path: '/pos/session',    builder: (_, __) => const PosSessionScreen()),
          GoRoute(path: '/pos/historique', builder: (_, __) => const PosHistoriqueScreen()),
          GoRoute(path: '/pos/profil',     builder: (_, __) => const PosProfilScreen()),
        ],
      ),

      // ── Admin ─────────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin/dashboard',    builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/producteurs',  builder: (_, __) => const AdminProducteursScreen()),
          GoRoute(path: '/admin/commandes',    builder: (_, __) => const AdminCommandesScreen()),
          GoRoute(path: '/admin/paiements',    builder: (_, __) => const AdminPaiementsScreen()),
          GoRoute(path: '/admin/catalogue',    builder: (_, __) => const AdminCatalogueScreen()),
          GoRoute(path: '/admin/stocks',       builder: (_, __) => const AdminStocksScreen()),
          GoRoute(path: '/admin/collectes',    builder: (_, __) => const AdminCollectesScreen()),
          GoRoute(path: '/admin/utilisateurs', builder: (_, __) => const AdminUsersScreen()),
        ],
      ),
    ],
  );
});

String _homeRouteForRole(String role) {
  switch (role) {
    case 'producteur':  return '/producteur/dashboard';
    case 'collecteur':  return '/collecteur/collectes';
    case 'pos_operator': return '/pos/vente';
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

class PosShell extends ConsumerWidget {
  final Widget child;
  const PosShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          const PosSessionBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, [
        const _NavItem(icon: Icons.point_of_sale,     label: 'Vente',      route: '/pos/vente'),
        const _NavItem(icon: Icons.lock_clock_outlined, label: 'Session',  route: '/pos/session'),
        const _NavItem(icon: Icons.history,            label: 'Historique', route: '/pos/historique'),
        const _NavItem(icon: Icons.person_outline,     label: 'Profil',     route: '/pos/profil'),
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
