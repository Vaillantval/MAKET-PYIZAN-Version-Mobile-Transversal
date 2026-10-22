import '../../../shared/widgets/ligne_sons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/changer_mot_de_passe_sheet.dart';
import '../providers/admin_stats_provider.dart';

/// Onglet « Plus » de l'admin : sections secondaires et compte.
class AdminPlusScreen extends ConsumerWidget {
  const AdminPlusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user  = ref.watch(authProvider).user;
    final stats = ref.watch(adminStatsProvider).valueOrNull;
    final nom   = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            const EnTeteEcran('Plus', padding: EdgeInsets.fromLTRB(4, 12, 0, 8)),
            Surface(
              child: Row(
                children: [
                  AvatarInitiales(nom.isEmpty ? 'Admin' : nom, taille: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nom.isEmpty ? 'Administrateur' : nom,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(user?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.grisTexte)),
                      ],
                    ),
                  ),
                  const PuceStatut('Super-admin', couleur: AppColors.violet),
                ],
              ),
            ),
            const Surtitre('Gestion'),
            GroupeLignes([
              LigneReglage(
                icone: Icons.inventory_2_outlined,
                titre: 'Catalogue',
                valeur: stats == null ? null : '${stats.totalProduits}',
                onTap: () => context.go('/admin/catalogue'),
              ),
              LigneReglage(
                icone: Icons.warehouse_outlined,
                titre: 'Stocks et alertes',
                valeur: (stats?.alertesStock ?? 0) > 0
                    ? '${stats!.alertesStock} alerte(s)'
                    : null,
                onTap: () => context.go('/admin/stocks'),
              ),
              LigneReglage(
                icone: Icons.local_shipping_outlined,
                titre: 'Collectes',
                valeur: stats == null
                    ? null
                    : '${stats.collectesPlanifiees + stats.collectesEnCours} active(s)',
                onTap: () => context.go('/admin/collectes'),
              ),
              LigneReglage(
                icone: Icons.group_outlined,
                titre: 'Utilisateurs',
                valeur: stats == null ? null : '${stats.totalUsers}',
                onTap: () => context.go('/admin/utilisateurs'),
              ),
            ]),
            const Surtitre('Compte'),
            GroupeLignes([
              LigneReglage(
                icone: Icons.lock_outline_rounded,
                titre: 'Changer le mot de passe',
                onTap: () => afficherChangementMotDePasse(context),
              ),
              const LigneSons(),
              LigneReglage(
                icone: Icons.logout_rounded,
                titre: 'Se déconnecter',
                couleur: AppColors.rouge,
                onTap: () => ref.read(authProvider.notifier).logout(),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
