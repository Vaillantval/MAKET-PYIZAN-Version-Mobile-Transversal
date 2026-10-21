import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/pos_terminal_status_provider.dart';

/// Bandeau non-bloquant affiché en haut des écrans POS quand le terminal
/// n'est pas (ou plus) autorisé côté backend. L'opérateur reste libre de
/// naviguer — voir aussi l'onglet Profil pour le détail et le bouton
/// "Vérifier maintenant".
class PosTerminalBanner extends ConsumerWidget {
  const PosTerminalBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(posTerminalStatusProvider);
    if (info.statut == PosTerminalStatut.actif) return const SizedBox.shrink();

    final Color couleur;
    final IconData icone;
    final String texte;
    switch (info.statut) {
      case PosTerminalStatut.enAttente:
        couleur = AppColors.orange;
        icone   = Icons.hourglass_top_rounded;
        texte   = info.tentatives != null
            ? 'Terminal en attente de validation (tentative ${info.tentatives})'
            : 'Terminal en attente de validation par l\'administrateur';
        break;
      case PosTerminalStatut.rejetee:
        couleur = AppColors.rouge;
        icone   = Icons.block_rounded;
        texte   = 'Terminal rejeté — contactez votre administrateur';
        break;
      case PosTerminalStatut.revoque:
        couleur = AppColors.rouge;
        icone   = Icons.block_rounded;
        texte   = 'Terminal révoqué — contactez votre administrateur';
        break;
      case PosTerminalStatut.roleInvalide:
        couleur = AppColors.rouge;
        icone   = Icons.no_accounts_outlined;
        texte   = "Ce compte n'est pas un compte opérateur de caisse";
        break;
      case PosTerminalStatut.actif:
      case PosTerminalStatut.inconnu:
        couleur = AppColors.grisTexte;
        icone   = Icons.help_outline_rounded;
        texte   = 'Statut du terminal inconnu';
        break;
    }

    return Container(
      color:   couleur.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icone, size: 16, color: couleur),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texte,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: couleur),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(posTerminalStatusProvider.notifier).verifier(),
            style: TextButton.styleFrom(
              foregroundColor: couleur,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Vérifier', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: () => context.push('/pos/appairage'),
            style: TextButton.styleFrom(
              foregroundColor: couleur,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Détails', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
