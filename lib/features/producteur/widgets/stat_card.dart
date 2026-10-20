import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Indicateur du tableau de bord. Contenu adaptatif (valeur réduite au
/// besoin, libellés sur une ligne) : tient dans une cellule de grille même
/// sur petit écran.
class StatCard extends StatelessWidget {
  final String   emoji;
  final String   label;
  final String   valeur;
  final Color    couleur;
  final String?  sousTitre;
  final VoidCallback? onTap;

  const StatCard({
    required this.emoji,
    required this.label,
    required this.valeur,
    this.couleur   = AppColors.vertVif,
    this.sousTitre,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.blanc,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.grisBord),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36, height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valeur,
                    style: TextStyle(
                      fontSize:   24,
                      fontWeight: FontWeight.w800,
                      color:      couleur,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12, color: AppColors.noir,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (sousTitre != null)
                  Text(
                    sousTitre!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11, color: AppColors.grisTexte,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
