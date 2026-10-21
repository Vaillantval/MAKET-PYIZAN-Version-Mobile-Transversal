import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/ui/ui.dart';
import '../providers/pos_device_provider.dart';
import '../providers/pos_terminal_status_provider.dart';

/// Statuts qui interdisent toute vente : la caisse est remplacée par
/// [PosTerminalBloque] tant que le serveur ne lève pas le blocage.
bool posTerminalBloque(PosTerminalStatut s) => const {
      PosTerminalStatut.enAttente,
      PosTerminalStatut.rejetee,
      PosTerminalStatut.revoque,
      PosTerminalStatut.roleInvalide,
    }.contains(s);

/// Écran bloquant de la caisse : terminal en attente de validation,
/// refusé, désactivé (ou rattaché à un autre agent), ou compte qui n'est
/// pas opérateur de caisse. Se débloque au push pos_terminal_valide ou
/// via « Vérifier à nouveau ».
class PosTerminalBloque extends ConsumerStatefulWidget {
  final PosTerminalInfo info;
  const PosTerminalBloque({required this.info, super.key});

  @override
  ConsumerState<PosTerminalBloque> createState() => _PosTerminalBloqueState();
}

class _PosTerminalBloqueState extends ConsumerState<PosTerminalBloque> {
  bool _verification = false;

  Future<void> _verifier() async {
    setState(() => _verification = true);
    await ref.read(posTerminalStatusProvider.notifier).verifier();
    if (mounted) setState(() => _verification = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceUid = ref.watch(posDeviceUidProvider);
    final (icone, couleur, titre, texte) = switch (widget.info.statut) {
      PosTerminalStatut.enAttente => (
          Icons.hourglass_top_rounded,
          AppColors.orange,
          'Terminal en attente',
          'Votre terminal a été transmis à l\'administration. Vous pourrez '
              'vendre dès sa validation : une notification vous préviendra.',
        ),
      PosTerminalStatut.rejetee => (
          Icons.block_rounded,
          AppColors.rouge,
          'Terminal refusé',
          'La demande d\'activation de ce terminal a été refusée. Contactez '
              'l\'administration MaketLakay.',
        ),
      PosTerminalStatut.roleInvalide => (
          Icons.no_accounts_outlined,
          AppColors.rouge,
          'Compte non autorisé',
          'Ce compte n\'est pas un compte opérateur de caisse. Connectez-vous '
              'avec le compte fourni par l\'administration.',
        ),
      _ => (
          Icons.phonelink_lock_outlined,
          AppColors.rouge,
          'Terminal désactivé',
          'Ce terminal a été désactivé ou appartient à un autre agent : il ne '
              'peut pas enregistrer de ventes. Contactez l\'administration '
              'MaketLakay.',
        ),
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TuileIcone(icone, couleur: couleur, taille: 84),
                const SizedBox(height: 22),
                Text(titre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4)),
                const SizedBox(height: 10),
                Text(texte,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14.5, color: AppColors.grisTexte, height: 1.45)),
                if (widget.info.nom != null) ...[
                  const SizedBox(height: 6),
                  Text(widget.info.nom!,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.grisLeger)),
                ],
                if (deviceUid != null &&
                    widget.info.statut != PosTerminalStatut.roleInvalide) ...[
                  const SizedBox(height: 20),
                  Surface(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: deviceUid));
                      afficherMessage(context, 'Identifiant copié');
                    },
                    padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Identifiant du terminal',
                                  style: TextStyle(
                                      fontSize: 11.5, color: AppColors.grisTexte)),
                              Text(deviceUid,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const Icon(Icons.copy_rounded,
                            size: 18, color: AppColors.grisTexte),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (widget.info.statut != PosTerminalStatut.roleInvalide)
                  ElevatedButton.icon(
                    onPressed: _verification ? null : _verifier,
                    icon: _verification
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.blanc))
                        : const Icon(Icons.refresh_rounded),
                    label: const Text('Vérifier à nouveau'),
                  ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Se déconnecter'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
