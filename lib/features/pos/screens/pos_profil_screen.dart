import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/printing/pos_printer_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../providers/auth_provider.dart';
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
    final imprimanteState = ref.watch(posPrinterProvider);
    final terminalInfo = ref.watch(posTerminalStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Profil opérateur POS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.vertFonce),
                ),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: const TextStyle(color: AppColors.grisTexte)),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Terminal',
                  value: deviceUid == null
                      ? '…'
                      : '${deviceUid.substring(0, 8)}…',
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  label: 'Session',
                  value: sessionOuverte ? 'Ouverte' : 'Aucune',
                  valueColor: sessionOuverte ? AppColors.vertVif : AppColors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _TerminalStatutCard(info: terminalInfo),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.qr_code, color: AppColors.vertFonce),
              title: const Text('Identifiant du terminal'),
              subtitle: const Text(
                'Voir / copier l\'identifiant pour l\'enregistrement admin',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/pos/appairage'),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.print_outlined, color: AppColors.vertFonce),
                  title: const Text('Impression automatique'),
                  subtitle: Text(
                    imprimanteState.disponible
                        ? 'Imprime le reçu dès la confirmation de la vente'
                        : 'Imprimante indisponible sur cet appareil',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _impressionAuto,
                  activeThumbColor: AppColors.vertVif,
                  onChanged: (v) async {
                    await ref.read(localStorageProvider).setBool(AppConstants.keyPosImpressionAuto, v);
                    setState(() => _impressionAuto = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.rouge),
              title: const Text('Déconnexion'),
              onTap: () => ref.read(authProvider.notifier).logout(),
            ),
          ),
        ],
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
      PosTerminalStatut.actif      => (AppColors.vertVif, Icons.check_circle, 'Actif'),
      PosTerminalStatut.enAttente  => (AppColors.orange, Icons.hourglass_top_rounded, 'En attente de validation'),
      PosTerminalStatut.rejetee    => (AppColors.rouge, Icons.block_rounded, 'Rejeté'),
      PosTerminalStatut.revoque    => (AppColors.rouge, Icons.block_rounded, 'Révoqué'),
      PosTerminalStatut.roleInvalide => (AppColors.rouge, Icons.no_accounts_outlined, 'Compte non caissier'),
      PosTerminalStatut.inconnu    => (AppColors.grisTexte, Icons.help_outline_rounded, 'Inconnu'),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: couleur, size: 20),
              const SizedBox(width: 8),
              const Text('Statut du terminal',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  libelle,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: couleur),
                ),
              ),
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
                foregroundColor: AppColors.vertFonce,
                side: const BorderSide(color: AppColors.vertFonce),
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: AppColors.grisTexte, fontSize: 13)),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w700, fontSize: 13,
          color: valueColor ?? AppColors.noir,
        ),
      ),
    ],
  );
}
