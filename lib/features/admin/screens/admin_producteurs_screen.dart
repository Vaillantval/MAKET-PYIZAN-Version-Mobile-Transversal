import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../shared/ui/ui.dart';
import '../providers/admin_producteurs_provider.dart';
import '../providers/admin_stats_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/admin_scaffold.dart';

/// Entreprises vendeuses (ex-« producteurs ») : validation et suspension.
class AdminProducteursScreen extends ConsumerStatefulWidget {
  const AdminProducteursScreen({super.key});

  @override
  ConsumerState<AdminProducteursScreen> createState() =>
      _AdminProducteursScreenState();
}

class _AdminProducteursScreenState
    extends ConsumerState<AdminProducteursScreen> {
  String _statut = '';

  static const _filtres = [
    ('',           'Toutes'),
    ('en_attente', 'À valider'),
    ('actif',      'Actives'),
    ('suspendu',   'Suspendues'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProducteursProvider);

    return AdminScaffold(
      titre: 'Entreprises',
      sousTitre: state.whenOrNull(data: (l) => '${l.length} enregistrée(s)'),
      filtres: PastillesFiltre(
        options: _filtres,
        valeur: _statut,
        onChanged: (v) => setState(() => _statut = v),
      ),
      corps: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('$e')),
        data:    (liste) {
          final entreprises = _statut.isEmpty
              ? liste
              : liste.where((p) => p['statut'] == _statut).toList();
          if (entreprises.isEmpty) {
            return const EmptyState(
              icone: Icons.storefront_outlined,
              titre: 'Aucune entreprise',
            );
          }
          return RefreshIndicator(
            color:     AppColors.vertFonce,
            onRefresh: () =>
                ref.read(adminProducteursProvider.notifier).charger(),
            child: ListView.separated(
              padding:   const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: entreprises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _CarteEntreprise(
                entreprise: entreprises[i],
                onStatut: (s) =>
                    _changerStatut(context, entreprises[i]['id'] as int, s),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _changerStatut(BuildContext ctx, int id, String statut) async {
    final success = await ref
        .read(adminProducteursProvider.notifier)
        .changerStatut(id, statut);
    if (success) ref.read(adminStatsProvider.notifier).charger();
    if (ctx.mounted) {
      afficherMessage(ctx,
          success ? 'Statut mis à jour' : 'Le statut n\'a pas pu être changé',
          succes: success);
    }
  }
}

class _CarteEntreprise extends StatelessWidget {
  final Map<String, dynamic> entreprise;
  final ValueChanged<String> onStatut;
  const _CarteEntreprise({required this.entreprise, required this.onStatut});

  @override
  Widget build(BuildContext context) {
    final p = entreprise;
    final statut = p['statut'] as String? ?? '';
    final style = StyleStatut.de(statut, libelle: p['statut_label'] as String?);
    final nom = (p['nom_affiche'] ?? p['nom'] ?? p['nom_complet'] ?? '—').toString();
    final logo = (p['logo_url'] ?? '').toString();
    final lieu = [p['commune'], p['departement_label'] ?? p['departement']]
        .where((v) => (v ?? '').toString().isNotEmpty)
        .join(', ');

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              logo.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: ImageUtils.imageUrl(logo),
                        width: 44, height: 44, fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const TuileIcone(Icons.storefront_outlined, taille: 44),
                      ),
                    )
                  : const TuileIcone(Icons.storefront_outlined,
                      couleur: AppColors.bleu, taille: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(
                      [p['type_label'], p['code_producteur']]
                          .where((v) => (v ?? '').toString().isNotEmpty)
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.grisTexte),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              style.puce(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (lieu.isNotEmpty) ...[
                const Icon(Icons.place_outlined,
                    size: 15, color: AppColors.grisLeger),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(lieu,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.grisTexte)),
                ),
              ] else
                const Spacer(),
              if (p['nb_produits'] != null)
                Text('${p['nb_produits']} produit(s)',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.grisTexte)),
            ],
          ),
          if (statut == 'en_attente') ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onStatut('suspendu'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.rouge),
                  child: const Text('Refuser'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => onStatut('actif'),
                  child: const Text('Valider'),
                ),
              ),
            ]),
          ] else ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: statut == 'actif'
                  ? TextButton.icon(
                      onPressed: () => onStatut('suspendu'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.rouge),
                      icon: const Icon(Icons.block_rounded, size: 18),
                      label: const Text('Suspendre'),
                    )
                  : TextButton.icon(
                      onPressed: () => onStatut('actif'),
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 18),
                      label: const Text('Activer'),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
