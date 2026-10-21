import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_utils.dart';

/// Pastille de filtre par catégorie (accueil, catalogue).
///
/// Visuel de la catégorie, par ordre de préférence : sa photo (`image`),
/// sinon l'emoji saisi par l'équipe (`emoji`, ou `icone` quand c'est un
/// emoji — le backend y met aussi des classes Font Awesome du site web,
/// ignorées ici), sinon une icône neutre. Sans [categorie] : « Tout ».
class CategorieChip extends StatelessWidget {
  final Map<String, dynamic>? categorie;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const CategorieChip({
    required this.categorie,
    required this.selected,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  static final _classeIcone = RegExp(r'^[a-z0-9 _-]+$', caseSensitive: false);

  /// Emoji renseigné pour la catégorie, ou null.
  static String? emoji(Map<String, dynamic> cat) {
    for (final v in [cat['emoji'], cat['icone']]) {
      final s = (v ?? '').toString().trim();
      if (s.isNotEmpty && !_classeIcone.hasMatch(s)) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cat    = categorie;
    final nom    = cat == null ? 'Tout' : (cat['nom'] ?? '').toString();
    final image  = cat == null ? '' : ImageUtils.imageUrl(cat['image'] as String?);
    final taille = compact ? 24.0 : 28.0;
    final couleurIcone = selected ? AppColors.blanc : AppColors.grisTexte;

    Widget repli() {
      final e = cat == null ? null : emoji(cat);
      return e != null
          ? Text(e, style: TextStyle(fontSize: taille - 12))
          : Icon(cat == null ? Icons.apps_rounded : Icons.category_outlined,
              size: taille - 10, color: couleurIcone);
    }

    final Widget visuel = image.isNotEmpty
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: image,
              width: taille, height: taille,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => repli(),
            ),
          )
        : repli();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: selected ? AppColors.noir : AppColors.blanc,
        shape: StadiumBorder(
          side: selected
              ? BorderSide.none
              : const BorderSide(color: AppColors.grisBord),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 5, compact ? 12 : 14, 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: taille, height: taille,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.blanc.withValues(alpha: 0.14)
                        : AppColors.surface2,
                    shape: BoxShape.circle,
                  ),
                  child: visuel,
                ),
                const SizedBox(width: 8),
                Text(
                  nom,
                  style: TextStyle(
                    fontSize:   compact ? 12.5 : 13,
                    fontWeight: FontWeight.w600,
                    color:      selected ? AppColors.blanc : AppColors.noir,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
