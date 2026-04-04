import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/commande_provider.dart';
import '../widgets/commande_statut_badge.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/htg_text.dart';

class CommandeDetailScreen extends ConsumerWidget {
  final String numero;
  const CommandeDetailScreen({required this.numero, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandeAsync = ref.watch(commandeDetailProvider(numero));

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: Text('Commande $numero'),
      ),
      body: commandeAsync.when(
        loading: () => const LoadingWidget(message: 'Chargement...'),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (commande) {
          if (commande == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Commande non trouvée'),
                  ElevatedButton(
                    onPressed: () =>
                        context.go('/acheteur/commandes'),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // En-tête commande
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Commande #${commande.numeroCommande}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.vertFonce,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                FormatUtils.date(
                                  commande.createdAt ?? '',
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grisTexte,
                                ),
                              ),
                            ],
                          ),
                          CommandeStatutBadge(commande.statut),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.vertFonce,
                            ),
                          ),
                          HtgText(commande.total, fontSize: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Producteur & Articles
              SliverToBoxAdapter(
                child: Container(
                  margin:
                      const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌾 Producteur',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.vertFonce,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        commande.producteur,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.noir,
                        ),
                      ),
                      if (commande.details.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Articles',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.vertFonce,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...commande.details.map((item) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          item['nom']
                                                  ?.toString() ??
                                              'Produit',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: AppColors
                                                .vertFonce,
                                          ),
                                        ),
                                        Text(
                                          'x${item['quantite'] ?? 0}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors
                                                .grisTexte,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    FormatUtils.htg(
                                      item['sous_total'] ?? 0,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w600,
                                      color:
                                          AppColors.vertFonce,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ),

              // Infos livraison
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📍 Livraison',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.vertFonce,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Adresse : ${commande.adresseLivraison ?? "Non spécifiée"}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.noir,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mode : ${commande.modeLivraison ?? "-"}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grisTexte,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Paiement : ${commande.statutPaiement}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grisTexte,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverPadding(
                padding: EdgeInsets.only(bottom: 80),
              ),
            ],
          );
        },
      ),
    );
  }
}
