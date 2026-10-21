import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
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
        // Session ouverte : rappel déjà dans les en-têtes des écrans
        if (ouverte) return const SizedBox.shrink();
        return Material(
          color: AppColors.orangeTeinte,
          child: InkWell(
            onTap: () => context.go('/pos/session'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Aucune session ouverte',
                        style: TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600,
                            color: AppColors.orange)),
                  ),
                  Text('Ouvrir',
                      style: TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700,
                          color: AppColors.orange)),
                  Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.orange),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
