import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../providers/catalogue_provider.dart';
import '../providers/panier_provider.dart';
import '../widgets/produit_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/htg_text.dart';

class ProduitDetailScreen extends ConsumerWidget {
  final String slug;
  const ProduitDetailScreen({required this.slug, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitAsync = ref.watch(produitDetailProvider(slug));
    final catalogueAsync = ref.watch(catalogueProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      body: produitAsync.when(
        loading: () => const LoadingWidget(message: 'Chargement...'),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (produit) {
          if (produit == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Produit non trouvé'),
                  ElevatedButton(
                    onPressed: () => context.go('/acheteur/accueil'),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            );
          }

          final imageUrl = ImageUtils.imageUrl(produit.imagePrincipale);
          final produitsSimilaires = catalogueAsync.produits
              .where((p) =>
                  p.categorie?['slug'] ==
                      produit.categorie?['slug'] &&
                  p.slug != produit.slug)
              .take(4)
              .toList();
//﻿ACB1-07D2
          return CustomScrollView(
            slivers: [
              // App bar personnalisée
              SliverAppBar(
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.vertMenthe,
                          child: const Center(
                            child: Text('🌿',
                                style: TextStyle(fontSize: 80)),
                          ),
                        ),
                ),
              ),

              // Contenu
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // En-tête avec titre + prix
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Catégorie + featured
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              if (produit.categorie != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.vertVif
                                        .withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    produit.categorie!['nom']
                                            ?.toString() ??
                                        '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.vertVif,
                                    ),
                                  ),
                                ),
                              if (produit.isFeatured)
                                const Text('⭐ Vedette',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.jaune,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Nom
                          Text(
                            produit.nom,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.vertFonce,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Producteur
                          if (produit.producteur != null)
                            Text(
                              '🌾 ${produit.producteur!['nom'] ?? 'Producteur'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.grisTexte,
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Prix + Stock
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('Prix unitaire',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grisTexte,
                                    )),
                                  HtgText(produit.prixUnitaire,
                                    fontSize: 24),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      produit.stockReel > 0
                                          ? AppColors.vertVif
                                              .withValues(alpha: 0.15)
                                          : AppColors.rouge
                                              .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  produit.stockReel > 0
                                      ? '${produit.stockReel} en stock'
                                      : 'Rupture',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        produit.stockReel > 0
                                            ? AppColors.vertVif
                                            : AppColors.rouge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bouton ajouter
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Ajouter au panier'),
                        onPressed: produit.stockReel > 0
                            ? () async {
                                final err = await ref
                                    .read(panierProvider.notifier)
                                    .ajouter(produit.slug, 1);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        err == null
                                            ? '✅ Ajouté au panier'
                                            : '❌ $err',
                                      ),
                                      backgroundColor: err == null
                                          ? AppColors.vertVif
                                          : AppColors.rouge,
                                    ),
                                  );
                                  if (err == null) {
                                    context.go('/acheteur/panier');
                                  }
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vertFonce,
                          minimumSize: const Size(double.infinity, 54),
                        ),
                      ),
                    ),

                    // Description
                    if (produit.description != null &&
                        produit.description!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.vertFonce,
                              )),
                            const SizedBox(height: 8),
                            Text(
                              produit.description!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grisTexte,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Produits similaires
                    if (produitsSimilaires.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Produits similaires',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.vertFonce,
                              )),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection:
                                  Axis.horizontal,
                              child: Row(
                                children: produitsSimilaires
                                    .map((p) => Container(
                                          width: 160,
                                          margin: const EdgeInsets
                                              .only(right: 12),
                                          child: ProduitCard(
                                            produit: p,
                                            onTap: () => context
                                                .go(
                                              '/acheteur/produit/${p.slug}',
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

