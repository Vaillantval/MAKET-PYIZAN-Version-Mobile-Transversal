import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_producteurs_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class AdminProducteursScreen extends ConsumerStatefulWidget {
  const AdminProducteursScreen({super.key});

  @override
  ConsumerState<AdminProducteursScreen> createState() =>
      _AdminProducteursScreenState();
}

class _AdminProducteursScreenState
    extends ConsumerState<AdminProducteursScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _filtres = [
    ('',           'Tous'),
    ('en_attente', '⏳ En attente'),
    ('actif',      '✅ Actifs'),
    ('suspendu',   '🚫 Suspendus'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filtres.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Producteurs'),
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
            _ProducteursList(statut: f.$1)).toList(),
      ),
    );
  }
}

class _ProducteursList extends ConsumerWidget {
  final String statut;
  const _ProducteursList({required this.statut});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminProducteursProvider);

    final produits = state.whenOrNull(
      data: (list) => statut.isEmpty
          ? list
          : list.where((p) => p['statut'] == statut).toList(),
    ) ?? [];

    return state.when(
      loading: () => const LoadingWidget(),
      error:   (e, _) => Center(child: Text('$e')),
      data:    (_) {
        if (produits.isEmpty) {
          return const EmptyState(
            emoji: '🌾', titre: 'Aucun producteur',
          );
        }

        return RefreshIndicator(
          color:     AppColors.vertVif,
          onRefresh: () =>
              ref.read(adminProducteursProvider.notifier).charger(),
          child: ListView.builder(
            padding:   const EdgeInsets.all(12),
            itemCount: produits.length,
            itemBuilder: (_, i) {
              final p = produits[i];
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
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p['nom_complet'] as String? ?? '—',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize:   15,
                              color:      AppColors.vertFonce,
                            ),
                          ),
                        ),
                        _StatutBadge(
                            p['statut'] as String? ?? ''),
                      ],
                    ),
                    Text(
                      p['code_producteur'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color:    AppColors.grisTexte,
                      ),
                    ),
                    Text(
                      '📍 ${p['commune'] ?? ''} — '
                      '${p['departement'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color:    AppColors.grisTexte,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (p['statut'] == 'en_attente')
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _changerStatut(
                              context, ref,
                              p['id'] as int, 'suspendu',
                            ),
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
                            onPressed: () => _changerStatut(
                              context, ref,
                              p['id'] as int, 'actif',
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.vertVif),
                            child: const Text('Valider'),
                          ),
                        ),
                      ])
                    else
                      Wrap(
                        spacing: 8,
                        children: [
                          if (p['statut'] != 'actif')
                            _ActionChip(
                              '✅ Activer',
                              AppColors.vertVif,
                              () => _changerStatut(
                                context, ref,
                                p['id'] as int, 'actif',
                              ),
                            ),
                          if (p['statut'] != 'suspendu')
                            _ActionChip(
                              '🚫 Suspendre',
                              AppColors.rouge,
                              () => _changerStatut(
                                context, ref,
                                p['id'] as int, 'suspendu',
                              ),
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
    );
  }

  Future<void> _changerStatut(
    BuildContext ctx, WidgetRef ref,
    int id, String statut,
  ) async {
    final success = await ref
        .read(adminProducteursProvider.notifier)
        .changerStatut(id, statut);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(success
            ? '✅ Statut mis à jour !'
            : '❌ Erreur'),
        backgroundColor:
            success ? AppColors.vertVif : AppColors.rouge,
      ));
    }
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;
  const _StatutBadge(this.statut);

  @override
  Widget build(BuildContext context) {
    final map = {
      'actif':      (AppColors.vertVif,  '✅ Actif'),
      'en_attente': (AppColors.orange,   '⏳ En attente'),
      'suspendu':   (AppColors.rouge,    '🚫 Suspendu'),
      'inactif':    (AppColors.grisTexte,'⬛ Inactif'),
    };
    final (color, label) =
        map[statut] ?? (AppColors.grisTexte, statut);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  const _ActionChip(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => ActionChip(
    label:       Text(label),
    onPressed:   onTap,
    backgroundColor: color.withOpacity(0.1),
    side:        BorderSide(color: color.withOpacity(0.3)),
    labelStyle:  TextStyle(
      color: color, fontWeight: FontWeight.w600, fontSize: 12,
    ),
  );
}
