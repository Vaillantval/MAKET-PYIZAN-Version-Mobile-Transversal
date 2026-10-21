import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/produit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/format_utils.dart';

/// Carte produit des grilles (accueil, catalogue, similaires).
///
/// Vignette sur fond gris clair, vendeur en petites capitales, nom et
/// prix. L'image occupe l'espace laissé par le texte (Expanded) : la carte
/// tient dans n'importe quelle cellule de grille.
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
    final imageUrl  = ImageUtils.imageUrl(produit.imagePrincipale);
    final enRupture = produit.stockReel <= 0;
    final vendeur   = (produit.producteur?['nom'] ?? '').toString();

    return Material(
      color: AppColors.blanc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.grisBord),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Vignette ───────────────────────────────────────
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit:      BoxFit.cover,
                              color:    enRupture ? Colors.white.withValues(alpha: 0.45) : null,
                              colorBlendMode: enRupture ? BlendMode.lighten : null,
                              placeholder: (_, __) => Shimmer.fromColors(
                                baseColor:      AppColors.surface2,
                                highlightColor: AppColors.grisClair,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (_, __, ___) => const _ImageVide(),
                            )
                          : const _ImageVide(),
                      // Rupture : le catalogue liste aussi les produits
                      // épuisés (après ceux en stock), non commandables
                      if (enRupture)
                        const Positioned(
                          top: 8, left: 8,
                          child: _Badge(texte: 'Rupture', fond: AppColors.noir,
                              texteCouleur: AppColors.blanc),
                        )
                      else if (produit.stockReel <= 5)
                        Positioned(
                          top: 8, left: 8,
                          child: _Badge(texte: '${produit.stockReel} restants',
                              fond: AppColors.blanc, texteCouleur: AppColors.rouge),
                        )
                      else if (produit.isFeatured)
                        const Positioned(
                          top: 8, left: 8,
                          child: _Badge(texte: 'Sélection', fond: AppColors.blanc,
                              texteCouleur: AppColors.noir),
                        ),
                      if (onAjouter != null && !enRupture)
                        Positioned(
                          right: 6, bottom: 6,
                          child: Material(
                            color: AppColors.noir,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onAjouter,
                              child: const Tooltip(
                                message: 'Ajouter au panier',
                                child: SizedBox(
                                  width: 34, height: 34,
                                  child: Icon(Icons.add_rounded,
                                      size: 20, color: AppColors.blanc),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Texte ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (vendeur.isNotEmpty)
                      Text(
                        vendeur.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5, color: AppColors.grisLeger,
                          fontWeight: FontWeight.w700, letterSpacing: .8,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      produit.nom,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600,
                        color: AppColors.noir, height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: FormatUtils.htg(produit.prixUnitaire),
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.noir,
                          ),
                        ),
                        TextSpan(
                          text: '  ${produit.uniteVenteLabel}',
                          style: const TextStyle(
                            fontSize: 11, color: AppColors.grisTexte,
                          ),
                        ),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageVide extends StatelessWidget {
  const _ImageVide();

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.surface2,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, size: 34, color: AppColors.grisLeger),
      );
}

class _Badge extends StatelessWidget {
  final String texte;
  final Color  fond;
  final Color  texteCouleur;
  const _Badge({required this.texte, required this.fond, required this.texteCouleur});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: fond,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(texte, style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700, color: texteCouleur)),
      );
}
