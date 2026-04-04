import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/commande_provider.dart';
import '../widgets/commande_statut_badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_widget.dart';

class CommandesScreen extends ConsumerWidget {
  const CommandesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commandesProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(commandesProvider.notifier).charger(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const LoadingWidget(message: 'Chargement...'),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (commandes) {
          if (commandes.isEmpty) {
            return EmptyState(
              emoji:       '📦',
              titre:       'Aucune commande',
              description: 'Vos commandes apparaîtront ici.',
              boutonLabel: 'Voir le catalogue',
              onBouton:    () => context.go('/acheteur/catalogue'),
            );
          }

          return RefreshIndicator(
            color:     AppColors.vertVif,
            onRefresh: () =>
                ref.read(commandesProvider.notifier).charger(),
            child: ListView.builder(
              padding:   const EdgeInsets.all(12),
              itemCount: commandes.length,
              itemBuilder: (_, i) {
                final c = commandes[i];
                return GestureDetector(
                  onTap: () => context.go(
                    '/acheteur/commande/${c.numeroCommande}',
                  ),
                  child: Container(
                    margin:  const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:     Colors.black.withValues(alpha: 0.05),
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
                            Text(
                              c.numeroCommande,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize:   15,
                                color:      AppColors.vertFonce,
                              ),
                            ),
                            CommandeStatutBadge(c.statut),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '🌾 ${c.producteur}',
                          style: const TextStyle(
                            fontSize: 13,
                            color:    AppColors.grisTexte,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              FormatUtils.date(c.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color:    AppColors.grisTexte,
                              ),
                            ),
                            Text(
                              FormatUtils.htg(c.total),
                              style: const TextStyle(
                                fontSize:   16,
                                fontWeight: FontWeight.w800,
                                color:      AppColors.vertFonce,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
