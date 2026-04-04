import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../providers/panier_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/htg_text.dart';

class PanierScreen extends ConsumerWidget {
  const PanierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panierState = ref.watch(panierProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          panierState.whenOrNull(
            data: (p) => p.items.isNotEmpty
                ? TextButton(
                    onPressed: () => _confirmerVider(context, ref),
                    child: const Text(
                      'Vider',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : null,
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: panierState.when(
        loading: () => const LoadingWidget(message: 'Chargement du panier...'),
        error:   (e, _) => Center(child: Text('Erreur : $e')),
        data:    (panier) {
          if (panier.items.isEmpty) {
            return EmptyState(
              emoji:       '🛒',
              titre:       'Votre panier est vide',
              description: 'Ajoutez des produits depuis le catalogue.',
              boutonLabel: 'Voir le catalogue',
              onBouton:    () => context.go('/acheteur/catalogue'),
            );
          }

          return Column(
            children: [
              // Liste des articles
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: panier.items.length,
                  itemBuilder: (_, i) {
                    final item = panier.items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:        Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:     Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.image != null
                                ? CachedNetworkImage(
                                    imageUrl: ImageUtils.imageUrl(item.image),
                                    width: 64, height: 64,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 64, height: 64,
                                    color: AppColors.vertMenthe,
                                    child: const Center(
                                      child: Text('🌿',
                                        style: TextStyle(fontSize: 28)),
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
                                  item.nom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.vertFonce,
                                  ),
                                ),
                                Text(
                                  item.producteurNom,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grisTexte,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                HtgText(item.prixUnitaire,
                                  fontSize: 13,
                                  suffix:   ' / ${item.uniteVente}',
                                ),
                              ],
                            ),
                          ),

                          // Quantité
                          Column(
                            children: [
                              _QuantiteControl(
                                quantite:    item.quantite,
                                stockMax:    item.stockReel,
                                onIncrement: () => ref
                                    .read(panierProvider.notifier)
                                    .modifier(item.slug, item.quantite + 1),
                                onDecrement: () {
                                  if (item.quantite <= 1) {
                                    ref.read(panierProvider.notifier)
                                        .retirer(item.slug);
                                  } else {
                                    ref.read(panierProvider.notifier)
                                        .modifier(item.slug, item.quantite - 1);
                                  }
                                },
                              ),
                              const SizedBox(height: 4),
                              HtgText(item.sousTotal, fontSize: 13),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Récapitulatif + Bouton commander
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color:     Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset:    const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Producteurs
                    if (panier.producteurs.length > 1)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:        AppColors.jauneClair,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.jaune),
                        ),
                        child: Text(
                          'ℹ️ ${panier.producteurs.length} producteurs — '
                          '${panier.producteurs.length} commandes seront créées.',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${panier.nbArticles} article${panier.nbArticles > 1 ? 's' : ''}',
                          style: const TextStyle(color: AppColors.grisTexte),
                        ),
                        HtgText(panier.total, fontSize: 20),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      icon:      const Icon(Icons.shopping_bag_outlined),
                      label:     const Text('Passer la commande'),
                      onPressed: () => context.go('/acheteur/checkout'),
                      style:     ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vertFonce,
                        minimumSize:     const Size(double.infinity, 52),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmerVider(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vider le panier ?'),
        content: const Text('Tous les articles seront supprimés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(panierProvider.notifier).vider();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rouge,
            ),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }
}

class _QuantiteControl extends StatelessWidget {
  final int quantite;
  final int stockMax;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantiteControl({
    required this.quantite,
    required this.stockMax,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _Btn(
        icon:      Icons.remove,
        onTap:     onDecrement,
        color:     quantite <= 1 ? AppColors.rouge : AppColors.vertVif,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          '$quantite',
          style: const TextStyle(
            fontWeight: FontWeight.w800, fontSize: 16,
          ),
        ),
      ),
      _Btn(
        icon:      Icons.add,
        onTap:     quantite < stockMax ? onIncrement : null,
        color:     AppColors.vertVif,
      ),
    ],
  );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  const _Btn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color:        onTap != null ? color.withValues(alpha: .15) : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon,
        size:  16,
        color: onTap != null ? color : Colors.grey,
      ),
    ),
  );
}
