import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/ui/ui.dart';
import '../providers/commande_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/commande_statut_badge.dart';
import '../../entreprise/widgets/espace_entreprise.dart';
import '../../../shared/widgets/changer_mot_de_passe_sheet.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user        = ref.watch(authProvider).user;
    final walletState = ref.watch(walletProvider);
    final derniere    = ref.watch(commandesProvider).valueOrNull?.firstOrNull;
    final nom         = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            const EnTeteEcran('Profil', padding: EdgeInsets.fromLTRB(4, 12, 0, 8)),

            // ── Identité ────────────────────────────────────────
            Surface(
              child: Row(
                children: [
                  user?.photo != null
                      ? CircleAvatar(
                          radius: 26,
                          backgroundImage: CachedNetworkImageProvider(user!.photo!),
                        )
                      : AvatarInitiales(nom.isEmpty ? '?' : nom, taille: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nom.isEmpty ? '—' : nom,
                            style: const TextStyle(
                                fontSize: 16.5, fontWeight: FontWeight.w700)),
                        Text(user?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.grisTexte)),
                        if ((user?.telephone ?? '').isNotEmpty)
                          Text(user!.telephone,
                              style: const TextStyle(
                                  fontSize: 12.5, color: AppColors.grisLeger)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Dernière commande ───────────────────────────────
            if (derniere != null) ...[
              const SizedBox(height: 10),
              Surface(
                onTap: () =>
                    context.go('/acheteur/commande/${derniere.numeroCommande}'),
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 21),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dernière commande',
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w600)),
                          Text(
                            '${derniere.numeroCommande} · ${FormatUtils.htg(derniere.total)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.grisTexte),
                          ),
                        ],
                      ),
                    ),
                    CommandeStatutBadge(derniere.statut),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.grisLeger),
                  ],
                ),
              ),
            ],

            // ── Compte ──────────────────────────────────────────
            const Surtitre('Compte'),
            GroupeLignes([
              LigneReglage(
                icone: Icons.receipt_long_outlined,
                titre: 'Mes commandes',
                onTap: () => context.go('/acheteur/commandes'),
              ),
              LigneReglage(
                icone: Icons.account_balance_wallet_outlined,
                titre: 'Portefeuille',
                valeur: walletState.whenOrNull(data: (w) => FormatUtils.htg(w.solde)),
                onTap: () => context.push('/acheteur/wallet'),
              ),
              LigneReglage(
                icone: Icons.card_giftcard_outlined,
                titre: 'Bons cadeaux',
                onTap: () => context.push('/acheteur/wallet/bons'),
              ),
              LigneReglage(
                icone: Icons.place_outlined,
                titre: 'Mes adresses',
                onTap: () => context.push('/acheteur/adresses'),
              ),
            ]),

            // ── Entreprises : accès à l'espace vendeur ──────────
            const Surtitre('Vendre sur MaketLakay'),
            const MesEntreprisesCard(),

            // ── Sécurité & aide ─────────────────────────────────
            const Surtitre('Réglages'),
            GroupeLignes([
              LigneReglage(
                icone: Icons.lock_outline_rounded,
                titre: 'Changer le mot de passe',
                onTap: () => afficherChangementMotDePasse(context),
              ),
              LigneReglage(
                icone: Icons.help_outline_rounded,
                titre: 'Aide',
                onTap: () => afficherMessage(context, 'Aide disponible bientôt'),
              ),
              LigneReglage(
                icone: Icons.logout_rounded,
                titre: 'Se déconnecter',
                couleur: AppColors.rouge,
                onTap: () => _confirmerDeco(context, ref),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _confirmerDeco(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Vous devrez saisir à nouveau vos identifiants.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.rouge),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
