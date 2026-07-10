import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/pos_device_provider.dart';

class PosAppairageScreen extends ConsumerStatefulWidget {
  const PosAppairageScreen({super.key});

  @override
  ConsumerState<PosAppairageScreen> createState() => _PosAppairageScreenState();
}

class _PosAppairageScreenState extends ConsumerState<PosAppairageScreen> {
  final _deviceUidCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _deviceUidCtrl.dispose();
    super.dispose();
  }

  Future<void> _appairer() async {
    final deviceUid = _deviceUidCtrl.text.trim();
    if (deviceUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez saisir l\'identifiant du terminal (device_uid).'),
        backgroundColor: AppColors.rouge,
      ));
      return;
    }

    setState(() => _loading = true);
    await ref.read(posDeviceUidProvider.notifier).appairer(deviceUid);
    setState(() => _loading = false);

    if (!mounted) return;
    context.go('/pos/vente');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Appairage du terminal POS')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.point_of_sale, size: 64, color: AppColors.vertFonce),
            const SizedBox(height: 16),
            const Text(
              'Appairer ce terminal',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: AppColors.vertFonce,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Saisissez l\'identifiant (device_uid) du terminal POS assigné '
              'à ce compte. Il doit être actif côté administration.',
              style: TextStyle(fontSize: 13, color: AppColors.grisTexte),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _deviceUidCtrl,
              decoration: InputDecoration(
                labelText: 'Device UID',
                hintText: 'Ex : POS-COMPTOIR-01',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _appairer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertFonce,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Appairer ce terminal', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
