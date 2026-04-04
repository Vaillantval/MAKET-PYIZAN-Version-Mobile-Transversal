import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

class PendingValidationScreen extends ConsumerWidget {
  const PendingValidationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.vertMenthe,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
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
              const Text(
                'Votre compte producteur est en attente de validation.',
                style: TextStyle(fontSize: 16, color: AppColors.grisTexte),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Notre équipe va examiner votre profil et vous enverrons une notification dès l\'approbation.',
                style: TextStyle(fontSize: 14, color: AppColors.grisTexte),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                icon:     const Icon(Icons.refresh),
                label:    const Text('Vérifier le statut'),
                onPressed: () =>
                    ref.read(authProvider.notifier).checkAuth(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.vertFonce,
                  side: const BorderSide(color: AppColors.vertFonce),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.read(authProvider.notifier).logout(),
                child: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: AppColors.rouge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
