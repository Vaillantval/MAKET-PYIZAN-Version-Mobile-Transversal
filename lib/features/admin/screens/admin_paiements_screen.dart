import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../providers/admin_paiements_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class AdminPaiementsScreen extends ConsumerWidget {
  const AdminPaiementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminPaiementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paiements à vérifier')),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('$e')),
        data:    (paiements) {
          if (paiements.isEmpty) {
            return const EmptyState(
              emoji:       '✅',
              titre:       'Aucun paiement en attente',
              description: 'Tous les paiements ont été traités.',
            );
          }

          return ListView.builder(
            padding:   const EdgeInsets.all(12),
            itemCount: paiements.length,
            itemBuilder: (_, i) {
              final p = paiements[i];
              return Container(
                margin:  const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:     Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.08),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payment,
                            color: AppColors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['reference'] as String? ?? '—',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.vertFonce,
                                  ),
                                ),
                                Text(
                                  p['commande_numero'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color:    AppColors.grisTexte,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            FormatUtils.htg(p['montant']),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize:   18,
                              color:      AppColors.vertFonce,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Détails + preuve
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _Row('Type',
                            p['type_label'] as String? ?? ''),
                          _Row('Statut',
                            p['statut_label'] as String? ?? ''),
                          _Row('Date',
                            FormatUtils.date(
                              p['created_at'] as String?)),

                          if (p['preuve_image'] != null) ...[
                            const SizedBox(height: 12),
                            const Text('🖼️ Preuve de paiement',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.vertFonce,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _voirPreuve(
                                context,
                                ImageUtils.imageUrl(
                                  p['preuve_image'] as String,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: ImageUtils.imageUrl(
                                    p['preuve_image'] as String,
                                  ),
                                  height: 120,
                                  width:  double.infinity,
                                  fit:    BoxFit.cover,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),

                          Row(children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.close),
                                label: const Text('Rejeter'),
                                onPressed: () => _traiter(
                                  context, ref,
                                  p['id'] as int, 'rejeter',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.rouge,
                                  side: const BorderSide(
                                      color: AppColors.rouge),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                label: const Text('Confirmer'),
                                onPressed: () => _traiter(
                                  context, ref,
                                  p['id'] as int, 'confirmer',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.vertVif,
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _voirPreuve(BuildContext ctx, String url) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: url),
        ),
      ),
    );
  }

  Future<void> _traiter(
    BuildContext ctx, WidgetRef ref,
    int id, String action,
  ) async {
    final success = await ref
        .read(adminPaiementsProvider.notifier)
        .traiter(id, action);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(success
            ? action == 'confirmer'
                ? '✅ Paiement confirmé !'
                : '❌ Paiement rejeté'
            : 'Erreur'),
        backgroundColor: success
            ? (action == 'confirmer'
                ? AppColors.vertVif
                : AppColors.orange)
            : AppColors.rouge,
      ));
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String valeur;
  const _Row(this.label, this.valeur);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: const TextStyle(
            color: AppColors.grisTexte, fontSize: 13,
          ),
        ),
        Text(valeur,
          style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13,
            color: AppColors.vertFonce,
          ),
        ),
      ],
    ),
  );
}
