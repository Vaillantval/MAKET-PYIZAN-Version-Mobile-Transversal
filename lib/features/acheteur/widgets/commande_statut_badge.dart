import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CommandeStatutBadge extends StatelessWidget {
  final String statut;
  const CommandeStatutBadge(this.statut, {super.key});

  static const _config = {
    'en_attente':     ('En attente',      AppColors.statutAttente),
    'confirmee':      ('Confirmée',       AppColors.statutConfirmee),
    'en_preparation': ('En préparation',  AppColors.statutConfirmee),
    'prete':          ('Prête',           AppColors.vertVif),
    'en_collecte':    ('En collecte',     AppColors.orange),
    'livree':         ('Livrée',          AppColors.statutLivree),
    'annulee':        ('Annulée',         AppColors.statutAnnulee),
    'litige':         ('En litige',       AppColors.rouge),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _config[statut] ??
        ('Inconnu', AppColors.grisTexte);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withValues(alpha: .4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   12,
          fontWeight: FontWeight.w600,
          color:      color,
        ),
      ),
    );
  }
}
