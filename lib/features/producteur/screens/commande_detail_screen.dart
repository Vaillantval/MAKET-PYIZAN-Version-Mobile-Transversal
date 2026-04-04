import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/commandes_producteur_provider.dart';
import '../../acheteur/widgets/commande_statut_badge.dart';
import '../../../shared/widgets/loading_widget.dart';

class CommandeDetailScreen extends ConsumerWidget {
  final String numero;
  const CommandeDetailScreen({required this.numero, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commandeProducteurDetailProvider(numero));

    return Scaffold(
      appBar: AppBar(
        title: Text('Commande $numero'),
        backgroundColor: AppColors.vertFonce,
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('Erreur : $e')),
        data:    (commande) {
          if (commande == null) {
            return const Center(child: Text('Commande introuvable.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Statut
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      commande.numeroCommande,
                      style: const TextStyle(
                        fontSize:   20,
                        fontWeight: FontWeight.w800,
                        color:      AppColors.vertFonce,
                      ),
                    ),
                    CommandeStatutBadge(commande.statut),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  FormatUtils.dateHeure(commande.createdAt),
                  style: const TextStyle(color: AppColors.grisTexte),
                ),
                const Divider(height: 28),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                      style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(
                      FormatUtils.htg(commande.total),
                      style: const TextStyle(
                        fontSize:   20,
                        fontWeight: FontWeight.w900,
                        color:      AppColors.vertFonce,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Paiement
                _InfoTile('💳 Paiement', commande.methodePaiement),
                if (commande.modeLivraison != null)
                  _InfoTile('🚚 Livraison', commande.modeLivraison!),
                if (commande.adresseLivraison != null)
                  _InfoTile('📍 Adresse', commande.adresseLivraison!),
                if (commande.notesAcheteur?.isNotEmpty == true)
                  _InfoTile('📝 Notes', commande.notesAcheteur!),
                const Divider(height: 28),

                // Articles
                if (commande.details.isNotEmpty) ...[
                  const Text('Articles',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize:   16,
                      color:      AppColors.vertFonce,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...commande.details.map((d) => _ArticleTile(detail: d)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String valeur;
  const _InfoTile(this.label, this.valeur);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
            style: const TextStyle(
              color: AppColors.grisTexte, fontSize: 13)),
        ),
        Expanded(
          child: Text(valeur,
            style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13,
              color: AppColors.vertFonce,
            )),
        ),
      ],
    ),
  );
}

class _ArticleTile extends StatelessWidget {
  final Map<String, dynamic> detail;
  const _ArticleTile({required this.detail});

  @override
  Widget build(BuildContext context) => Container(
    margin:  const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(10),
      border:       Border.all(color: const Color(0xFFEEEEEE)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail['produit_nom']?.toString() ?? '—',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.vertFonce,
                ),
              ),
              Text(
                'x${detail['quantite']}  ${detail['unite_vente'] ?? ''}',
                style: const TextStyle(
                  fontSize: 12, color: AppColors.grisTexte),
              ),
            ],
          ),
        ),
        Text(
          FormatUtils.htg(detail['sous_total']),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.vertFonce,
          ),
        ),
      ],
    ),
  );
}
