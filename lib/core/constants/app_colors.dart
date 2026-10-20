import 'package:flutter/material.dart';

class AppColors {
  // Palette officielle MaketLakay (logo « ML » : vert forêt + orange),
  // alignée sur l'accent du site web (static/css/modernist.css).
  static const Color vertFonce  = Color(0xFF0B4A24);
  static const Color vertVif    = Color(0xFF1C7A3E);
  static const Color vertMoyen  = Color(0xFF6CB87A);
  static const Color vertMenthe = Color(0xFFEAF4EC);
  // Orange du logo — remplace l'ancien jaune comme couleur d'accent
  // (badges, avatars, mises en avant). Texte foncé dessus : contraste AA.
  static const Color jaune      = Color(0xFFF26B1D);
  static const Color jauneClair = Color(0xFFFFF1E8);
  static const Color blanc      = Color(0xFFFFFFFF);
  static const Color noir       = Color(0xFF201E1D);
  static const Color grisClair  = Color(0xFFF5F4F2);
  static const Color grisTexte  = Color(0xFF605D5D);
  static const Color grisBord   = Color(0xFFE4E1DF);
  static const Color rouge      = Color(0xFFC62828);
  static const Color orange     = Color(0xFFE65100);
  static const Color bleu       = Color(0xFF1565C0);

  static const Color violet    = Color(0xFF6A1B9A);

  // Dégradé des en-têtes (cartes solde, profils)
  static const Color vertDegrade = Color(0xFF17703A);

  // Statuts commandes
  static const Color statutAttente   = Color(0xFFE08600);
  static const Color statutConfirmee = Color(0xFF1565C0);
  static const Color statutLivree    = Color(0xFF1C7A3E);
  static const Color statutAnnulee   = Color(0xFFC62828);
}
