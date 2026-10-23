import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/commandes_producteur_provider.dart';
import '../../acheteur/widgets/commande_statut_badge.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/ui/ui.dart';

class CommandeDetailScreen extends ConsumerWidget {
  final String numero;
  const CommandeDetailScreen({required this.numero, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commandeProducteurDetailProvider(numero));

    return Scaffold(
      appBar: AppBar(title: Text(numero)),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => ErreurChargement(e),
        data:    (commande) {
          if (commande == null) {
            return const EmptyState(
              icone: Icons.receipt_long_outlined,
              titre: 'Commande introuvable',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            FormatUtils.dateHeure(commande.createdAt),
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.grisTexte),
                          ),
                        ),
                        CommandeStatutBadge(commande.statut),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.grisTexte)),
                    Text(FormatUtils.htg(commande.total),
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6)),
                  ],
                ),
              ),
              const Surtitre('Livraison et paiement'),
              Surface(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    LigneInfo(Icons.payments_outlined, 'Paiement',
                        commande.methodePaiement),
                    if (commande.modeLivraison != null)
                      LigneInfo(Icons.local_shipping_outlined, 'Livraison',
                          commande.modeLivraison!),
                    if (commande.adresseLivraison != null)
                      LigneInfo(Icons.place_outlined, 'Adresse',
                          commande.adresseLivraison!),
                    if (commande.notesAcheteur?.isNotEmpty == true)
                      LigneInfo(Icons.notes_rounded, 'Notes',
                          commande.notesAcheteur!),
                  ],
                ),
              ),
              if (commande.details.isNotEmpty) ...[
                Surtitre('Articles (${commande.details.length})'),
                GroupeLignes([
                  for (final d in commande.details) _ArticleTile(detail: d),
                ]),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final Map<String, dynamic> detail;
  const _ArticleTile({required this.detail});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        const TuileIcone(Icons.inventory_2_outlined,
            couleur: AppColors.grisTexte, taille: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail['produit_nom']?.toString() ?? '—',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                // quantite/unite_vente sont toujours dans l'unité de base
                // du produit ; quantite_choisie/unite_choisie reflètent ce
                // que l'acheteur a réellement sélectionné.
                '× ${detail['quantite_choisie'] ?? detail['quantite']}  '
                '${detail['unite_choisie'] ?? detail['unite_vente'] ?? ''}',
                style: const TextStyle(
                  fontSize: 12, color: AppColors.grisTexte),
              ),
            ],
          ),
        ),
        Text(
          FormatUtils.htg(detail['sous_total']),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
