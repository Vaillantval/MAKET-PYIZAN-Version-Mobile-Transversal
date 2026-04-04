import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/produit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/format_utils.dart';

class ProduitCard extends StatelessWidget {
  final Produit      produit;
  final VoidCallback onTap;
  final VoidCallback? onAjouter;

  const ProduitCard({
    required this.produit,
    required this.onTap,
    this.onAjouter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ImageUtils.imageUrl(produit.imagePrincipale);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color:       Colors.black.withValues(alpha: 0.07),
              blurRadius:  8,
              offset:      const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          height:   140,
                          width:    double.infinity,
                          fit:      BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor:      Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 140,
                              color:  Colors.white,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 140,
                            color:  AppColors.vertMenthe,
                            child:  const Center(
                              child: Text('🌿', style: TextStyle(fontSize: 40)),
                            ),
                          ),
                        )
                      : Container(
                          height: 140,
                          color:  AppColors.vertMenthe,
                          child:  const Center(
                            child: Text('🌿', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                ),
                // Badge featured
                if (produit.isFeatured)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:        AppColors.jaune,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '⭐ Vedette',
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.noir,
                        ),
                      ),
                    ),
                  ),
                // Badge stock faible
                if (produit.stockReel <= 5 && produit.stockReel > 0)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:        AppColors.rouge,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⚡ ${produit.stockReel} restants',
                        style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie
                  if (produit.categorie != null)
                    Text(
                      produit.categorie!['nom']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 10, color: AppColors.vertVif,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .3,
                      ),
                    ),
                  const SizedBox(height: 2),

                  // Nom
                  Text(
                    produit.nom,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.vertFonce,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Producteur
                  if (produit.producteur != null)
                    Text(
                      '📍 ${produit.producteur!['commune'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 11, color: AppColors.grisTexte,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Prix + bouton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FormatUtils.htg(produit.prixUnitaire),
                            style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: AppColors.vertFonce,
                            ),
                          ),
                          Text(
                            '/ ${produit.uniteVenteLabel}',
                            style: const TextStyle(
                              fontSize: 10, color: AppColors.grisTexte,
                            ),
                          ),
                        ],
                      ),
                      if (onAjouter != null)
                        GestureDetector(
                          onTap: onAjouter,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:        AppColors.vertVif,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
