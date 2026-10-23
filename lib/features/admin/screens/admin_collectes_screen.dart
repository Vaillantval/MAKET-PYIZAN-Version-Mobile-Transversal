import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/ui/ui.dart';
import '../providers/admin_collectes_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/admin_scaffold.dart';

class AdminCollectesScreen extends ConsumerStatefulWidget {
  const AdminCollectesScreen({super.key});

  @override
  ConsumerState<AdminCollectesScreen> createState() =>
      _AdminCollectesScreenState();
}

class _AdminCollectesScreenState extends ConsumerState<AdminCollectesScreen> {
  String _statut = 'planifiee';

  static const _filtres = [
    ('planifiee', 'Planifiées'),
    ('en_cours',  'En cours'),
    ('terminee',  'Terminées'),
    ('annulee',   'Annulées'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(adminCollectesProvider.notifier).charger(statut: _statut));
  }

  void _filtrer(String statut) {
    setState(() => _statut = statut);
    ref.read(adminCollectesProvider.notifier).charger(statut: statut);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCollectesProvider);

    return AdminScaffold(
      titre: 'Collectes',
      retour: '/admin/plus',
      filtres: PastillesFiltre(
        options: _filtres,
        valeur: _statut,
        onChanged: _filtrer,
      ),
      corps: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => ErreurChargement(e),
        data:    (collectes) {
          if (collectes.isEmpty) {
            return const EmptyState(
              icone: Icons.local_shipping_outlined, titre: 'Aucune collecte',
            );
          }
          return RefreshIndicator(
            color:     AppColors.vertFonce,
            onRefresh: () => ref
                .read(adminCollectesProvider.notifier)
                .charger(statut: _statut),
            child: ListView.separated(
              padding:   const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: collectes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _CarteCollecte(
                collecte: collectes[i],
                onStatut: (s) => _changer(context, collectes[i]['id'] as int, s),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _changer(BuildContext ctx, int id, String statut) async {
    final success = await ref
        .read(adminCollectesProvider.notifier)
        .changerStatut(id, statut); // recharge le filtre courant
    if (ctx.mounted) {
      afficherMessage(ctx,
          success ? 'Collecte mise à jour' : 'Mise à jour impossible',
          succes: success);
    }
  }
}

class _CarteCollecte extends StatelessWidget {
  final Map<String, dynamic> collecte;
  final ValueChanged<String> onStatut;
  const _CarteCollecte({required this.collecte, required this.onStatut});

  @override
  Widget build(BuildContext context) {
    final c = collecte;
    final statut = c['statut'] as String? ?? '';
    final style = StyleStatut.de(statut, libelle: c['statut_label'] as String?);
    final enRetard = c['est_en_retard'] == true;
    final lieu = [c['zone'], c['point'], c['commune']]
        .where((v) => (v ?? '').toString().isNotEmpty)
        .join(' · ');

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TuileIcone(Icons.local_shipping_outlined,
                  couleur: style.couleur, taille: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['reference'] as String? ?? '—',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14.5)),
                    Text(lieu.isEmpty ? '—' : lieu,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.grisTexte)),
                  ],
                ),
              ),
              enRetard
                  ? const PuceStatut('En retard', couleur: AppColors.rouge)
                  : style.puce(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 15, color: AppColors.grisLeger),
              const SizedBox(width: 4),
              Text(FormatUtils.date(c['date_planifiee'] as String?),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.grisTexte)),
              const SizedBox(width: 14),
              const Icon(Icons.person_outline_rounded,
                  size: 15, color: AppColors.grisLeger),
              const SizedBox(width: 4),
              Expanded(
                child: Text((c['collecteur'] ?? 'Sans agent').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.grisTexte)),
              ),
              Text('${c['nb_producteurs'] ?? 0} part.',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.grisTexte)),
            ],
          ),
          if (statut == 'planifiee' || statut == 'en_cours') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onStatut('annulee'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rouge),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => onStatut(
                        statut == 'planifiee' ? 'en_cours' : 'terminee'),
                    child: Text(statut == 'planifiee' ? 'Démarrer' : 'Terminer'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
