import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_collectes_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class AdminCollectesScreen extends ConsumerStatefulWidget {
  const AdminCollectesScreen({super.key});

  @override
  ConsumerState<AdminCollectesScreen> createState() =>
      _AdminCollectesScreenState();
}

class _AdminCollectesScreenState
    extends ConsumerState<AdminCollectesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _filtres = [
    ('planifiee',  '📅 Planifiées'),
    ('en_cours',   '🚛 En cours'),
    ('terminee',   '✅ Terminées'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filtres.length, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        ref.read(adminCollectesProvider.notifier)
            .charger(statut: _filtres[_tabs.index].$1);
      }
    });
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCollectesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collectes'),
        bottom: TabBar(
          controller:          _tabs,
          labelColor:          AppColors.jaune,
          unselectedLabelColor: Colors.white70,
          indicatorColor:      AppColors.jaune,
          tabs: _filtres.map((f) => Tab(text: f.$2)).toList(),
        ),
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('$e')),
        data:    (collectes) {
          if (collectes.isEmpty) {
            return const EmptyState(
              emoji: '🚛', titre: 'Aucune collecte',
            );
          }

          return RefreshIndicator(
            color:     AppColors.vertVif,
            onRefresh: () =>
                ref.read(adminCollectesProvider.notifier).charger(),
            child: ListView.builder(
              padding:   const EdgeInsets.all(12),
              itemCount: collectes.length,
              itemBuilder: (_, i) {
                final c = collectes[i];
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['reference'] as String? ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color:      AppColors.vertFonce,
                        ),
                      ),
                      Text(
                        c['collecteur'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color:    AppColors.grisTexte,
                        ),
                      ),
                      Text(
                        '📍 ${c['zone'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color:    AppColors.grisTexte,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (c['statut'] == 'planifiee')
                            _ActionBtn(
                              '🚛 Démarrer', AppColors.orange,
                              () => _action(context, ref,
                                  c['id'] as int, 'demarrer'),
                            ),
                          if (c['statut'] == 'en_cours')
                            _ActionBtn(
                              '✅ Terminer', AppColors.vertVif,
                              () => _action(context, ref,
                                  c['id'] as int, 'terminer'),
                            ),
                          if (c['statut'] != 'terminee')
                            _ActionBtn(
                              '❌ Annuler', AppColors.rouge,
                              () => _action(context, ref,
                                  c['id'] as int, 'annuler'),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _action(
    BuildContext ctx, WidgetRef ref,
    int id, String action,
  ) async {
    final success = await ref
        .read(adminCollectesProvider.notifier)
        .changerStatut(id, action);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(success ? '✅ Mis à jour !' : '❌ Erreur'),
        backgroundColor: success ? AppColors.vertVif : AppColors.rouge,
      ));
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  const _ActionBtn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed:   onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      side:            BorderSide(color: color),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      textStyle: const TextStyle(fontSize: 12),
    ),
    child: Text(label),
  );
}
