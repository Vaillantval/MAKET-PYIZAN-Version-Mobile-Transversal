import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/offline/offline_banner.dart';

class DashboardProducteurScreen extends ConsumerWidget {
  const DashboardProducteurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user      = ref.watch(authProvider).user;
    final dashState = ref.watch(dashboardProvider);

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
                    ref.read(dashboardProvider.notifier).charger(),
                child: CustomScrollView(
                  slivers: [

                    // ── Header ────────────────────────────────
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.vertFonce,
                              Color(0xFF1E8449),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(
                          20, 16, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjou ${user?.firstName ?? ''} 🌾',
                                      style: const TextStyle(
                                        color:      Colors.white,
                                        fontSize:   20,
                                        fontFamily: 'PlayfairDisplay',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Text(
                                      'Tableau de bord producteur',
                                      style: TextStyle(
                                        color:   Color(0xBBFFFFFF),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.15),
                                  child: Text(
                                    (user?.firstName ?? '?')[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color:      Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize:   18,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Revenus du mois
                            dashState.whenOrNull(
                              data: (stats) => Container(
                                margin:  const EdgeInsets.only(top: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:        Colors.white
                                      .withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Revenus ce mois',
                                          style: TextStyle(
                                            color:   Color(0xBBFFFFFF),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          FormatUtils.htg(
                                              stats.revenusMois),
                                          style: const TextStyle(
                                            color:      AppColors.jaune,
                                            fontSize:   24,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'PlayfairDisplay',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Total',
                                          style: TextStyle(
                                            color:   Color(0xBBFFFFFF),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          FormatUtils.htg(
                                              stats.revenusTotal),
                                          style: const TextStyle(
                                            color:      Colors.white,
                                            fontSize:   16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ) ?? const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),

                    // ── Stats Commandes ───────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: const Text(
                          '🧾 Commandes',
                          style: TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.w800,
                            color:      AppColors.vertFonce,
                          ),
                        ),
                      ),
                    ),

                    dashState.when(
                      loading: () => const SliverToBoxAdapter(
                        child: LoadingWidget(),
                      ),
                      error: (e, _) => SliverToBoxAdapter(
                        child: Center(child: Text('Erreur : $e')),
                      ),
                      data: (stats) => SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        sliver: SliverGrid(
                          delegate: SliverChildListDelegate([
                            StatCard(
                              emoji:   '⏳',
                              label:   'En attente',
                              valeur:  '${stats.commandesEnAttente}',
                              couleur: AppColors.statutAttente,
                              onTap: () => context.go(
                                '/producteur/commandes?statut=en_attente',
                              ),
                            ),
                            StatCard(
                              emoji:   '✅',
                              label:   'Confirmées',
                              valeur:  '${stats.commandesConfirmees}',
                              couleur: AppColors.statutConfirmee,
                              onTap: () => context.go(
                                '/producteur/commandes?statut=confirmee',
                              ),
                            ),
                            StatCard(
                              emoji:   '📦',
                              label:   'Livrées',
                              valeur:  '${stats.commandesLivrees}',
                              couleur: AppColors.statutLivree,
                            ),
                            StatCard(
                              emoji:   '📊',
                              label:   'Total',
                              valeur:  '${stats.commandesTotal}',
                              couleur: AppColors.vertFonce,
                            ),
                          ]),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:   2,
                            childAspectRatio: 1.3,
                            mainAxisSpacing:  10,
                            crossAxisSpacing: 10,
                          ),
                        ),
                      ),
                    ),

                    // ── Stats Produits & Stock ─────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: const Text(
                          '🥬 Produits & Stock',
                          style: TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.w800,
                            color:      AppColors.vertFonce,
                          ),
                        ),
                      ),
                    ),

                    dashState.whenOrNull(
                      data: (stats) => SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        sliver: SliverGrid(
                          delegate: SliverChildListDelegate([
                            StatCard(
                              emoji:   '🌿',
                              label:   'Produits actifs',
                              valeur:  '${stats.nbProduitsActifs}',
                              couleur: AppColors.vertVif,
                              onTap: () =>
                                  context.go('/producteur/catalogue'),
                            ),
                            StatCard(
                              emoji:   '🔴',
                              label:   'Épuisés',
                              valeur:  '${stats.nbProduitsEpuises}',
                              couleur: AppColors.rouge,
                            ),
                            StatCard(
                              emoji:   '⚠️',
                              label:   'Alertes stock',
                              valeur:  '${stats.alertesStock}',
                              couleur: AppColors.orange,
                            ),
                            StatCard(
                              emoji:   '🚛',
                              label:   'Collectes à venir',
                              valeur:  '${stats.collectesAVenir}',
                              couleur: AppColors.bleu,
                              onTap: () =>
                                  context.go('/producteur/collectes'),
                            ),
                          ]),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:   2,
                            childAspectRatio: 1.3,
                            mainAxisSpacing:  10,
                            crossAxisSpacing: 10,
                          ),
                        ),
                      ),
                    ) ?? const SliverToBoxAdapter(child: SizedBox.shrink()),

                    // ── Actions rapides ────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚡ Actions rapides',
                              style: TextStyle(
                                fontSize:   16,
                                fontWeight: FontWeight.w800,
                                color:      AppColors.vertFonce,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                child: _ActionBtn(
                                  emoji: '➕',
                                  label: 'Nouveau produit',
                                  onTap: () => context.go(
                                    '/producteur/produit/nouveau',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ActionBtn(
                                  emoji: '📋',
                                  label: 'Commandes reçues',
                                  onTap: () => context.go(
                                    '/producteur/commandes',
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),

                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 80),
                    ),
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

class _ActionBtn extends StatelessWidget {
  final String       emoji;
  final String       label;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color:        AppColors.vertMenthe,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.vertVif.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(label,
            style: const TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w700,
              color:      AppColors.vertFonce,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
