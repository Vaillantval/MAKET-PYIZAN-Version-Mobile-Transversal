import 'package:flutter/material.dart';

/// Palette MaketLakay.
///
/// Interface sobre : fond gris très clair, cartes blanches à bordure fine,
/// texte encre, actions principales en noir. Le vert de la marque sert
/// d'accent (sélection, navigation, indicateurs) ; les tableaux de bord
/// utilisent des paires couleur / teinte pastel pour les indicateurs.
class AppColors {
  // Marque (logo « ML » : vert forêt + orange)
  static const Color vertFonce  = Color(0xFF0B4A24);
  static const Color vertVif    = Color(0xFF1F8A4C);
  static const Color vertMoyen  = Color(0xFF6CB87A);
  static const Color vertMenthe = Color(0xFFE8F4EC);
  static const Color jaune      = Color(0xFFF26B1D); // orange du logo
  static const Color jauneClair = Color(0xFFFFF1E8);

  // Neutres
  static const Color blanc      = Color(0xFFFFFFFF);
  static const Color noir       = Color(0xFF141416); // encre : textes, boutons
  static const Color grisClair  = Color(0xFFF6F6F8); // fond des écrans
  static const Color surface2   = Color(0xFFF1F1F4); // vignettes, pastilles
  static const Color grisTexte  = Color(0xFF6E6E78);
  static const Color grisLeger  = Color(0xFFA3A3AD); // libellés discrets
  static const Color grisBord   = Color(0xFFEBEBEF);

  // Couleurs d'état / d'indicateurs (fort + teinte)
  static const Color rouge       = Color(0xFFD94141);
  static const Color rougeTeinte = Color(0xFFFDEDED);
  static const Color orange      = Color(0xFFE9862B);
  static const Color orangeTeinte= Color(0xFFFFF2E6);
  static const Color bleu        = Color(0xFF3B78E7);
  static const Color bleuTeinte  = Color(0xFFEBF2FE);
  static const Color violet      = Color(0xFF7657E8);
  static const Color violetTeinte= Color(0xFFF0EDFD);
  static const Color vertTeinte  = Color(0xFFE9F6EE);
  static const Color ambre       = Color(0xFFD9A11A);
  static const Color ambreTeinte = Color(0xFFFFF7E0);

  // Ancien dégradé des en-têtes (cartes solde)
  static const Color vertDegrade = Color(0xFF17703A);

  // Statuts commandes
  static const Color statutAttente   = orange;
  static const Color statutConfirmee = bleu;
  static const Color statutLivree    = vertVif;
  static const Color statutAnnulee   = rouge;

  /// Teinte pastel associée à une couleur d'indicateur.
  static Color teinte(Color c) => switch (c.toARGB32()) {
        0xFFD94141 => rougeTeinte,
        0xFFE9862B => orangeTeinte,
        0xFF3B78E7 => bleuTeinte,
        0xFF7657E8 => violetTeinte,
        0xFFD9A11A => ambreTeinte,
        0xFF1F8A4C || 0xFF0B4A24 => vertTeinte,
        _ => c.withValues(alpha: 0.10),
      };
}
