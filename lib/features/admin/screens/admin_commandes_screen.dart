import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/ui/ui.dart';
import '../providers/admin_commandes_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/statut_selector.dart';

class AdminCommandesScreen extends ConsumerStatefulWidget {
  const AdminCommandesScreen({super.key});

  @override
  ConsumerState<AdminCommandesScreen> createState() =>
      _AdminCommandesScreenState();
}

class _AdminCommandesScreenState extends ConsumerState<AdminCommandesScreen> {
  String _statut = '';

  static const _filtres = [
    ('',               'Toutes'),
    ('en_attente',     'En attente'),
    ('confirmee',      'Confirmées'),
    ('en_preparation', 'En préparation'),
    ('livree',         'Livrées'),
    ('litige',         'Litiges'),
    ('annulee',        'Annulées'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCommandesProvider);

    return AdminScaffold(
      titre: 'Commandes',
      sousTitre: state.whenOrNull(data: (l) => '${l.length} commande(s)'),
      filtres: PastillesFiltre(
        options: _filtres,
        valeur: _statut,
        onChanged: (v) => setState(() => _statut = v),
      ),
      corps: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => ErreurChargement(e),
        data:    (liste) {
          final commandes = _statut.isEmpty
              ? liste
              : liste.where((c) => c['statut'] == _statut).toList();
          if (commandes.isEmpty) {
            return const EmptyState(
              icone: Icons.receipt_long_outlined,
              titre: 'Aucune commande',
            );
          }
          return RefreshIndicator(
            color:     AppColors.vertFonce,
            onRefresh: () =>
                ref.read(adminCommandesProvider.notifier).charger(),
            child: ListView.separated(
              padding:   const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: commandes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _CarteCommande(
                commande: commandes[i],
                onStatut: () => _changerStatut(
                  context, commandes[i]['numero_commande'] as String? ?? ''),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _changerStatut(BuildContext ctx, String numero) async {
    final statut = await showStatutSelector(
      ctx,
      titre: 'Changer le statut',
      options: const [
        ('confirmee',      'Confirmée'),
        ('en_preparation', 'En préparation'),
        ('prete',          'Prête'),
        ('en_collecte',    'En collecte'),
        ('livree',         'Livrée'),
        ('litige',         'Litige'),
        ('annulee',        'Annulée'),
      ],
    );
    if (statut == null || !ctx.mounted) return;

    final success = await ref
        .read(adminCommandesProvider.notifier)
        .changerStatut(numero, statut);
    if (ctx.mounted) {
      afficherMessage(ctx,
          success ? 'Statut mis à jour' : 'Le statut n\'a pas pu être changé',
          succes: success);
    }
  }
}

class _CarteCommande extends StatelessWidget {
  final Map<String, dynamic> commande;
  final VoidCallback onStatut;
  const _CarteCommande({required this.commande, required this.onStatut});

  @override
  Widget build(BuildContext context) {
    final c = commande;
    final statut = StyleStatut.de(c['statut'] as String?,
        libelle: c['statut_label'] as String?);
    final acheteur = (c['acheteur_nom'] ?? c['acheteur'] ?? '').toString();
    final vendeur  = (c['producteur_nom'] ?? '').toString();

    return Surface(
      onTap: onStatut,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TuileIcone(statut.icone, couleur: statut.couleur, taille: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(c['numero_commande'] as String? ?? '—',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14.5)),
                    ),
                    const SizedBox(width: 8),
                    Text(FormatUtils.htg(c['total']),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [acheteur, vendeur].where((t) => t.isNotEmpty).join(' → '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.grisTexte),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(child: statut.puce()),
                    const SizedBox(width: 8),
                    Text(FormatUtils.date(c['created_at'] as String?),
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.grisLeger)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
