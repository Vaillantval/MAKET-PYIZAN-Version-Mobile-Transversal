import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_utils.dart';

/// Pastille de filtre par catégorie (accueil, catalogue).
///
/// Visuel de la catégorie, par ordre de préférence : sa photo (`image`),
/// sinon son emoji (`emoji`, ou `icone` quand c'est un emoji — le backend y
/// met aussi des classes Font Awesome du site web, ignorées ici), sinon 🌿.
/// Sans [categorie] : pastille « Tout ».
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

  /// Emoji de la catégorie, ou 🌿 à défaut.
  static String emoji(Map<String, dynamic> cat) {
    for (final v in [cat['emoji'], cat['icone']]) {
      final s = (v ?? '').toString().trim();
      if (s.isNotEmpty && !_classeIcone.hasMatch(s)) return s;
    }
    return '🌿';
  }

  @override
  Widget build(BuildContext context) {
    final cat   = categorie;
    final nom   = cat == null ? 'Tout' : (cat['nom'] ?? '').toString();
    final image = cat == null ? '' : ImageUtils.imageUrl(cat['image'] as String?);
    final taille = compact ? 20.0 : 24.0;

    final Widget visuel = cat == null
        ? Icon(Icons.apps_rounded, size: taille - 4,
            color: selected ? Colors.white : AppColors.vertFonce)
        : image.isNotEmpty
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: image,
                  width: taille, height: taille,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Text(emoji(cat), style: TextStyle(fontSize: taille - 8)),
                ),
              )
            : Text(emoji(cat), style: TextStyle(fontSize: taille - 8));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: selected ? AppColors.vertFonce : Colors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.vertFonce : AppColors.grisBord,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 6 : 8, compact ? 4 : 6, compact ? 12 : 14, compact ? 4 : 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: taille, height: taille, child: Center(child: visuel)),
                const SizedBox(width: 6),
                Text(
                  nom,
                  style: TextStyle(
                    fontSize:   compact ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color:      selected ? Colors.white : AppColors.noir,
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
