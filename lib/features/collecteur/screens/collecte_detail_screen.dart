import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Détail d'une collecte terrain — stub à compléter
class CollecteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> collecte;
  const CollecteDetailScreen({required this.collecte, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          collecte['titre']?.toString() ??
              collecte['reference']?.toString() ??
              'Collecte',
        ),
        backgroundColor: AppColors.vertFonce,
      ),
      body: const Center(
        child: Text('Détail collecte — à implémenter'),
      ),
    );
  }
}
