import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../providers/pos_device_provider.dart';
import '../providers/pos_session_provider.dart';

class PosProfilScreen extends ConsumerWidget {
  const PosProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user     = ref.watch(authProvider).user;
    final deviceUid = ref.watch(posDeviceUidProvider);
    final sessionOuverte = ref.watch(posSessionProvider.notifier).isOuverte;

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
