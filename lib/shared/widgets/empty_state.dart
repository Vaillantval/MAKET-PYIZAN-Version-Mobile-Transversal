import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String  emoji;
  final String  titre;
  final String? description;
  final String? boutonLabel;
  final VoidCallback? onBouton;

  const EmptyState({
    required this.emoji,
    required this.titre,
    this.description,
    this.boutonLabel,
    this.onBouton,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(titre,
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.vertFonce,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(description!,
              style: const TextStyle(
                fontSize: 14, color: AppColors.grisTexte,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (boutonLabel != null && onBouton != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBouton,
              child: Text(boutonLabel!),
            ),
          ],
        ],
      ),
    ),
  );
}
