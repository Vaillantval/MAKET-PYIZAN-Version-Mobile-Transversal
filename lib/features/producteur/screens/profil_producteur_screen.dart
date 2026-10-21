import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/entreprise_provider.dart';
import '../../../shared/ui/ui.dart';
import '../../entreprise/widgets/espace_entreprise.dart';
import '../providers/dashboard_provider.dart';

class ProfilProducteurScreen extends ConsumerWidget {
  const ProfilProducteurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user          = ref.watch(authProvider).user;
    final stats         = ref.watch(dashboardProvider).valueOrNull;
    final entreprise    = ref.watch(entrepriseActiveProvider);
    final nbEntreprises = user?.entreprises.length ?? 0;
    final proprio       = entreprise?.estProprietaire ?? false;
    final nom           = entreprise?.nom ?? '—';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            const EnTeteEcran('Profil', padding: EdgeInsets.fromLTRB(4, 12, 0, 8)),

            // ── Carte entreprise ────────────────────────────────
            Surface(
              child: Column(
                children: [
                  Row(
                    children: [
                      AvatarInitiales(nom,
                          taille: 54,
                          fond: AppColors.vertFonce,
                          texte: AppColors.blanc),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nom,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700)),
                            Text(
                              [entreprise?.typeLabel, entreprise?.roleLabel]
                                  .where((s) => s != null && s.trim().isNotEmpty)
                                  .join(' · '),
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.grisTexte),
                            ),
                            if (user != null)
                              Text('${user.firstName} ${user.lastName}',
                                  style: const TextStyle(
                                      fontSize: 12.5, color: AppColors.grisLeger)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (stats != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _Chiffre('${stats.commandesTotal}', 'Commandes'),
                        _Chiffre('${stats.nbProduitsActifs}', 'Produits'),
                        _Chiffre('${stats.commandesLivrees}', 'Livrées'),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Surtitre('Entreprise'),
            GroupeLignes([
              LigneReglage(
                icone: Icons.storefront_outlined,
                titre: 'Fiche de l\'entreprise',
                onTap: () => context.push('/producteur/entreprise'),
              ),
              LigneReglage(
                icone: Icons.group_outlined,
                titre: 'Membres',
                onTap: () => context.push('/producteur/membres'),
              ),
              // Portefeuille de l'entreprise : propriétaires seulement
              if (proprio)
                LigneReglage(
                  icone: Icons.account_balance_wallet_outlined,
                  titre: 'Portefeuille',
                  onTap: () => context.push('/producteur/wallet'),
                ),
            ]),

            const Surtitre('Activité'),
            GroupeLignes([
              LigneReglage(
                icone: Icons.inventory_2_outlined,
                titre: 'Mes produits',
                onTap: () => context.go('/producteur/catalogue'),
              ),
              LigneReglage(
                icone: Icons.receipt_long_outlined,
                titre: 'Commandes reçues',
                onTap: () => context.go('/producteur/commandes'),
              ),
              LigneReglage(
                icone: Icons.local_shipping_outlined,
                titre: 'Collectes',
                onTap: () => context.go('/producteur/collectes'),
              ),
            ]),

            const Surtitre('Compte'),
            GroupeLignes([
              if (nbEntreprises > 1)
                LigneReglage(
                  icone: Icons.swap_horiz_rounded,
                  titre: 'Changer d\'entreprise',
                  valeur: '$nbEntreprises',
                  onTap: () async {
                    final choix = await choisirEntreprise(
                        context, user!.entreprises);
                    if (choix != null && context.mounted) {
                      await entrerDansEntreprise(context, ref, choix);
                    }
                  },
                ),
              LigneReglage(
                icone: Icons.shopping_bag_outlined,
                titre: 'Espace acheteur',
                onTap: () => revenirEspaceAcheteur(context, ref),
              ),
              LigneReglage(
                icone: Icons.logout_rounded,
                titre: 'Se déconnecter',
                couleur: AppColors.rouge,
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Chiffre extends StatelessWidget {
  final String valeur;
  final String libelle;
  const _Chiffre(this.valeur, this.libelle);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.grisClair,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(valeur,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              Text(libelle,
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.grisTexte)),
            ],
          ),
        ),
      );
}
