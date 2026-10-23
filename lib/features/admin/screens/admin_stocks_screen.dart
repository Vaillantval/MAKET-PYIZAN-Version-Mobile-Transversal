import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/ui/ui.dart';
import '../providers/admin_stocks_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/admin_scaffold.dart';

class AdminStocksScreen extends ConsumerStatefulWidget {
  const AdminStocksScreen({super.key});

  @override
  ConsumerState<AdminStocksScreen> createState() => _AdminStocksScreenState();
}

class _AdminStocksScreenState extends ConsumerState<AdminStocksScreen> {
  String _vue = 'alertes';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminStocksProvider);

    return AdminScaffold(
      titre: 'Stocks',
      retour: '/admin/plus',
      filtres: PastillesFiltre(
        options: [
          ('alertes', 'Alertes${_compte(state, 'alertes')}'),
          ('lots',    'Lots${_compte(state, 'lots')}'),
        ],
        valeur: _vue,
        onChanged: (v) => setState(() => _vue = v),
      ),
      corps: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => ErreurChargement(e),
        data:    (data) {
          final liste = (data[_vue] as List?)
                  ?.cast<Map<String, dynamic>>() ?? const [];
          if (liste.isEmpty) {
            return _vue == 'alertes'
                ? const EmptyState(
                    icone: Icons.task_alt_rounded,
                    titre: 'Aucune alerte de stock')
                : const EmptyState(
                    icone: Icons.inventory_2_outlined,
                    titre: 'Aucun lot enregistré');
          }
          return ListView.separated(
            padding:   const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: liste.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _vue == 'alertes'
                ? _CarteAlerte(liste[i])
                : _CarteLot(liste[i]),
          );
        },
      ),
    );
  }

  String _compte(AsyncValue<Map<String, dynamic>> s, String cle) {
    final n = (s.valueOrNull?[cle] as List?)?.length;
    return n == null ? '' : ' · $n';
  }
}

Color _couleurNiveau(String? niveau) => switch (niveau) {
      'critique' || 'rupture' => AppColors.rouge,
      'alerte' || 'bas'       => AppColors.orange,
      _                       => AppColors.bleu,
    };

class _CarteAlerte extends StatelessWidget {
  final Map<String, dynamic> a;
  const _CarteAlerte(this.a);

  @override
  Widget build(BuildContext context) {
    final couleur = _couleurNiveau(a['niveau'] as String?);
    final stock = num.tryParse('${a['stock_actuel']}') ?? 0;
    final seuil = num.tryParse('${a['seuil']}') ?? 0;
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TuileIcone(Icons.warning_amber_rounded, couleur: couleur, taille: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((a['produit_nom'] ?? a['produit'] ?? '—').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14.5)),
                    Text((a['producteur_nom'] ?? a['producteur'] ?? '').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.grisTexte)),
                  ],
                ),
              ),
              PuceStatut(
                  (a['niveau'] as String? ?? 'info').replaceAll('_', ' '),
                  couleur: couleur),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Stock $stock',
                  style: TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600, color: couleur)),
              const Spacer(),
              Text('Seuil $seuil',
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.grisTexte)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: seuil == 0 ? 0 : (stock / seuil).clamp(0, 1).toDouble(),
              minHeight: 6,
              color: couleur,
              backgroundColor: AppColors.surface2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteLot extends StatelessWidget {
  final Map<String, dynamic> l;
  const _CarteLot(this.l);

  @override
  Widget build(BuildContext context) {
    final qtAct  = num.tryParse('${l['quantite_actuelle']}') ?? 0;
    final qtInit = num.tryParse('${l['quantite_initiale']}') ?? 0;
    final taux   = qtInit == 0 ? 0.0 : (qtAct / qtInit).toDouble();
    final couleur = taux > 0.5
        ? AppColors.vertVif
        : taux > 0.2 ? AppColors.orange : AppColors.rouge;

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l['numero_lot'] as String? ?? '—',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14.5)),
              ),
              PuceStatut(
                  (l['statut_label'] ?? l['statut'] ?? '').toString(),
                  couleur: AppColors.grisTexte),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            [l['produit_nom'] ?? l['produit'], l['producteur_nom'] ?? l['producteur']]
                .where((v) => (v ?? '').toString().isNotEmpty)
                .join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: AppColors.grisTexte),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: taux.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.surface2,
                    color: couleur,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('$qtAct / $qtInit',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
