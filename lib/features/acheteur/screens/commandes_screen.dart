import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/ui/ui.dart';
import '../providers/commande_provider.dart';
import '../widgets/commande_statut_badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_widget.dart';

class CommandesScreen extends ConsumerStatefulWidget {
  const CommandesScreen({super.key});

  @override
  ConsumerState<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends ConsumerState<CommandesScreen> {
  String _filtre = 'toutes';

  static const _enCours = {'en_attente', 'confirmee', 'en_preparation', 'prete', 'en_collecte'};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commandesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EnTeteEcran('Commandes',
                surtitre: state.whenOrNull(data: (l) => '${l.length} au total')),
            const SizedBox(height: 6),
            PastillesFiltre(
              options: const [
                ('toutes',   'Toutes'),
                ('en_cours', 'En cours'),
                ('livree',   'Livrées'),
                ('annulee',  'Annulées'),
              ],
              valeur: _filtre,
              onChanged: (v) => setState(() => _filtre = v),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: state.when(
                loading: () => const LoadingWidget(message: 'Chargement…'),
                error: (e, _) => ErreurChargement(e),
                data: (toutes) {
                  final commandes = switch (_filtre) {
                    'en_cours' => toutes.where((c) => _enCours.contains(c.statut)).toList(),
                    'toutes'   => toutes,
                    final f    => toutes.where((c) => c.statut == f).toList(),
                  };
                  if (commandes.isEmpty) {
                    return EmptyState(
                      icone:       Icons.receipt_long_outlined,
                      titre:       'Aucune commande',
                      description: 'Vos commandes apparaîtront ici.',
                      boutonLabel: toutes.isEmpty ? 'Voir la boutique' : null,
                      onBouton:    () => context.go('/acheteur/catalogue'),
                    );
                  }

                  return RefreshIndicator(
                    color:     AppColors.vertFonce,
                    onRefresh: () =>
                        ref.read(commandesProvider.notifier).charger(),
                    child: ListView.separated(
                      padding:   const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: commandes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final c = commandes[i];
                        return Surface(
                          onTap: () => context.go(
                            '/acheteur/commande/${c.numeroCommande}',
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              TuileIcone(Icons.receipt_long_outlined,
                                  couleur: CommandeStatutBadge.couleur(c.statut),
                                  taille: 44),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.producteur,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize:   14.5,
                                      ),
                                    ),
                                    Text(
                                      '${c.numeroCommande} · ${FormatUtils.date(c.createdAt)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color:    AppColors.grisTexte,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    CommandeStatutBadge(c.statut),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                FormatUtils.htg(c.total),
                                style: const TextStyle(
                                  fontSize:   14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
