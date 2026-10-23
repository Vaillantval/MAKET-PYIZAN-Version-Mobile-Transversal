import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/produit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/favoris_provider.dart';

/// Carte produit des grilles (accueil, catalogue, similaires).
///
/// Vignette sur fond sauge (badge de statut ou de remise, cœur favori),
/// vendeur en petites capitales, nom, prix (barré si promotion) et bouton
/// panier carré arrondi (cf. maquettes). L'image occupe l'espace laissé
/// par le texte (Expanded) : la carte tient dans n'importe quelle cellule.
class ProduitCard extends ConsumerWidget {
  final Produit      produit;
  final VoidCallback onTap;
  /// Reçoit le contexte du bouton « + » (point de départ de l'animation
  /// vers le panier).
  final void Function(BuildContext bouton)? onAjouter;

  const ProduitCard({
    required this.produit,
    required this.onTap,
    this.onAjouter,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favori    = ref.watch(favorisProvider).contains(produit.id);
    final remise    = produit.remisePourcent;
    final imageUrl  = ImageUtils.imageUrl(produit.imagePrincipale);
    final enRupture = produit.stockReel <= 0;
    final vendeur   = (produit.producteur?['nom'] ?? '').toString();

    return Material(
      color: AppColors.blanc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(15),
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
                      else if (remise != null)
                        Positioned(
                          top: 8, left: 8,
                          child: _Badge(texte: '-$remise%',
                              fond: AppColors.vertVif, texteCouleur: AppColors.blanc),
                        )
                      else if (produit.isFeatured)
                        const Positioned(
                          top: 8, left: 8,
                          child: _Badge(texte: 'Sélection', fond: AppColors.blanc,
                              texteCouleur: AppColors.noir),
                        ),
                      Positioned(
                        top: 6, right: 6,
                        child: Material(
                          color: AppColors.blanc,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => ref
                                .read(favorisProvider.notifier)
                                .basculer(produit.id),
                            child: Tooltip(
                              message: favori
                                  ? 'Retirer des favoris'
                                  : 'Ajouter aux favoris',
                              child: SizedBox(
                                width: 30, height: 30,
                                child: Icon(
                                  favori
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 17,
                                  color: favori ? AppColors.rouge : AppColors.noir,
                                ),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (remise != null)
                                Text(
                                  FormatUtils.htg(produit.prixOriginal!),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.grisLeger,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
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
                        if (onAjouter != null && !enRupture) ...[
                          const SizedBox(width: 6),
                          Builder(
                            builder: (bouton) => Material(
                              color: AppColors.noir,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => onAjouter!(bouton),
                                child: const Tooltip(
                                  message: 'Ajouter au panier',
                                  child: SizedBox(
                                    width: 32, height: 32,
                                    child: Icon(Icons.shopping_bag_outlined,
                                        size: 17, color: AppColors.blanc),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
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
