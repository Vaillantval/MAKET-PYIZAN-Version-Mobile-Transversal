import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/mes_produits_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class MesProduitsScreen extends ConsumerWidget {
  const MesProduitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mesProduitsProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Mes Produits'),
        actions: [
          IconButton(
            icon:      const Icon(Icons.add),
            tooltip:   'Nouveau produit',
            onPressed: () =>
                context.go('/producteur/produit/nouveau'),
          ),
        ],
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('Erreur : $e')),
        data:    (produits) {
          if (produits.isEmpty) {
            return EmptyState(
              emoji:       '🌿',
              titre:       'Aucun produit',
              description: 'Ajoutez votre premier produit !',
              boutonLabel: 'Ajouter un produit',
              onBouton: () =>
                  context.go('/producteur/produit/nouveau'),
            );
          }

          return RefreshIndicator(
            color:     AppColors.vertVif,
            onRefresh: () =>
                ref.read(mesProduitsProvider.notifier).charger(),
            child: ListView.builder(
              padding:   const EdgeInsets.all(12),
              itemCount: produits.length,
              itemBuilder: (_, i) {
                final p = produits[i];
                return Container(
                  margin:  const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
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
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: p.imagePrincipale != null
                            ? CachedNetworkImage(
                                imageUrl: ImageUtils.imageUrl(
                                    p.imagePrincipale),
                                width: 70, height: 70,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 70, height: 70,
                                color: AppColors.vertMenthe,
                                child: const Center(
                                  child: Text('🌿',
                                    style: TextStyle(fontSize: 30)),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Infos
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.nom,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize:   15,
                                color:      AppColors.vertFonce,
                              ),
                            ),
                            Text(
                              '${FormatUtils.htg(p.prixUnitaire)} / ${p.uniteVenteLabel}',
                              style: const TextStyle(
                                fontSize: 13,
                                color:    AppColors.grisTexte,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Stock badge
                            _StockBadge(stock: p.stockReel),
                          ],
                        ),
                      ),

                      // Actions
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.vertVif,
                            ),
                            onPressed: () => context.go(
                              '/producteur/produit/${p.slug}/modifier',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.rouge,
                            ),
                            onPressed: () =>
                                _confirmerSuppression(context, ref, p.slug),
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

  void _confirmerSuppression(
    BuildContext ctx, WidgetRef ref, String slug,
  ) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title:   const Text('Supprimer ce produit ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(mesProduitsProvider.notifier)
                  .supprimer(slug);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rouge),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;
  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (stock == 0) {
      color = AppColors.rouge;
      label = '🔴 Épuisé';
    } else if (stock <= 5) {
      color = AppColors.orange;
      label = '⚡ Stock faible : $stock';
    } else {
      color = AppColors.vertVif;
      label = '✅ En stock : $stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   11,
          fontWeight: FontWeight.w600,
          color:      color,
        ),
      ),
    );
  }
}
