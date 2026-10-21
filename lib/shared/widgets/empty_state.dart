import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icone;
  final String  titre;
  final String? description;
  final String? boutonLabel;
  final VoidCallback? onBouton;

  const EmptyState({
    required this.icone,
    required this.titre,
    this.description,
    this.boutonLabel,
    this.onBouton,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76, height: 76,
            decoration: const BoxDecoration(
              color: AppColors.blanc,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 34, color: AppColors.grisTexte),
          ),
          const SizedBox(height: 18),
          Text(titre,
            style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700,
              color: AppColors.noir, letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(description!,
              style: const TextStyle(
                fontSize: 13.5, color: AppColors.grisTexte, height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (boutonLabel != null && onBouton != null) ...[
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onBouton,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(boutonLabel!),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
