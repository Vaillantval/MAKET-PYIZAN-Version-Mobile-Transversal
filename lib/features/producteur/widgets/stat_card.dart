import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: couleur, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color:     Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset:    const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            valeur,
            style: TextStyle(
              fontSize:   26,
              fontWeight: FontWeight.w900,
              color:      couleur,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12, color: AppColors.grisTexte,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (sousTitre != null)
            Text(
              sousTitre!,
              style: const TextStyle(
                fontSize: 11, color: AppColors.grisTexte,
              ),
            ),
        ],
      ),
    ),
  );
}
