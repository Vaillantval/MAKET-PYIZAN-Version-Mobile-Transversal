import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/entreprise_provider.dart';
import '../../../shared/ui/ui.dart';
import '../../entreprise/widgets/espace_entreprise.dart';
import '../providers/dashboard_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/offline/offline_banner.dart';
import '../../../shared/ui/courbe_ventes.dart';

class DashboardProducteurScreen extends ConsumerWidget {
  const DashboardProducteurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user       = ref.watch(authProvider).user;
    final dashState  = ref.watch(dashboardProvider);
    final entreprise = ref.watch(entrepriseActiveProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                color:     AppColors.vertFonce,
                onRefresh: () =>
                    ref.read(dashboardProvider.notifier).charger(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    EnTeteEcran(
                      entreprise?.nom ?? 'Mon entreprise',
                      surtitre: 'Bonjour ${user?.firstName ?? ''},',
                      padding: const EdgeInsets.fromLTRB(4, 12, 0, 16),
                      actions: [
                        // Retour rapide à l'espace acheteur
                        BoutonRond(
                          Icons.shopping_bag_outlined,
                          tooltip: 'Espace acheteur',
                          onTap: () => revenirEspaceAcheteur(context, ref),
                        ),
                      ],
                    ),
                    ...dashState.when(
                      loading: () => const [
                        SizedBox(height: 200, child: LoadingWidget()),
                      ],
                      error: (e, _) => [
                        Surface(
                          child: Text('Statistiques indisponibles.\n$e',
                              style: const TextStyle(
                                  color: AppColors.grisTexte)),
                        ),
                      ],
                      data: (s) => _contenu(context, s),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _contenu(BuildContext context, DashboardStats s) {
    final tauxLivraison =
        s.commandesTotal == 0 ? 0.0 : s.commandesLivrees / s.commandesTotal;
    final autres = (s.commandesTotal -
            s.commandesEnAttente -
            s.commandesConfirmees -
            s.commandesEnCours -
            s.commandesLivrees)
        .clamp(0, s.commandesTotal);

    return [
      // ── Revenus : en-tête vert forêt (cf. maquette tableau de bord) ──
      Surface(
        couleur: AppColors.noir,
        bordure: false,
        rayon: 26,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Revenus du mois',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xB8FFFFFF))),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(FormatUtils.htg(s.revenusMois),
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blanc,
                            letterSpacing: -0.8)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_outlined,
                          size: 15, color: Color(0x99FFFFFF)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Total ${FormatUtils.htg(s.revenusTotal)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xB8FFFFFF)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                AnneauProgression(
                  valeur: tauxLivraison,
                  couleur: AppColors.vertMoyen,
                  couleurTexte: AppColors.blanc,
                  taille: 70,
                ),
                const SizedBox(height: 6),
                const Text('livrées',
                    style: TextStyle(
                        fontSize: 11.5, color: Color(0xB8FFFFFF))),
              ],
            ),
          ],
        ),
      ),

      if (s.ventesParJour.length > 1) ...[
        const SizedBox(height: 12),
        CourbeVentes(s.ventesParJour),
      ],

      // ── À traiter ───────────────────────────────────────────
      const TitreSection('À suivre'),
      GrilleIndicateurs([
        CarteIndicateur(
          libelle: 'Commandes en attente',
          valeur: '${s.commandesEnAttente}',
          precision: 'à confirmer',
          icone: Icons.schedule_rounded,
          couleur: AppColors.orange,
          onTap: () => context.go('/producteur/commandes?statut=en_attente'),
        ),
        CarteIndicateur(
          libelle: 'Commandes confirmées',
          valeur: '${s.commandesConfirmees}',
          precision: 'à préparer',
          icone: Icons.inventory_2_outlined,
          couleur: AppColors.bleu,
          onTap: () => context.go('/producteur/commandes?statut=confirmee'),
        ),
        CarteIndicateur(
          libelle: 'Produits en ligne',
          valeur: '${s.nbProduitsActifs}',
          precision: '${s.nbProduitsEpuises} épuisé(s)',
          icone: Icons.storefront_outlined,
          couleur: AppColors.vertVif,
          onTap: () => context.go('/producteur/catalogue'),
        ),
        CarteIndicateur(
          libelle: 'Collectes à venir',
          valeur: '${s.collectesAVenir}',
          icone: Icons.local_shipping_outlined,
          couleur: AppColors.violet,
          onTap: () => context.go('/producteur/collectes'),
        ),
      ]),

      if (s.alertesStock > 0 || s.nbProduitsEpuises > 0) ...[
        const SizedBox(height: 12),
        GroupeLignes([
          if (s.alertesStock > 0)
            LigneReglage(
              icone: Icons.warning_amber_rounded,
              tuile: AppColors.orange,
              titre: '${s.alertesStock} alerte(s) de stock',
              sousTitre: 'Réapprovisionnez avant la rupture',
              onTap: () => context.go('/producteur/catalogue'),
            ),
          if (s.nbProduitsEpuises > 0)
            LigneReglage(
              icone: Icons.remove_shopping_cart_outlined,
              tuile: AppColors.rouge,
              titre: '${s.nbProduitsEpuises} produit(s) épuisé(s)',
              sousTitre: 'Invisibles à l\'achat tant que le stock est nul',
              onTap: () => context.go('/producteur/catalogue'),
            ),
        ]),
      ],

      // ── Commandes ───────────────────────────────────────────
      TitreSection('Commandes',
          action: 'Voir tout',
          onAction: () => context.go('/producteur/commandes')),
      Surface(
        child: Repartition(
          [
            ('En attente', s.commandesEnAttente, AppColors.orange),
            ('Confirmées', s.commandesConfirmees, AppColors.bleu),
            ('En cours', s.commandesEnCours, AppColors.violet),
            ('Livrées', s.commandesLivrees, AppColors.vertVif),
            ('Autres', autres, AppColors.grisLeger),
          ],
          centre: '${s.commandesTotal}',
          sousCentre: 'commandes',
          taille: 112,
        ),
      ),

      // ── Raccourcis ──────────────────────────────────────────
      const TitreSection('Raccourcis'),
      Row(
        children: [
          Expanded(
            child: _Raccourci(
              icone: Icons.add_rounded,
              libelle: 'Nouveau produit',
              couleur: AppColors.vertVif,
              onTap: () => context.go('/producteur/produit/nouveau'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Raccourci(
              icone: Icons.receipt_long_outlined,
              libelle: 'Commandes reçues',
              couleur: AppColors.bleu,
              onTap: () => context.go('/producteur/commandes'),
            ),
          ),
        ],
      ),
    ];
  }
}

class _Raccourci extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final Color couleur;
  final VoidCallback onTap;
  const _Raccourci({
    required this.icone,
    required this.libelle,
    required this.couleur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Surface(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            TuileIcone(icone, couleur: couleur, taille: 38, plein: true),
            const SizedBox(width: 10),
            Expanded(
              child: Text(libelle,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
