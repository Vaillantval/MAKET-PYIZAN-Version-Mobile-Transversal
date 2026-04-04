import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/collecteur_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class CollectesTerrainScreen extends ConsumerWidget {
  const CollectesTerrainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collecteurProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Mes Collectes Terrain')),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('Erreur : $e')),
        data:    (collectes) {
          if (collectes.isEmpty) {
            return const EmptyState(
              emoji:       '🚛',
              titre:       'Aucune collecte assignée',
              description:
                  'Les collectes qui vous sont assignées apparaîtront ici.',
            );
          }

          return ListView.builder(
            padding:   const EdgeInsets.all(12),
            itemCount: collectes.length,
            itemBuilder: (_, i) {
              final c       = collectes[i];
              final collecte = c['collecte'] as Map<String, dynamic>? ?? {};

              return Container(
                margin:  const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:     Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:        AppColors.vertMenthe,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: AppColors.vertFonce,
                            size:  28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                collecte['titre'] as String? ??
                                    collecte['reference'] as String? ??
                                    'Collecte',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize:   16,
                                  color:      AppColors.vertFonce,
                                ),
                              ),
                              Text(
                                collecte['zone'] as String? ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color:    AppColors.grisTexte,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatutBadge(
                          collecte['statut'] as String? ?? '',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Infos collecte
                    Row(children: [
                      const Icon(Icons.calendar_today,
                        size: 14, color: AppColors.grisTexte),
                      const SizedBox(width: 6),
                      Text(
                        FormatUtils.date(
                          collecte['date_prevue'] as String?
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color:    AppColors.grisTexte,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 14),
                    Row(children: [
                      const Icon(Icons.people_outline,
                        size: 14, color: AppColors.vertVif),
                      const SizedBox(width: 6),
                      Text(
                        '${collecte['nb_producteurs'] ?? 0} '
                        'producteur(s) participant(s)',
                        style: const TextStyle(
                          fontSize: 13,
                          color:    AppColors.grisTexte,
                        ),
                      ),
                    ]),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;
  const _StatutBadge(this.statut);

  @override
  Widget build(BuildContext context) {
    final map = {
      'planifiee':  (AppColors.bleu,    'Planifiée'),
      'en_cours':   (AppColors.orange,  'En cours'),
      'terminee':   (AppColors.vertVif, 'Terminée'),
      'annulee':    (AppColors.rouge,   'Annulée'),
    };
    final (color, label) = map[statut] ??
        (AppColors.grisTexte, statut);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
