import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/produit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/format_utils.dart';

/// Carte produit des grilles (accueil, catalogue, similaires).
///
/// L'image occupe l'espace laissé par le texte (Expanded) plutôt qu'une
/// hauteur fixe : la carte tient dans n'importe quelle cellule de grille,
/// quels que soient la largeur d'écran et la longueur du nom.
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

    return Material(
      color: AppColors.blanc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.grisBord),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image + badges ─────────────────────────────────
            Expanded(
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
                            baseColor:      AppColors.grisBord,
                            highlightColor: AppColors.grisClair,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) => const _ImageVide(),
                        )
                      : const _ImageVide(),
                  if (produit.isFeatured)
                    const Positioned(
                      top: 8, left: 8,
                      child: _Badge(texte: 'Vedette', icone: Icons.star_rounded,
                          fond: AppColors.jaune, texteCouleur: AppColors.noir),
                    ),
                  // Rupture : le catalogue liste aussi les produits épuisés
                  // (après ceux en stock) — visibles mais non commandables
                  if (enRupture)
                    const Positioned(
                      top: 8, right: 8,
                      child: _Badge(texte: 'Rupture', fond: AppColors.noir,
                          texteCouleur: AppColors.blanc),
                    )
                  else if (produit.stockReel <= 5)
                    Positioned(
                      top: 8, right: 8,
                      child: _Badge(texte: '${produit.stockReel} restants',
                          fond: AppColors.rouge, texteCouleur: AppColors.blanc),
                    ),
                ],
              ),
            ),

            // ── Contenu ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (produit.categorie != null)
                    Text(
                      (produit.categorie!['nom']?.toString() ?? '').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10, color: AppColors.vertVif,
                        fontWeight: FontWeight.w700, letterSpacing: .6,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    produit.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700,
                      color: AppColors.noir, height: 1.2,
                    ),
                  ),
                  if (produit.producteur != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 12, color: AppColors.grisTexte),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${produit.producteur!['commune'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.grisTexte),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: FormatUtils.htg(produit.prixUnitaire),
                              style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: AppColors.vertFonce,
                              ),
                            ),
                            TextSpan(
                              text: ' / ${produit.uniteVenteLabel}',
                              style: const TextStyle(
                                fontSize: 10.5, color: AppColors.grisTexte,
                              ),
                            ),
                          ]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onAjouter != null && !enRupture)
                        SizedBox(
                          width: 34, height: 34,
                          child: IconButton.filled(
                            onPressed: onAjouter,
                            padding: EdgeInsets.zero,
                            tooltip: 'Ajouter au panier',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.vertFonce,
                              foregroundColor: AppColors.blanc,
                            ),
                            icon: const Icon(Icons.add_rounded, size: 20),
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

class _ImageVide extends StatelessWidget {
  const _ImageVide();

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.vertMenthe,
        alignment: Alignment.center,
        child: const Icon(Icons.eco_outlined, size: 40, color: AppColors.vertMoyen),
      );
}

class _Badge extends StatelessWidget {
  final String    texte;
  final IconData? icone;
  final Color     fond;
  final Color     texteCouleur;
  const _Badge({required this.texte, required this.fond,
      required this.texteCouleur, this.icone});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: fond,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 12, color: texteCouleur),
              const SizedBox(width: 2),
            ],
            Text(texte, style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: texteCouleur)),
          ],
        ),
      );
}
