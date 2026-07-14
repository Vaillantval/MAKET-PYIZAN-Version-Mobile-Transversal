import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../providers/pos_device_provider.dart';

/// Écran d'accueil du terminal POS : affiche l'identifiant (UUID)
/// généré automatiquement et stocké en stockage sécurisé, à
/// communiquer à un superadmin pour enregistrer ce terminal côté
/// administration avant de pouvoir encaisser.
class PosAppairageScreen extends ConsumerWidget {
  const PosAppairageScreen({super.key});

  Future<void> _continuer(BuildContext context, WidgetRef ref) async {
    await ref.read(localStorageProvider).setBool(AppConstants.keyPosOnboardingVu, true);
    if (context.mounted) context.go('/pos/vente');
  }

  void _copier(BuildContext context, String uid) {
    Clipboard.setData(ClipboardData(text: uid));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Identifiant copié dans le presse-papiers'),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceUid = ref.watch(posDeviceUidProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Terminal POS')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.point_of_sale, size: 64, color: AppColors.vertFonce),
            const SizedBox(height: 16),
            const Text(
              'Enregistrement du terminal',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: AppColors.vertFonce,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Communiquez l\'identifiant ci-dessous à votre administrateur '
              'pour qu\'il enregistre ce terminal. Sans cela, les ventes '
              'seront refusées par le serveur.',
              style: TextStyle(fontSize: 13, color: AppColors.grisTexte),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (deviceUid == null)
              const Center(child: CircularProgressIndicator(color: AppColors.vertVif))
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.vertVif.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    SelectableText(
                      deviceUid,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _copier(context, deviceUid),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copier l\'identifiant'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: deviceUid == null ? null : () => _continuer(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertFonce,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continuer', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
