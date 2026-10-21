import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../../../shared/ui/ui.dart';
import '../providers/admin_paiements_provider.dart';
import '../providers/admin_stats_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/admin_scaffold.dart';

/// Paiements manuels soumis (MonCash hors ligne, virement…) à vérifier.
class AdminPaiementsScreen extends ConsumerWidget {
  const AdminPaiementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminPaiementsProvider);

    return AdminScaffold(
      titre: 'Paiements',
      sousTitre: state.whenOrNull(data: (l) => '${l.length} à vérifier'),
      corps: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('$e')),
        data:    (paiements) {
          if (paiements.isEmpty) {
            return const EmptyState(
              icone:       Icons.task_alt_rounded,
              titre:       'Aucun paiement en attente',
              description: 'Tous les paiements ont été traités.',
            );
          }
          return RefreshIndicator(
            color: AppColors.vertFonce,
            onRefresh: () =>
                ref.read(adminPaiementsProvider.notifier).charger(),
            child: ListView.separated(
              padding:   const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: paiements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CartePaiement(
                paiement: paiements[i],
                onTraiter: (statut) =>
                    _traiter(context, ref, paiements[i]['id'] as int, statut),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _traiter(
    BuildContext ctx, WidgetRef ref, int id, String statut,
  ) async {
    final success = await ref
        .read(adminPaiementsProvider.notifier)
        .traiter(id, statut);
    if (success) ref.read(adminStatsProvider.notifier).charger();
    if (ctx.mounted) {
      afficherMessage(
        ctx,
        !success
            ? 'Le paiement n\'a pas pu être traité'
            : statut == 'confirme'
                ? 'Paiement confirmé'
                : 'Paiement rejeté',
        succes: success,
      );
    }
  }
}

class _CartePaiement extends StatelessWidget {
  final Map<String, dynamic> paiement;
  final ValueChanged<String> onTraiter;
  const _CartePaiement({required this.paiement, required this.onTraiter});

  @override
  Widget build(BuildContext context) {
    final p = paiement;
    final preuve = p['preuve_image'] as String?;

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TuileIcone(Icons.account_balance_wallet_outlined,
                  couleur: AppColors.violet, taille: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['reference'] as String? ?? '—',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14.5)),
                    Text(
                      'Commande ${p['commande_numero'] ?? '—'}',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.grisTexte),
                    ),
                  ],
                ),
              ),
              Text(FormatUtils.htg(p['montant']),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 4),
          LigneInfo(Icons.person_outline_rounded, 'Acheteur',
              (p['acheteur'] ?? '—').toString()),
          LigneInfo(Icons.payments_outlined, 'Mode',
              p['type_label'] as String? ?? '—'),
          if ((p['numero_expediteur'] ?? '').toString().isNotEmpty)
            LigneInfo(Icons.phone_iphone_rounded, 'Expéditeur',
                p['numero_expediteur'].toString()),
          if ((p['id_transaction'] ?? '').toString().isNotEmpty)
            LigneInfo(Icons.tag_rounded, 'Transaction',
                p['id_transaction'].toString()),
          LigneInfo(Icons.event_outlined, 'Soumis le',
              FormatUtils.dateHeure(p['created_at'] as String?)),
          if (preuve != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _voirPreuve(context, ImageUtils.imageUrl(preuve)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: ImageUtils.imageUrl(preuve),
                      height: 130,
                      width:  double.infinity,
                      fit:    BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        height: 130,
                        color: AppColors.surface2,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: AppColors.grisLeger),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8, bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.noir.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in_rounded,
                                size: 14, color: AppColors.blanc),
                            SizedBox(width: 4),
                            Text('Preuve de paiement',
                                style: TextStyle(
                                    color: AppColors.blanc, fontSize: 11.5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onTraiter('echoue'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rouge),
                child: const Text('Rejeter'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () => onTraiter('confirme'),
                child: const Text('Confirmer'),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  void _voirPreuve(BuildContext ctx, String url) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: url),
        ),
      ),
    );
  }
}
