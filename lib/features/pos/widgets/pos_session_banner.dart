import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/pos_session_provider.dart';

/// Bandeau permanent affiché dans toute la shell POS indiquant
/// l'état de la session de caisse.
class PosSessionBanner extends ConsumerWidget {
  const PosSessionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(posSessionProvider);

    return sessionState.when(
      loading: () => const SizedBox.shrink(),
      error:   (_, __) => const SizedBox.shrink(),
      data: (session) {
        final ouverte = session != null && session.statut == 'ouverte';
        return Container(
          width: double.infinity,
          color: ouverte ? AppColors.vertMenthe : AppColors.jauneClair,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            children: [
              Icon(
                ouverte ? Icons.lock_open : Icons.lock_outline,
                size: 14,
                color: ouverte ? AppColors.vertFonce : AppColors.orange,
              ),
              const SizedBox(width: 6),
              Text(
                ouverte
                    ? 'Session ouverte depuis ${FormatUtils.heure(session.ouverteLe)}'
                    : 'Aucune session ouverte',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: ouverte ? AppColors.vertFonce : AppColors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
