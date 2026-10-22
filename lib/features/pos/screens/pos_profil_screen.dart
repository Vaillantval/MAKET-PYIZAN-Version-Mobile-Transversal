import '../../../shared/widgets/ligne_sons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/printing/pos_printer_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/ui/ui.dart';
import '../providers/pos_device_provider.dart';
import '../providers/pos_session_provider.dart';
import '../providers/pos_terminal_status_provider.dart';

class PosProfilScreen extends ConsumerStatefulWidget {
  const PosProfilScreen({super.key});

  @override
  ConsumerState<PosProfilScreen> createState() => _PosProfilScreenState();
}

class _PosProfilScreenState extends ConsumerState<PosProfilScreen> {
  late bool _impressionAuto;

  @override
  void initState() {
    super.initState();
    _impressionAuto = ref.read(localStorageProvider).getBool(AppConstants.keyPosImpressionAuto);
  }

  @override
  Widget build(BuildContext context) {
    final user     = ref.watch(authProvider).user;
    final deviceUid = ref.watch(posDeviceUidProvider);
    final sessionOuverte = ref.watch(posSessionProvider.notifier).isOuverte;
    ref.watch(posSessionProvider);
    final imprimanteState = ref.watch(posPrinterProvider);
    final terminalInfo = ref.watch(posTerminalStatusProvider);
    final nom = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            const EnTeteEcran('Profil', padding: EdgeInsets.fromLTRB(4, 12, 0, 8)),
            Surface(
              child: Row(
                children: [
                  AvatarInitiales(nom.isEmpty ? '?' : nom, taille: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nom.isEmpty ? 'Opérateur' : nom,
                            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
                        Text(user?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppColors.grisTexte)),
                      ],
                    ),
                  ),
                  const PuceStatut('Caissier', couleur: AppColors.bleu),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _TerminalStatutCard(info: terminalInfo),

            const Surtitre('Caisse'),
            GroupeLignes([
              LigneReglage(
                icone: Icons.lock_clock_outlined,
                titre: 'Session',
                valeur: sessionOuverte ? 'Ouverte' : 'Aucune',
                onTap: () => context.go('/pos/session'),
              ),
              LigneReglage(
                icone: Icons.qr_code_2_rounded,
                titre: 'Identifiant du terminal',
                valeur: deviceUid == null ? '…' : '${deviceUid.substring(0, 8)}…',
                onTap: () => context.push('/pos/appairage'),
              ),
              LigneReglage(
                icone: Icons.print_outlined,
                titre: 'Impression automatique',
                sousTitre: imprimanteState.disponible
                    ? 'Reçu imprimé dès la confirmation de la vente'
                    : 'Imprimante indisponible sur cet appareil',
                trailing: Switch(
                  value: _impressionAuto,
                  onChanged: (v) async {
                    await ref.read(localStorageProvider).setBool(AppConstants.keyPosImpressionAuto, v);
                    setState(() => _impressionAuto = v);
                  },
                ),
              ),
            ]),

            const Surtitre('Compte'),
            GroupeLignes([
              const LigneSons(),
              LigneReglage(
                icone: Icons.logout_rounded,
                titre: 'Se déconnecter',
                couleur: AppColors.rouge,
                onTap: () => ref.read(authProvider.notifier).logout(),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Badge coloré (vert/orange/rouge/gris) + détail du statut d'autorisation
/// du terminal, avec bouton "Vérifier maintenant" (roue de secours si le
/// push de validation n'arrive pas — device sans Google Play Services,
/// token FCM expiré…).
class _TerminalStatutCard extends ConsumerStatefulWidget {
  final PosTerminalInfo info;
  const _TerminalStatutCard({required this.info});

  @override
  ConsumerState<_TerminalStatutCard> createState() => _TerminalStatutCardState();
}

class _TerminalStatutCardState extends ConsumerState<_TerminalStatutCard> {
  bool _verification = false;

  Future<void> _verifier() async {
    setState(() => _verification = true);
    await ref.read(posTerminalStatusProvider.notifier).verifier();
    if (mounted) setState(() => _verification = false);
  }

  @override
  Widget build(BuildContext context) {
    final (couleur, icone, libelle) = switch (widget.info.statut) {
      PosTerminalStatut.actif      => (AppColors.vertVif, Icons.verified_outlined, 'Actif'),
      PosTerminalStatut.enAttente  => (AppColors.orange, Icons.hourglass_top_rounded, 'En attente de validation'),
      PosTerminalStatut.rejetee    => (AppColors.rouge, Icons.block_rounded, 'Rejeté'),
      PosTerminalStatut.revoque    => (AppColors.rouge, Icons.block_rounded, 'Révoqué'),
      PosTerminalStatut.roleInvalide => (AppColors.rouge, Icons.no_accounts_outlined, 'Compte non caissier'),
      PosTerminalStatut.inconnu    => (AppColors.grisTexte, Icons.help_outline_rounded, 'Inconnu'),
    };

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TuileIcone(icone, couleur: couleur, taille: 38),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Statut du terminal',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
              ),
              PuceStatut(libelle, couleur: couleur),
            ],
          ),
          if (widget.info.tentatives != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tentative(s) : ${widget.info.tentatives}',
              style: const TextStyle(fontSize: 12, color: AppColors.grisTexte),
            ),
          ],
          if (widget.info.statut != PosTerminalStatut.actif) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _verification ? null : _verifier,
              icon: _verification
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: const Text('Vérifier maintenant'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
