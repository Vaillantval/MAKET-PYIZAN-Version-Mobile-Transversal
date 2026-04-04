import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_commandes_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/statut_selector.dart';

class AdminCommandesScreen extends ConsumerStatefulWidget {
  const AdminCommandesScreen({super.key});

  @override
  ConsumerState<AdminCommandesScreen> createState() =>
      _AdminCommandesScreenState();
}

class _AdminCommandesScreenState
    extends ConsumerState<AdminCommandesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _filtres = [
    ('',              'Toutes'),
    ('en_attente',    '⏳ En attente'),
    ('en_preparation','🔧 En préparation'),
    ('livree',        '✅ Livrées'),
    ('annulee',       '❌ Annulées'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filtres.length, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes'),
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
            _CommandesList(statut: f.$1)).toList(),
      ),
    );
  }
}

class _CommandesList extends ConsumerWidget {
  final String statut;
  const _CommandesList({required this.statut});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminCommandesProvider);

    final commandes = state.whenOrNull(
      data: (list) => statut.isEmpty
          ? list
          : list.where((c) => c['statut'] == statut).toList(),
    ) ?? [];

    return state.when(
      loading: () => const LoadingWidget(),
      error:   (e, _) => Center(child: Text('$e')),
      data:    (_) {
        if (commandes.isEmpty) {
          return const EmptyState(
            emoji: '📦', titre: 'Aucune commande',
          );
        }

        return RefreshIndicator(
          color:     AppColors.vertVif,
          onRefresh: () =>
              ref.read(adminCommandesProvider.notifier).charger(),
          child: ListView.builder(
            padding:   const EdgeInsets.all(12),
            itemCount: commandes.length,
            itemBuilder: (_, i) {
              final c = commandes[i];
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['numero_commande'] as String? ?? '—',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color:      AppColors.vertFonce,
                            ),
                          ),
                          Text(
                            c['acheteur'] as String? ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color:    AppColors.grisTexte,
                            ),
                          ),
                          Text(
                            c['total'] as String? ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color:      AppColors.vertVif,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _changerStatut(
                        context, ref,
                        c['numero_commande'] as String? ?? '',
                      ),
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
    BuildContext ctx, WidgetRef ref, String numero,
  ) async {
    final statut = await showStatutSelector(
      ctx,
      titre: 'Changer le statut',
      options: const [
        ('en_preparation', '🔧 En préparation'),
        ('pret',           '📦 Prêt'),
        ('livree',         '✅ Livrée'),
        ('annulee',        '❌ Annulée'),
      ],
    );
    if (statut == null || !ctx.mounted) return;

    final success = await ref
        .read(adminCommandesProvider.notifier)
        .changerStatut(numero, statut);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(success ? '✅ Statut mis à jour !' : '❌ Erreur'),
        backgroundColor: success ? AppColors.vertVif : AppColors.rouge,
      ));
    }
  }
}
