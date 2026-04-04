import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Champs de formulaire réutilisables pour la création/modification produit
class ProduitFormSection extends StatelessWidget {
  final String titre;
  final Widget child;

  const ProduitFormSection({
    required this.titre,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        titre,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize:   14,
          color:      AppColors.vertFonce,
        ),
      ),
      const SizedBox(height: 8),
      child,
    ],
  );
}
