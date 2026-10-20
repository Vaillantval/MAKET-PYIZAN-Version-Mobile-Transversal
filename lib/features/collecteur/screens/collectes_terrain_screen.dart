import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

/// Espace agent de collecte.
///
/// Le backend MaketLakay assigne les collectes aux agents depuis le tableau
/// de bord, mais n'expose pas encore d'API « mes collectes » pour eux :
/// plutôt qu'un écran en erreur (403), on indique clairement où les suivre.
class CollectesTerrainScreen extends ConsumerWidget {
  const CollectesTerrainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Mes collectes')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.vertMenthe,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(Icons.local_shipping_outlined,
                      size: 44, color: AppColors.vertFonce),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bonjou ${user?.firstName ?? ''} !',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: AppColors.noir, letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Le suivi des collectes depuis l\'application arrive '
                  'bientôt.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.noir),
                ),
                const SizedBox(height: 8),
                const Text(
                  'En attendant, vos collectes (dates, zones, producteurs) '
                  'vous sont communiquées par l\'équipe MaketLakay depuis le '
                  'tableau de bord. Contactez votre responsable pour toute '
                  'question.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.grisTexte, height: 1.4),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  icon:  const Icon(Icons.logout),
                  label: const Text('Se déconnecter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rouge,
                    side: const BorderSide(color: AppColors.rouge),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
