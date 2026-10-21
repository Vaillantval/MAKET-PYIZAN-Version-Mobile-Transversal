import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/ui/ui.dart';

class CommandeStatutBadge extends StatelessWidget {
  final String statut;
  const CommandeStatutBadge(this.statut, {super.key});

  static const _config = {
    'en_attente':     ('En attente',      AppColors.orange),
    'confirmee':      ('Confirmée',       AppColors.bleu),
    'en_preparation': ('En préparation',  AppColors.violet),
    'prete':          ('Prête',           AppColors.violet),
    'en_collecte':    ('En collecte',     AppColors.bleu),
    'livree':         ('Livrée',          AppColors.vertVif),
    'annulee':        ('Annulée',         AppColors.grisTexte),
    'litige':         ('En litige',       AppColors.rouge),
  };

  /// Couleur associée au statut (pastilles, icônes de liste).
  static Color couleur(String statut) =>
      _config[statut]?.$2 ?? AppColors.grisTexte;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _config[statut] ??
        (statut.replaceAll('_', ' '), AppColors.grisTexte);
    return PuceStatut(label, couleur: color);
  }
}
