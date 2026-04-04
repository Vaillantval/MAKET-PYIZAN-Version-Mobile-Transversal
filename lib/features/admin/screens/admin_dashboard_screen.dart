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
    final stats      = ref.watch(adminStatsProvider);
    final user       = ref.watch(authProvider).user;
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
