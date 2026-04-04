import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/commandes_producteur_provider.dart';
import '../../acheteur/widgets/commande_statut_badge.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class CommandesRecuesScreen extends ConsumerStatefulWidget {
  final String? statutInitial;
  const CommandesRecuesScreen({this.statutInitial, super.key});

  @override
  ConsumerState<CommandesRecuesScreen> createState() =>
      _CommandesRecuesScreenState();
}

class _CommandesRecuesScreenState
    extends ConsumerState<CommandesRecuesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _filtres = [
    ('',             'Toutes'),
    ('en_attente',   '⏳ Attente'),
    ('confirmee',    '✅ Confirmées'),
    ('en_preparation','🔄 Préparation'),
    ('livree',       '📦 Livrées'),
    ('annulee',      '❌ Annulées'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filtres.length, vsync: this);
    if (widget.statutInitial != null) {
      final idx = _filtres.indexWhere(
        (f) => f.$1 == widget.statutInitial,
      );
      if (idx >= 0) _tabs.index = idx;
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Commandes reçues'),
        bottom: TabBar(
          controller:      _tabs,
          isScrollable:    true,
          labelColor:      AppColors.jaune,
          unselectedLabelColor: Colors.white70,
          indicatorColor:  AppColors.jaune,
          tabs: _filtres.map((f) => Tab(text: f.$2)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: _filtres.map((f) => _CommandesList(
          statut: f.$1,
        )).toList(),
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
            emoji:       '📭',
            titre:       'Aucune commande',
            description: 'Aucune commande dans cette catégorie.',
          );
        }

        return RefreshIndicator(
          color:     AppColors.vertVif,
          onRefresh: () =>
              ref.read(commandesProducteurProvider(statut).notifier)
                  .charger(),
          child: ListView.builder(
            padding:   const EdgeInsets.all(12),
            itemCount: commandes.length,
            itemBuilder: (_, i) {
              final c = commandes[i];
              return GestureDetector(
                onTap: () => context.go(
                  '/producteur/commande/${c.numeroCommande}',
                ),
                child: Container(
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
                      // Boutons action rapide si en_attente
                      if (c.statut == 'en_attente') ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _annuler(context, ref, c.numeroCommande),
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
                              onPressed: () =>
                                  _confirmer(context, ref, c.numeroCommande),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.vertVif,
                              ),
                              child: const Text('Confirmer'),
                            ),
                          ),
                        ]),
                      ],
                    ],
                  ),
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
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(result?['success'] == true
            ? '✅ Commande confirmée !'
            : result?['error']?.toString() ?? 'Erreur'),
        backgroundColor: result?['success'] == true
            ? AppColors.vertVif : AppColors.rouge,
      ));
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
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rouge),
            child: const Text('Confirmer le refus'),
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
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(result?['success'] == true
              ? 'Commande refusée.' : 'Erreur'),
          backgroundColor: result?['success'] == true
              ? AppColors.orange : AppColors.rouge,
        ));
      }
    }
  }
}
