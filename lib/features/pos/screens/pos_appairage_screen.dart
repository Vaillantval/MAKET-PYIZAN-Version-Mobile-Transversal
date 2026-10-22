import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/ui/ui.dart';
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
    afficherMessage(context, 'Identifiant copié');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceUid = ref.watch(posDeviceUidProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Terminal de caisse')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: TuileIcone(Icons.point_of_sale_rounded,
                  couleur: AppColors.vertFonce, taille: 80),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enregistrement du terminal',
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4,
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
              const Center(child: CircularProgressIndicator())
            else
              Surface(
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
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copier l\'identifiant'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: deviceUid == null ? null : () => _continuer(context, ref),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              child: const Text('Continuer', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
