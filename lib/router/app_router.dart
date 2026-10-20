import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/entreprise_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/local_storage.dart';
import '../models/entreprise.dart';
import '../core/offline/offline_banner.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/mot_de_passe_oublie_screen.dart';
import '../features/auth/screens/pending_validation_screen.dart';
import '../features/acheteur/providers/panier_provider.dart';
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
import '../features/entreprise/screens/creer_entreprise_screen.dart';
import '../features/entreprise/screens/entreprise_infos_screen.dart';
import '../features/entreprise/screens/membres_screen.dart';
import '../features/pos/screens/pos_appairage_screen.dart';
import '../features/pos/screens/pos_vente_screen.dart';
import '../features/pos/screens/pos_session_screen.dart';
import '../features/pos/screens/pos_historique_screen.dart';
import '../features/pos/screens/pos_paiement_screen.dart';
import '../features/pos/screens/pos_profil_screen.dart';
import '../features/pos/widgets/pos_session_banner.dart';
import '../features/pos/widgets/pos_terminal_banner.dart';
import '../features/pos/providers/pos_terminal_status_provider.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_producteurs_screen.dart';
import '../features/admin/screens/admin_commandes_screen.dart';
import '../features/admin/screens/admin_paiements_screen.dart';
import '../features/admin/screens/admin_stocks_screen.dart';
import '../features/admin/screens/admin_catalogue_screen.dart';
import '../features/admin/screens/admin_users_screen.dart';
import '../features/admin/screens/admin_collectes_screen.dart';

// Notifie go_router à chaque changement d'authState pour qu'il réévalue
// son `redirect`, SANS reconstruire l'objet GoRouter lui-même. Recréer tout
// le router à chaque changement d'état (ce qu'un Provider<GoRouter> qui fait
// ref.watch(authProvider) ferait) est un anti-pattern connu de go_router :
// un nouvel objet GoRouter avec une toute nouvelle pile de navigation
// interne peut désynchroniser la redirection réactive de la vraie
// localisation courante de l'app.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
    // Entrer / sortir de l'espace entreprise, ou changer d'entreprise
    _ref.listen<int?>(entrepriseActiveIdProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final status  = authState.status;
      final path    = state.matchedLocation;
      // '/splash' est volontairement exclu : c'est un écran de transit qui
      // doit toujours être quitté dès que le statut d'auth est résolu (sinon
      // l'app reste bloquée dessus indéfiniment une fois non-authentifié).
      final isAuth  = ['/login', '/register', '/mot-de-passe-oublie'].contains(path);

      if (status == AuthStatus.unknown) {
        return path == '/splash' ? null : '/splash';
      }

      if (status == AuthStatus.unauthenticated) {
        if (path == '/splash') return '/login';
        return isAuth ? null : '/login';
      }

      final role = authState.user?.role ?? 'acheteur';
      // Espace entreprise : vendre ne dépend plus du rôle du compte mais de
      // son appartenance à une entreprise, choisie depuis l'espace acheteur.
      final entreprise = ref.read(entrepriseActiveProvider);

      // Connecté
      if (isAuth || path == '/splash') {
        // Rediriger selon le rôle (ou rouvrir l'entreprise active)
        return _homeRoute(role, entreprise);
      }

      // Garde-fou : /pos/* réservé au rôle pos_operator
      if (path.startsWith('/pos/') && role != 'pos_operator') {
        return _homeRoute(role, entreprise);
      }

      // Garde-fou : /producteur/* exige une entreprise active dont le
      // compte est (toujours) membre
      if (path.startsWith('/producteur')) {
        if (entreprise == null) return '/acheteur/accueil';

        // Entreprise pas (encore) validée → écran dédié
        if (!entreprise.estActive) {
          return path == '/producteur/en-attente'
              ? null
              : '/producteur/en-attente';
        }
        if (path == '/producteur/en-attente') return '/producteur/dashboard';

        // Portefeuille d'entreprise : propriétaires seulement
        if (path.startsWith('/producteur/wallet') &&
            !entreprise.estProprietaire) {
          return '/producteur/profil';
        }
      }

      // POS : premier lancement → forcer l'écran d'enregistrement du
      // terminal (le device_uid, lui, est toujours généré automatiquement)
      if (role == 'pos_operator' && path != '/pos/appairage') {
        final onboardingVu = ref
            .read(localStorageProvider)
            .getBool(AppConstants.keyPosOnboardingVu);
        if (!onboardingVu) {
          return '/pos/appairage';
        }
      }

      // POS : un terminal non (ou plus) autorisé (TERMINAL_EN_ATTENTE /
      // TERMINAL_REVOQUE) n'est volontairement PAS bloquant ici — voir
      // PosTerminalBanner et l'onglet Profil pour le statut affiché à
      // l'opérateur, qui reste libre de naviguer.

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
        path:    '/mot-de-passe-oublie',
        builder: (_, __) => const MotDePasseOublieScreen(),
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
          // ── Entreprises ──────────────────────────────────
          GoRoute(path: '/acheteur/entreprise/creer', builder: (_, __) => const CreerEntrepriseScreen()),
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
          GoRoute(path: '/producteur/entreprise', builder: (_, __) => const EntrepriseInfosScreen()),
          GoRoute(path: '/producteur/membres',   builder: (_, __) => const MembresScreen()),
          // ── Wallet de l'entreprise (mêmes écrans que côté acheteur) ──
          // Recharges, bons et paiement au comptoir restent personnels :
          // seuls le solde, l'historique et les retraits portent sur
          // l'entreprise (en-tête X-Entreprise, cf. ApiClient).
          GoRoute(path: '/producteur/wallet',          builder: (_, __) => const WalletScreen()),
          GoRoute(path: '/producteur/wallet/retrait',  builder: (_, __) => const WalletRetraitScreen()),
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

String _homeRoute(String role, EntrepriseMembre? entreprise) {
  switch (role) {
    case 'collecteur':  return '/collecteur/collectes';
    case 'pos_operator': return '/pos/vente';
    case 'superadmin':
    case 'admin':       return '/admin/dashboard';
    default:
      return entreprise != null ? '/producteur/dashboard' : '/acheteur/accueil';
  }
}

// ── Shells (BottomNavigation par rôle) ────────────────────────

class AcheteurShell extends ConsumerWidget {
  final Widget child;
  const AcheteurShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(panierProvider); // badge du panier à jour
    final nbPanier = ref.read(panierProvider.notifier).nbArticles;
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNav(context, [
        const _NavItem(icon: Icons.home_outlined, iconActif: Icons.home,      label: 'Accueil',   route: '/acheteur/accueil'),
        const _NavItem(icon: Icons.store_outlined, iconActif: Icons.store,     label: 'Catalogue', route: '/acheteur/catalogue'),
        _NavItem(icon: Icons.shopping_cart_outlined, iconActif: Icons.shopping_cart, label: 'Panier',route: '/acheteur/panier', badge: nbPanier),
        const _NavItem(icon: Icons.receipt_outlined, iconActif: Icons.receipt,   label: 'Commandes', route: '/acheteur/commandes'),
        const _NavItem(icon: Icons.person_outline, iconActif: Icons.person,     label: 'Profil',    route: '/acheteur/profil'),
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
        const _NavItem(icon: Icons.dashboard_outlined, iconActif: Icons.dashboard,  label: 'Dashboard',  route: '/producteur/dashboard'),
        const _NavItem(icon: Icons.receipt_outlined, iconActif: Icons.receipt,    label: 'Commandes',  route: '/producteur/commandes'),
        const _NavItem(icon: Icons.inventory_outlined, iconActif: Icons.inventory,  label: 'Catalogue',  route: '/producteur/catalogue'),
        const _NavItem(icon: Icons.local_shipping_outlined, iconActif: Icons.local_shipping, label: 'Collectes', route: '/producteur/collectes'),
        const _NavItem(icon: Icons.person_outline, iconActif: Icons.person,      label: 'Profil',     route: '/producteur/profil'),
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
        const _NavItem(icon: Icons.local_shipping_outlined, iconActif: Icons.local_shipping, label: 'Collectes', route: '/collecteur/collectes'),
        const _NavItem(icon: Icons.person_outline, iconActif: Icons.person,          label: 'Profil',    route: '/collecteur/profil'),
      ]),
    );
  }
}

class PosShell extends ConsumerStatefulWidget {
  final Widget child;
  const PosShell({required this.child, super.key});

  @override
  ConsumerState<PosShell> createState() => _PosShellState();
}

class _PosShellState extends ConsumerState<PosShell> {
  @override
  void initState() {
    super.initState();
    // Vérification non-bloquante au démarrage/reprise de l'app — un appel
    // POS réel (catalogue, session…) alimente déjà ce statut en direct sur
    // un 403, mais l'opérateur peut aussi naviguer directement sur Session/
    // Historique/Profil sans jamais déclencher un tel appel.
    Future.microtask(() => ref.read(posTerminalStatusProvider.notifier).verifier());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          const PosTerminalBanner(),
          const PosSessionBanner(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, [
        const _NavItem(icon: Icons.point_of_sale,     label: 'Vente',      route: '/pos/vente'),
        const _NavItem(icon: Icons.lock_clock_outlined, iconActif: Icons.lock_clock, label: 'Session',  route: '/pos/session'),
        const _NavItem(icon: Icons.history,            label: 'Historique', route: '/pos/historique'),
        const _NavItem(icon: Icons.person_outline, iconActif: Icons.person,     label: 'Profil',     route: '/pos/profil'),
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
      appBar: AppBar(title: const Text('MaketLakay Admin')),
      drawer: _buildAdminDrawer(context),
      body: child,
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.vertFonce),
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

  return DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.grisBord)),
    ),
    child: NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => context.go(items[i].route),
      destinations: items.map((i) => NavigationDestination(
        icon:         _iconeNav(i.icon, i.badge),
        selectedIcon: _iconeNav(i.iconActif ?? i.icon, i.badge),
        label:        i.label,
      )).toList(),
    ),
  );
}

Widget _iconeNav(IconData icone, int badge) => badge > 0
    ? Badge(
        label: Text('$badge'),
        backgroundColor: AppColors.jaune,
        textColor: AppColors.noir,
        child: Icon(icone),
      )
    : Icon(icone);

class _NavItem {
  final IconData  icon;
  final IconData? iconActif;
  final String    label;
  final String    route;
  final int       badge;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.iconActif,
    this.badge = 0,
  });
}
