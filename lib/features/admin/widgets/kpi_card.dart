import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class KpiCard extends StatelessWidget {
  final String       emoji;
  final String       valeur;
  final String       label;
  final Color        couleur;
  final String?      tendance;
  final bool         urgent;
  final VoidCallback? onTap;

  const KpiCard({
    required this.emoji,
    required this.valeur,
    required this.label,
    this.couleur  = AppColors.vertVif,
    this.tendance,
    this.urgent   = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: urgent
            ? Border.all(color: AppColors.rouge, width: 1.5)
            : Border(left: BorderSide(color: couleur, width: 4)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              if (urgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:        AppColors.rouge.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('!',
                    style: TextStyle(
                      color:      AppColors.rouge,
                      fontWeight: FontWeight.w900,
                      fontSize:   12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(valeur,
            style: TextStyle(
              fontSize:   28,
              fontWeight: FontWeight.w900,
              color:      urgent ? AppColors.rouge : couleur,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
            style: const TextStyle(
              fontSize: 11, color: AppColors.grisTexte,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (tendance != null) ...[
            const SizedBox(height: 4),
            Text(tendance!,
              style: const TextStyle(
                fontSize: 11, color: AppColors.vertVif,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
