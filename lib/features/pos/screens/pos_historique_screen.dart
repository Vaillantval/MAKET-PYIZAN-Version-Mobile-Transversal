import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/pos_sale.dart';
import '../providers/pos_vente_provider.dart';

class PosHistoriqueScreen extends ConsumerStatefulWidget {
  const PosHistoriqueScreen({super.key});

  @override
  ConsumerState<PosHistoriqueScreen> createState() => _PosHistoriqueScreenState();
}

class _PosHistoriqueScreenState extends ConsumerState<PosHistoriqueScreen> {
  bool _syncing = false;

  Future<void> _synchroniser() async {
    setState(() => _syncing = true);
    await ref.read(posHistoriqueProvider.notifier).synchroniserMaintenant();
    setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posHistoriqueProvider);
    final nbEnAttente = ref.watch(posHistoriqueProvider.notifier).nbEnAttente;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Historique du jour'),
            if (nbEnAttente > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$nbEnAttente en attente',
                    style: const TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: _syncing
                ? const SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Synchroniser maintenant',
            onPressed: _syncing ? null : _synchroniser,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.vertVif,
        onRefresh: () => ref.read(posHistoriqueProvider.notifier).charger(),
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.vertVif)),
          error:   (e, _) => Center(child: Text('Erreur : $e')),
          data: (ventes) {
            if (ventes.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: Text('Aucune vente aujourd\'hui.',
                          style: TextStyle(color: AppColors.grisTexte)),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: ventes.length,
              itemBuilder: (_, i) => _VenteTile(vente: ventes[i]),
            );
          },
        ),
      ),
    );
  }
}

class _VenteTile extends StatelessWidget {
  final PosSale vente;
  const _VenteTile({required this.vente});

  (Color, String) get _badge {
    switch (vente.syncStatus) {
      case 'synchronisee': return (AppColors.vertVif, 'Synchronisée');
      case 'rejetee':       return (AppColors.rouge, 'Rejetée');
      default:              return (AppColors.orange, 'En attente');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (couleur, label) = _badge;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: couleur.withValues(alpha: 0.12),
          child: Icon(Icons.point_of_sale, color: couleur, size: 20),
        ),
        title: Text(
          vente.numeroVente ?? 'Vente ${vente.idempotencyKey.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${FormatUtils.heure(vente.vendueLe)} — ${vente.items.length} article(s) — '
              '${vente.methodePaiement.toUpperCase()}',
              style: const TextStyle(fontSize: 12, color: AppColors.grisTexte),
            ),
            if (vente.montantWallet > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  vente.montantWallet >= vente.montantTotal
                      ? 'Portefeuille : ${FormatUtils.htg(vente.montantWallet)}'
                      : 'Portefeuille : ${FormatUtils.htg(vente.montantWallet)} + '
                        '${vente.methodePaiement.toUpperCase()} : '
                        '${FormatUtils.htg(vente.montantTotal - vente.montantWallet)}',
                  style: const TextStyle(
                    fontSize: 11, color: AppColors.vertFonce, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              FormatUtils.htg(vente.montantTotal),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: couleur)),
            ),
          ],
        ),
      ),
    );
  }
}
