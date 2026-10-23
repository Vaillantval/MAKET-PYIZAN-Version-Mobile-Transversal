import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/ui/ui.dart';
import '../providers/admin_stats_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/offline/offline_banner.dart';
import '../../../core/notifications/notification_provider.dart';
import '../../../shared/ui/courbe_ventes.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats      = ref.watch(adminStatsProvider);
    final user       = ref.watch(authProvider).user;
    final notifCount = ref.watch(notificationProvider).unreadCount;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                color:     AppColors.vertFonce,
                onRefresh: () =>
                    ref.read(adminStatsProvider.notifier).charger(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    EnTeteEcran(
                      user?.firstName ?? 'Admin',
                      surtitre: 'Bonjour,',
                      padding: const EdgeInsets.fromLTRB(4, 12, 0, 16),
                      actions: [
                        BoutonRond(
                          Icons.notifications_none_rounded,
                          badge: notifCount,
                          tooltip: 'Notifications',
                          onTap: () => ref
                              .read(notificationProvider.notifier)
                              .markAllRead(),
                        ),
                      ],
                    ),
                    ...stats.when(
                      loading: () => const [
                        SizedBox(height: 200, child: LoadingWidget()),
                      ],
                      error: (e, _) => [
                        Surface(
                          child: Text('Statistiques indisponibles.\n$e',
                              style: const TextStyle(color: AppColors.grisTexte)),
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

  List<Widget> _contenu(BuildContext context, AdminStats s) {
    final alertes = [
      if (s.paiementsAVerifier > 0)
        LigneReglage(
          icone: Icons.account_balance_wallet_outlined,
          tuile: AppColors.violet,
          titre: '${s.paiementsAVerifier} paiement(s) à vérifier',
          onTap: () => context.go('/admin/paiements'),
        ),
      if (s.producteursAttente > 0)
        LigneReglage(
          icone: Icons.storefront_outlined,
          tuile: AppColors.bleu,
          titre: '${s.producteursAttente} entreprise(s) à valider',
          onTap: () => context.go('/admin/producteurs'),
        ),
      if (s.alertesStock > 0)
        LigneReglage(
          icone: Icons.inventory_2_outlined,
          tuile: AppColors.orange,
          titre: '${s.alertesStock} alerte(s) de stock',
          onTap: () => context.go('/admin/stocks'),
        ),
      if (s.commandesLitige > 0)
        LigneReglage(
          icone: Icons.report_gmailerrorred_rounded,
          tuile: AppColors.rouge,
          titre: '${s.commandesLitige} commande(s) en litige',
          onTap: () => context.go('/admin/commandes'),
        ),
      if (s.collectesEnRetard > 0)
        LigneReglage(
          icone: Icons.schedule_rounded,
          tuile: AppColors.rouge,
          titre: '${s.collectesEnRetard} collecte(s) en retard',
          onTap: () => context.go('/admin/collectes'),
        ),
    ];

    final autresCommandes = (s.totalCommandes -
            s.commandesEnAttente -
            s.commandesLivrees -
            s.commandesAnnulees -
            s.commandesLitige)
        .clamp(0, s.totalCommandes);

    return [
      // ── Revenus : en-tête vert forêt (cf. maquette tableau de bord) ──
      Surface(
        couleur: AppColors.noir,
        bordure: false,
        rayon: 26,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Revenus du mois',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xB8FFFFFF))),
                ),
                PuceStatut('${s.commandesMois} commande(s)',
                    couleur: AppColors.vertMoyen),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(FormatUtils.htg(s.revenuMois),
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blanc,
                      letterSpacing: -0.8)),
            ),
            const SizedBox(height: 14),
            BarreProgression(
              s.revenuMois == 0 ? 0 : s.revenu7j / s.revenuMois,
              couleur: AppColors.vertMoyen,
              fond: AppColors.blanc.withValues(alpha: 0.14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MiniStat('7 derniers jours', FormatUtils.htg(s.revenu7j)),
                ),
                Expanded(
                  child: _MiniStat('Depuis le début', FormatUtils.htg(s.revenuTotal)),
                ),
              ],
            ),
          ],
        ),
      ),

      if (s.ventesParJour.length > 1) ...[
        const SizedBox(height: 12),
        CourbeVentes(s.ventesParJour),
      ],

      if (alertes.isNotEmpty) ...[
        const TitreSection('À traiter'),
        GroupeLignes(alertes),
      ],

      // ── Indicateurs clés ────────────────────────────────────
      const TitreSection("Vue d'ensemble"),
      GrilleIndicateurs([
        CarteIndicateur(
          libelle: 'Commandes en attente',
          valeur: '${s.commandesEnAttente}',
          precision: 'sur ${s.totalCommandes} au total',
          icone: Icons.receipt_long_outlined,
          couleur: AppColors.orange,
          onTap: () => context.go('/admin/commandes'),
        ),
        CarteIndicateur(
          libelle: 'Paiements à vérifier',
          valeur: '${s.paiementsAVerifier}',
          precision: FormatUtils.htg(s.montantAVerifier),
          icone: Icons.account_balance_wallet_outlined,
          couleur: AppColors.violet,
          onTap: () => context.go('/admin/paiements'),
        ),
        CarteIndicateur(
          libelle: 'Entreprises actives',
          valeur: '${s.producteursActifs}',
          precision: '${s.producteursAttente} à valider',
          icone: Icons.storefront_outlined,
          couleur: AppColors.bleu,
          onTap: () => context.go('/admin/producteurs'),
        ),
        CarteIndicateur(
          libelle: 'Produits actifs',
          valeur: '${s.totalProduits}',
          precision: '${s.produitsEpuises} épuisé(s)',
          icone: Icons.inventory_2_outlined,
          couleur: AppColors.vertVif,
          onTap: () => context.go('/admin/catalogue'),
        ),
      ]),

      // ── Commandes ───────────────────────────────────────────
      TitreSection('Commandes',
          action: 'Voir tout', onAction: () => context.go('/admin/commandes')),
      Surface(
        child: Repartition(
          [
            ('En attente', s.commandesEnAttente, AppColors.orange),
            ('En cours', autresCommandes, AppColors.bleu),
            ('Livrées', s.commandesLivrees, AppColors.vertVif),
            ('Annulées', s.commandesAnnulees, AppColors.grisLeger),
            ('Litiges', s.commandesLitige, AppColors.rouge),
          ],
          centre: '${s.totalCommandes}',
          sousCentre: 'commandes',
          taille: 112,
        ),
      ),

      // ── Utilisateurs ────────────────────────────────────────
      TitreSection('Utilisateurs',
          action: 'Voir tout',
          onAction: () => context.go('/admin/utilisateurs')),
      Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${s.totalUsers}',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6)),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text('comptes · +${s.nouveauxUsers30j} en 30 jours',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.grisTexte)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BarresComparees([
              ('Acheteurs', s.totalAcheteurs, AppColors.vertVif),
              ('Entreprises', s.totalProducteurs, AppColors.bleu),
              ('Entreprises à valider', s.producteursAttente, AppColors.orange),
            ]),
          ],
        ),
      ),

      // ── Logistique ──────────────────────────────────────────
      TitreSection('Collectes et stock',
          action: 'Voir tout', onAction: () => context.go('/admin/collectes')),
      GrilleIndicateurs([
        CarteIndicateur(
          libelle: 'Collectes planifiées',
          valeur: '${s.collectesPlanifiees}',
          precision: '${s.collectesEnCours} en cours',
          icone: Icons.event_outlined,
          couleur: AppColors.bleu,
          onTap: () => context.go('/admin/collectes'),
        ),
        CarteIndicateur(
          libelle: 'Collectes en retard',
          valeur: '${s.collectesEnRetard}',
          icone: Icons.schedule_rounded,
          couleur: AppColors.rouge,
          onTap: () => context.go('/admin/collectes'),
        ),
        CarteIndicateur(
          libelle: 'Alertes de stock',
          valeur: '${s.alertesStock}',
          icone: Icons.warning_amber_rounded,
          couleur: AppColors.orange,
          onTap: () => context.go('/admin/stocks'),
        ),
        CarteIndicateur(
          libelle: 'Bons actifs',
          valeur: '${s.vouchersActifs}',
          icone: Icons.confirmation_number_outlined,
          couleur: AppColors.violet,
        ),
      ]),
    ];
  }
}

class _MiniStat extends StatelessWidget {
  final String libelle;
  final String valeur;
  const _MiniStat(this.libelle, this.valeur);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(libelle,
              style: TextStyle(fontSize: 12, color: AppColors.blanc.withValues(alpha: 0.72))),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valeur,
                style: const TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w700,
                    color: AppColors.blanc)),
          ),
        ],
      );
}
