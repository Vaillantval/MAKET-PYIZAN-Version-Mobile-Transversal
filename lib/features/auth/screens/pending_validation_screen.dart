import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/entreprise_provider.dart';
import '../../entreprise/widgets/espace_entreprise.dart';

/// Espace entreprise d'une entreprise pas (ou plus) autorisée à vendre :
/// en attente de validation, suspendue ou inactive.
class PendingValidationScreen extends ConsumerWidget {
  const PendingValidationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user       = ref.watch(authProvider).user;
    final entreprise = ref.watch(entrepriseActiveProvider);
    final enAttente  = entreprise?.estEnAttente ?? true;
    final nom        = entreprise?.nom ?? '';

    return Scaffold(
      backgroundColor: AppColors.vertMenthe,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                enAttente ? Icons.hourglass_top_rounded : Icons.block,
                size:  80,
                color: AppColors.vertFonce,
              ),
              const SizedBox(height: 24),
              Text(
                'Bonjour ${user?.firstName ?? ''} !',
                style: const TextStyle(
                  fontFamily:  'PlayfairDisplay',
                  fontSize:    28,
                  fontWeight:  FontWeight.w900,
                  color:       AppColors.vertFonce,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                enAttente
                    ? 'L\'entreprise « $nom » est en attente de validation.'
                    : 'L\'entreprise « $nom » est suspendue ou inactive.',
                style: const TextStyle(fontSize: 16, color: AppColors.grisTexte),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                enAttente
                    ? 'Notre équipe va l\'examiner et vous enverra une '
                      'notification dès son approbation. En attendant, vous '
                      'pouvez continuer à acheter.'
                    : 'Elle ne peut pas vendre pour le moment. Contactez '
                      'notre équipe pour en savoir plus.',
                style: const TextStyle(fontSize: 14, color: AppColors.grisTexte),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                icon:     const Icon(Icons.refresh),
                label:    const Text('Vérifier le statut'),
                onPressed: () =>
                    ref.read(authProvider.notifier).rafraichirProfil(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.vertFonce,
                  side: const BorderSide(color: AppColors.vertFonce),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon:  const Icon(Icons.shopping_basket_outlined),
                label: const Text('Retour à l\'espace acheteur'),
                onPressed: () => revenirEspaceAcheteur(context, ref),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
