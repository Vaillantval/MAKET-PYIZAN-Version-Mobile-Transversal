import 'package:flutter/material.dart';

/// Palette Makèt Peyizan.
///
/// Inspirée du logo et des maquettes de référence : fond sauge clair,
/// cartes blanches arrondies, encre vert forêt très profond pour les textes
/// comme pour les actions principales (boutons, sélections, barre de
/// navigation). Le vert vif et l'or du soleil servent d'accents ; les
/// tableaux de bord utilisent des paires couleur / teinte pastel.
class AppColors {
  // Marque (logo : vert forêt, vert prairie, soleil doré)
  static const Color vertFonce  = Color(0xFF1F4A2C);
  static const Color vertVif    = Color(0xFF2E8540);
  static const Color vertMoyen  = Color(0xFF7DB86A);
  static const Color vertMenthe = Color(0xFFDDEBD5);
  static const Color jaune      = Color(0xFFD99A0B); // or du soleil (lisible sur blanc)
  static const Color jauneClair = Color(0xFFFFF5D6);

  // Neutres (teintés de vert, comme les maquettes)
  static const Color blanc      = Color(0xFFFFFFFF);
  static const Color noir       = Color(0xFF17301F); // encre : textes, boutons
  static const Color grisClair  = Color(0xFFEEF2EA); // fond sauge des écrans
  static const Color surface2   = Color(0xFFE4EBDF); // vignettes, pastilles
  static const Color grisTexte  = Color(0xFF5B6A5F);
  static const Color grisLeger  = Color(0xFF97A39A); // libellés discrets
  static const Color grisBord   = Color(0xFFDDE5D8);

  // Couleurs d'état / d'indicateurs (fort + teinte)
  static const Color rouge       = Color(0xFFD94141);
  static const Color rougeTeinte = Color(0xFFFDEDED);
  static const Color orange      = Color(0xFFE9862B);
  static const Color orangeTeinte= Color(0xFFFFF2E6);
  static const Color bleu        = Color(0xFF3B78E7);
  static const Color bleuTeinte  = Color(0xFFEBF2FE);
  static const Color violet      = Color(0xFF7657E8);
  static const Color violetTeinte= Color(0xFFF0EDFD);
  static const Color vertTeinte  = Color(0xFFE3EFDB);
  static const Color ambre       = Color(0xFFD9A11A);
  static const Color ambreTeinte = Color(0xFFFFF7E0);

  // Ancien dégradé des en-têtes (cartes solde)
  static const Color vertDegrade = Color(0xFF2B6A3C);

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
        0xFF2E8540 || 0xFF1F4A2C => vertTeinte,
        _ => c.withValues(alpha: 0.10),
      };
}
