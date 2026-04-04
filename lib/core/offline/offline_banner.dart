import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'connectivity_service.dart';
import 'sync_queue.dart';

/// Bannière à afficher en haut des écrans quand offline
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline     = ref.watch(isOnlineProvider);
    final syncQueue    = ref.read(syncQueueProvider);
    final pendingCount = syncQueue.pendingCount;

    if (isOnline) {
      // Si en ligne mais actions en attente → bannière verte
      if (pendingCount > 0) {
        return Container(
          color:   AppColors.vertVif,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.sync, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Synchronisation de $pendingCount action(s)...',
                style: const TextStyle(
                  color: Colors.white, fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // Hors ligne
    return Container(
      color:   AppColors.orange,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pendingCount > 0
                  ? 'Hors ligne — $pendingCount action(s) en attente de sync'
                  : 'Hors ligne — Mode lecture seule',
              style: const TextStyle(
                color: Colors.white, fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
