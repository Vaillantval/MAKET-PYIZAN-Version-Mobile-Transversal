import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/printing/pos_printer_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../providers/auth_provider.dart';
import '../providers/pos_device_provider.dart';
import '../providers/pos_session_provider.dart';

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
                _InfoRow(label: 'Terminal', value: deviceUid ?? 'Non appairé'),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
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
