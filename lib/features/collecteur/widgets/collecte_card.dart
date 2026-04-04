import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';

class CollecteCard extends StatelessWidget {
  final Map<String, dynamic> collecte;
  final VoidCallback? onTap;

  const CollecteCard({
    required this.collecte,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:     Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding:    const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        AppColors.vertMenthe,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: AppColors.vertFonce,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collecte['titre']?.toString() ??
                      collecte['reference']?.toString() ??
                      'Collecte',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.vertFonce,
                  ),
                ),
                Text(
                  FormatUtils.date(collecte['date_prevue'] as String?),
                  style: const TextStyle(
                    fontSize: 12, color: AppColors.grisTexte,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.grisTexte,
          ),
        ],
      ),
    ),
  );
}
