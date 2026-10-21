import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/entreprise_provider.dart';
import '../../entreprise/widgets/espace_entreprise.dart';
import '../../../shared/ui/ui.dart';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TuileIcone(
                enAttente ? Icons.hourglass_top_rounded : Icons.block_rounded,
                couleur: enAttente ? AppColors.orange : AppColors.rouge,
                taille: 84,
              ),
              const SizedBox(height: 24),
              Text(
                'Bonjour ${user?.firstName ?? ''} !',
                style: const TextStyle(
                  fontSize:    26,
                  fontWeight:  FontWeight.w700,
                  letterSpacing: -0.6,
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
                icon:     const Icon(Icons.refresh_rounded),
                label:    const Text('Vérifier le statut'),
                onPressed: () =>
                    ref.read(authProvider.notifier).rafraichirProfil(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon:  const Icon(Icons.shopping_bag_outlined),
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
