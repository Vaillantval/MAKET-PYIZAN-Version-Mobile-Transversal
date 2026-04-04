import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_stocks_provider.dart';
import '../../../shared/widgets/loading_widget.dart';

class AdminStocksScreen extends ConsumerStatefulWidget {
  const AdminStocksScreen({super.key});

  @override
  ConsumerState<AdminStocksScreen> createState() =>
      _AdminStocksScreenState();
}

class _AdminStocksScreenState
    extends ConsumerState<AdminStocksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminStocksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks & Alertes'),
        bottom: TabBar(
          controller:          _tabs,
          labelColor:          AppColors.jaune,
          unselectedLabelColor: Colors.white70,
          indicatorColor:      AppColors.jaune,
          tabs: const [
            Tab(text: '⚠️ Alertes'),
            Tab(text: '📦 Lots'),
          ],
        ),
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('$e')),
        data:    (data) => TabBarView(
          controller: _tabs,
          children: [
            _AlertesList(
              alertes: (data['alertes'] as List?)
                  ?.cast<Map<String, dynamic>>() ?? [],
            ),
            _LotsList(
              lots: (data['lots'] as List?)
                  ?.cast<Map<String, dynamic>>() ?? [],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertesList extends StatelessWidget {
  final List<Map<String, dynamic>> alertes;
  const _AlertesList({required this.alertes});

  @override
  Widget build(BuildContext context) {
    if (alertes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✅', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Aucune alerte de stock',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.vertFonce,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding:   const EdgeInsets.all(12),
      itemCount: alertes.length,
      itemBuilder: (_, i) {
        final a = alertes[i];
        final niveauColor = {
          'critique': AppColors.rouge,
          'alerte':   AppColors.orange,
          'bas':      AppColors.statutAttente,
          'info':     AppColors.bleu,
        }[a['niveau']] ?? AppColors.grisTexte;

        return Container(
          margin:  const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: niveauColor.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color:     Colors.black.withOpacity(0.05),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width:  6,
                height: 50,
                decoration: BoxDecoration(
                  color:        niveauColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['produit'] as String? ?? '—',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.vertFonce,
                      ),
                    ),
                    Text(
                      a['producteur'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color:    AppColors.grisTexte,
                      ),
                    ),
                    Text(
                      'Stock : ${a['stock_actuel']} '
                      '(seuil : ${a['seuil']})',
                      style: TextStyle(
                        fontSize: 12,
                        color:    niveauColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:        niveauColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (a['niveau'] as String? ?? '')
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize:   10,
                    fontWeight: FontWeight.w800,
                    color:      niveauColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LotsList extends StatelessWidget {
  final List<Map<String, dynamic>> lots;
  const _LotsList({required this.lots});

  @override
  Widget build(BuildContext context) {
    if (lots.isEmpty) {
      return const Center(
        child: Text('Aucun lot disponible'),
      );
    }

    return ListView.builder(
      padding:   const EdgeInsets.all(12),
      itemCount: lots.length,
      itemBuilder: (_, i) {
        final l = lots[i];
        final qtAct  = l['quantite_actuelle'] as int? ?? 0;
        final qtInit = l['quantite_initiale'] as int? ?? 1;
        final taux   = qtAct / qtInit;

        return Container(
          margin:  const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:     Colors.black.withOpacity(0.05),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l['numero_lot'] as String? ?? '—',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.vertFonce,
                    ),
                  ),
                  Text(
                    l['statut'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color:    AppColors.grisTexte,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${l['produit']} — ${l['producteur']}',
                style: const TextStyle(
                  fontSize: 13,
                  color:    AppColors.grisTexte,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value:      taux.clamp(0.0, 1.0),
                        minHeight:  8,
                        backgroundColor: Colors.grey[200],
                        color:      taux > 0.5
                            ? AppColors.vertVif
                            : taux > 0.2
                                ? AppColors.orange
                                : AppColors.rouge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$qtAct / $qtInit kg',
                    style: const TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
