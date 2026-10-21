import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/commandes_producteur_provider.dart';
import '../../acheteur/widgets/commande_statut_badge.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/ui/ui.dart';

class CommandesRecuesScreen extends ConsumerStatefulWidget {
  final String? statutInitial;
  const CommandesRecuesScreen({this.statutInitial, super.key});

  @override
  ConsumerState<CommandesRecuesScreen> createState() =>
      _CommandesRecuesScreenState();
}

class _CommandesRecuesScreenState
    extends ConsumerState<CommandesRecuesScreen> {
  late String _statut;

  static const _filtres = [
    ('',               'Toutes'),
    ('en_attente',     'En attente'),
    ('confirmee',      'Confirmées'),
    ('en_preparation', 'En préparation'),
    ('livree',         'Livrées'),
    ('annulee',        'Annulées'),
  ];

  @override
  void initState() {
    super.initState();
    _statut = _filtres.any((f) => f.$1 == widget.statutInitial)
        ? widget.statutInitial!
        : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EnTeteEcran('Commandes reçues'),
            const SizedBox(height: 6),
            PastillesFiltre(
              options: _filtres,
              valeur: _statut,
              onChanged: (v) => setState(() => _statut = v),
            ),
            const SizedBox(height: 6),
            Expanded(child: _CommandesList(statut: _statut)),
          ],
        ),
      ),
    );
  }
}

class _CommandesList extends ConsumerWidget {
  final String statut;
  const _CommandesList({required this.statut});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commandesProducteurProvider(statut));

    return state.when(
      loading: () => const LoadingWidget(),
      error:   (e, _) => Center(child: Text('Erreur : $e')),
      data:    (commandes) {
        if (commandes.isEmpty) {
          return const EmptyState(
            icone:       Icons.inbox_outlined,
            titre:       'Aucune commande',
            description: 'Aucune commande dans cette catégorie.',
          );
        }

        return RefreshIndicator(
          color:     AppColors.vertFonce,
          onRefresh: () =>
              ref.read(commandesProducteurProvider(statut).notifier)
                  .charger(),
          child: ListView.separated(
            padding:   const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: commandes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = commandes[i];
              return Surface(
                onTap: () => context.go(
                  '/producteur/commande/${c.numeroCommande}',
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TuileIcone(Icons.receipt_long_outlined,
                            couleur: CommandeStatutBadge.couleur(c.statut),
                            taille: 42),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.numeroCommande,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize:   14.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(child: CommandeStatutBadge(c.statut)),
                                  const SizedBox(width: 8),
                                  Text(FormatUtils.date(c.createdAt),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color:    AppColors.grisLeger,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(FormatUtils.htg(c.total),
                          style: const TextStyle(
                            fontSize:   14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    // Actions rapides tant que la commande est en attente
                    if (c.statut == 'en_attente') ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _annuler(context, ref, c.numeroCommande),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.rouge,
                            ),
                            child: const Text('Refuser'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                _confirmer(context, ref, c.numeroCommande),
                            child: const Text('Confirmer'),
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmer(
    BuildContext ctx, WidgetRef ref, String numero,
  ) async {
    final result = await ref
        .read(commandesProducteurProvider('').notifier)
        .changerStatut(numero, 'confirmer');
    if (ctx.mounted) {
      final ok = result?['success'] == true;
      afficherMessage(ctx,
          ok ? 'Commande confirmée' : result?['error']?.toString() ?? 'Erreur',
          succes: ok);
    }
  }

  Future<void> _annuler(
    BuildContext ctx, WidgetRef ref, String numero,
  ) async {
    final motifCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Refuser la commande ?'),
        content: TextField(
          controller: motifCtrl,
          decoration: const InputDecoration(
            labelText: 'Motif (requis)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.rouge),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirm == true && motifCtrl.text.isNotEmpty) {
      final result = await ref
          .read(commandesProducteurProvider('').notifier)
          .changerStatut(numero, 'annuler',
              motif: motifCtrl.text);
      if (ctx.mounted) {
        final ok = result?['success'] == true;
        afficherMessage(ctx, ok ? 'Commande refusée' : 'Erreur', succes: ok);
      }
    }
  }
}
