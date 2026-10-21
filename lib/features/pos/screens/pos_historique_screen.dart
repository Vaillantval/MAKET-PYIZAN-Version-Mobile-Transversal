import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/printing/pos_printer_service.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/pos_sale.dart';
import '../../../providers/auth_provider.dart';
import '../providers/pos_device_provider.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/pos_vente_provider.dart';

class PosHistoriqueScreen extends ConsumerStatefulWidget {
  const PosHistoriqueScreen({super.key});

  @override
  ConsumerState<PosHistoriqueScreen> createState() => _PosHistoriqueScreenState();
}

class _PosHistoriqueScreenState extends ConsumerState<PosHistoriqueScreen> {
  bool _syncing = false;
  String _filtre = 'toutes';

  Future<void> _synchroniser() async {
    setState(() => _syncing = true);
    await ref.read(posHistoriqueProvider.notifier).synchroniserMaintenant();
    if (mounted) setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posHistoriqueProvider);
    final nbEnAttente = ref.watch(posHistoriqueProvider.notifier).nbEnAttente;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.vertFonce,
          onRefresh: () => ref.read(posHistoriqueProvider.notifier).charger(),
          child: state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:   (e, _) => Center(child: Text('Erreur : $e')),
            data: (toutes) {
              final ventes = switch (_filtre) {
                'attente' => toutes.where((v) => v.syncStatus == 'enAttente').toList(),
                'rejetee' => toutes.where((v) => v.syncStatus == 'rejetee').toList(),
                _         => toutes,
              };
              final chiffre = toutes.fold<double>(0, (t, v) => t + v.montantTotal);
              final wallet  = toutes.fold<double>(0, (t, v) => t + v.montantWallet);

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  EnTeteEcran(
                    'Historique',
                    surtitre: "Ventes d'aujourd'hui",
                    padding: const EdgeInsets.fromLTRB(4, 12, 0, 12),
                    actions: [
                      BoutonRond(
                        _syncing ? Icons.hourglass_top_rounded : Icons.sync_rounded,
                        tooltip: 'Synchroniser maintenant',
                        badge: nbEnAttente,
                        onTap: _syncing ? null : _synchroniser,
                      ),
                    ],
                  ),
                  GrilleIndicateurs([
                    CarteIndicateur(
                      libelle: 'Ventes',
                      valeur: '${toutes.length}',
                      precision: nbEnAttente > 0
                          ? '$nbEnAttente à synchroniser'
                          : 'toutes synchronisées',
                      icone: Icons.receipt_long_outlined,
                      couleur: nbEnAttente > 0 ? AppColors.orange : AppColors.bleu,
                    ),
                    CarteIndicateur(
                      libelle: "Chiffre d'affaires",
                      valeur: FormatUtils.htg(chiffre),
                      precision: wallet > 0 ? 'dont ${FormatUtils.htg(wallet)} portefeuille' : null,
                      icone: Icons.payments_outlined,
                      couleur: AppColors.vertVif,
                    ),
                  ], hauteur: 112),
                  const SizedBox(height: 14),
                  PastillesFiltre(
                    padding: EdgeInsets.zero,
                    options: const [
                      ('toutes',  'Toutes'),
                      ('attente', 'À synchroniser'),
                      ('rejetee', 'Rejetées'),
                    ],
                    valeur: _filtre,
                    onChanged: (v) => setState(() => _filtre = v),
                  ),
                  const SizedBox(height: 12),
                  if (ventes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: EmptyState(
                        icone: Icons.receipt_long_outlined,
                        titre: 'Aucune vente',
                        description: 'Les ventes de la journée apparaîtront ici.',
                      ),
                    )
                  else
                    GroupeLignes([for (final v in ventes) _VenteTile(vente: v)]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VenteTile extends ConsumerStatefulWidget {
  final PosSale vente;
  const _VenteTile({required this.vente});

  @override
  ConsumerState<_VenteTile> createState() => _VenteTileState();
}

class _VenteTileState extends ConsumerState<_VenteTile> {
  bool _impressionEnCours = false;

  (Color, String) get _badge {
    switch (widget.vente.syncStatus) {
      case 'synchronisee': return (AppColors.vertVif, 'Synchronisée');
      case 'rejetee':       return (AppColors.rouge, 'Rejetée');
      default:              return (AppColors.orange, 'En attente');
    }
  }

  Future<void> _reimprimer() async {
    setState(() => _impressionEnCours = true);

    final user       = ref.read(authProvider).user;
    final deviceUid  = ref.read(posDeviceUidProvider);
    final nomComplet = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    // Note : le nom client et le montant reçu (cash) ne sont pas
    // persistés dans l'historique local — un reçu réimprimé n'affiche
    // donc pas ces deux détails, contrairement au reçu imprimé à chaud.
    final resultat = await ref.read(posPrinterProvider.notifier).imprimerRecu(
      widget.vente,
      nomOperateur: nomComplet.isNotEmpty ? nomComplet : (user?.username ?? 'Opérateur'),
      nomCaisse: deviceUid ?? 'POS',
    );

    if (!mounted) return;
    setState(() => _impressionEnCours = false);

    if (resultat.indisponible) return;

    final messenger = ScaffoldMessenger.of(context);
    if (resultat.succes) {
      afficherMessage(context, 'Reçu réimprimé');
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(resultat.erreur ?? 'Erreur d\'impression du reçu.'),
        backgroundColor: AppColors.rouge,
        action: SnackBarAction(label: 'Réessayer', textColor: Colors.white, onPressed: _reimprimer),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vente = widget.vente;
    final (couleur, label) = _badge;
    final imprimanteDisponible = ref.watch(posPrinterProvider).disponible;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TuileIcone(Icons.receipt_long_outlined, couleur: couleur, taille: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vente.numeroVente ?? 'Vente ${vente.idempotencyKey.substring(0, 8)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    Text(
                      FormatUtils.htg(vente.montantTotal),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${FormatUtils.heure(vente.vendueLe)} · ${vente.items.length} article(s) · '
                  '${vente.methodePaiement.toUpperCase()}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grisTexte),
                ),
                if (vente.montantWallet > 0)
                  Text(
                    vente.montantWallet >= vente.montantTotal
                        ? 'Portefeuille ${FormatUtils.htg(vente.montantWallet)}'
                        : 'Portefeuille ${FormatUtils.htg(vente.montantWallet)} + '
                          '${vente.methodePaiement.toUpperCase()} '
                          '${FormatUtils.htg(vente.montantTotal - vente.montantWallet)}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.grisTexte),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    PuceStatut(label, couleur: couleur),
                    if (vente.stockConflict) ...[
                      const SizedBox(width: 6),
                      const PuceStatut('Conflit de stock', couleur: AppColors.orange,
                          icone: Icons.warning_amber_rounded),
                    ],
                  ],
                ),
                if (vente.syncStatus == 'rejetee' && vente.erreurSync != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      vente.erreurSync!,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.rouge),
                    ),
                  ),
              ],
            ),
          ),
          if (imprimanteDisponible)
            IconButton(
              icon: _impressionEnCours
                  ? const SizedBox(
                      height: 16, width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.print_outlined, size: 20),
              tooltip: 'Réimprimer',
              onPressed: _impressionEnCours ? null : _reimprimer,
            ),
        ],
      ),
    );
  }
}
