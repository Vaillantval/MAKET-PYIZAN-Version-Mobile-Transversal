import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../../../shared/ui/ui.dart';
import '../providers/admin_catalogue_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/admin_scaffold.dart';

/// Catalogue (superadmin) : filtres par statut, publication / vedette et
/// modération des produits soumis par les entreprises.
class AdminCatalogueScreen extends ConsumerStatefulWidget {
  /// Filtre ouvert d'emblée (ex. « en_attente » depuis un push admin_produit).
  final String? statutInitial;
  const AdminCatalogueScreen({this.statutInitial, super.key});

  @override
  ConsumerState<AdminCatalogueScreen> createState() => _AdminCatalogueScreenState();
}

class _AdminCatalogueScreenState extends ConsumerState<AdminCatalogueScreen> {
  static const _filtres = [
    ('', 'Tous'),
    ('en_attente', 'À valider'),
    ('refuse', 'Refusés'),
    ('actif', 'Publiés'),
    ('epuise', 'Épuisés'),
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.statutInitial;
    if (s != null && s != ref.read(adminCatalogueProvider.notifier).statut) {
      Future.microtask(() => ref.read(adminCatalogueProvider.notifier).charger(statut: s));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state  = ref.watch(adminCatalogueProvider);
    final statut = ref.read(adminCatalogueProvider.notifier).statut;

    return AdminScaffold(
      titre: 'Catalogue',
      retour: '/admin/plus',
      filtres: PastillesFiltre<String>(
        options: _filtres,
        valeur: statut,
        onChanged: (v) => setState(() {
          ref.read(adminCatalogueProvider.notifier).charger(statut: v);
        }),
      ),
      corps: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => ErreurChargement(e),
        data:    (produits) {
          if (produits.isEmpty) {
            return EmptyState(
              icone: Icons.inventory_2_outlined,
              titre: statut == 'en_attente' ? 'Rien à valider' : 'Aucun produit',
            );
          }
          return RefreshIndicator(
            color:     AppColors.vertFonce,
            onRefresh: () =>
                ref.read(adminCatalogueProvider.notifier).charger(),
            child: ListView.separated(
              padding:   const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: produits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _LigneProduit(
                produit: produits[i],
                onActif: () => _basculer(context, produits[i], vedette: false),
                onVedette: () => _basculer(context, produits[i], vedette: true),
                onApprouver: () => _moderer(context, produits[i], approuver: true),
                onRefuser: () => _demanderMotif(context, produits[i]),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _basculer(BuildContext ctx, Map<String, dynamic> p,
      {required bool vedette}) async {
    final id = p['id'] as int?;
    if (id == null) return;
    final n = ref.read(adminCatalogueProvider.notifier);
    final ok = vedette ? await n.toggleVedette(id) : await n.toggleActif(id);
    if (!ok && ctx.mounted) {
      afficherMessage(ctx, 'Modification impossible', succes: false);
    }
  }

  Future<void> _moderer(BuildContext ctx, Map<String, dynamic> p,
      {required bool approuver, String motif = ''}) async {
    final id = p['id'] as int?;
    if (id == null) return;
    final erreur = await ref
        .read(adminCatalogueProvider.notifier)
        .moderer(id, approuver: approuver, motif: motif);
    if (!ctx.mounted) return;
    afficherMessage(ctx,
        erreur ?? (approuver
            ? 'Produit validé et publié'
            : "Produit refusé — l'entreprise est prévenue"),
        succes: erreur == null);
  }

  Future<void> _demanderMotif(BuildContext ctx, Map<String, dynamic> p) async {
    final ctrl = TextEditingController();
    final motif = await showDialog<String>(
      context: ctx,
      builder: (dialogue) => AlertDialog(
        title: const Text('Refuser ce produit ?'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Motif transmis à l'entreprise (obligatoire)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogue),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.rouge),
            onPressed: () {
              final m = ctrl.text.trim();
              if (m.isNotEmpty) Navigator.pop(dialogue, m);
            },
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (motif != null && ctx.mounted) {
      await _moderer(ctx, p, approuver: false, motif: motif);
    }
  }
}

class _LigneProduit extends StatelessWidget {
  final Map<String, dynamic> produit;
  final VoidCallback onActif;
  final VoidCallback onVedette;
  final VoidCallback onApprouver;
  final VoidCallback onRefuser;
  const _LigneProduit({
    required this.produit, required this.onActif, required this.onVedette,
    required this.onApprouver, required this.onRefuser,
  });

  @override
  Widget build(BuildContext context) {
    final p = produit;
    final image = p['image_principale'] as String?;
    final vendeur = p['producteur_nom'] ??
        (p['producteur'] is Map ? (p['producteur'] as Map)['nom'] : null);
    final actif   = p['is_active'] == true;
    final vedette = p['is_featured'] == true;
    final stock   = p['stock_disponible'];
    final statut  = p['statut']?.toString() ?? '';
    final aValider = statut == 'en_attente' || statut == 'refuse';

    final vignette = Container(
      width: 56, height: 56,
      color: AppColors.surface2,
      child: const Icon(Icons.image_outlined, color: AppColors.grisLeger),
    );

    final ligne = Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image == null
                ? vignette
                : CachedNetworkImage(
                    imageUrl: ImageUtils.imageUrl(image),
                    width: 56, height: 56, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => vignette,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vendeur != null)
                  Text(vendeur.toString().toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10.5,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grisLeger)),
                Text(p['nom'] as String? ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  [
                    if (p['prix_unitaire'] != null) FormatUtils.htg(p['prix_unitaire']),
                    if (stock != null) 'Stock $stock',
                  ].join(' · '),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grisTexte),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: actif ? 'Masquer' : 'Publier',
            icon: Icon(
              actif ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: actif ? AppColors.noir : AppColors.grisLeger,
            ),
            onPressed: onActif,
          ),
          IconButton(
            tooltip: vedette ? 'Retirer de la vedette' : 'Mettre en vedette',
            icon: Icon(
              vedette ? Icons.star_rounded : Icons.star_outline_rounded,
              color: vedette ? AppColors.jaune : AppColors.grisLeger,
            ),
            onPressed: onVedette,
          ),
        ],
      );

    return Surface(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ligne,
          if (statut.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: PuceStatut(
                p['statut_label']?.toString() ?? statut,
                couleur: switch (statut) {
                  'en_attente'        => AppColors.orange,
                  'refuse'            => AppColors.rouge,
                  'actif' || 'epuise' => AppColors.vertVif,
                  _                   => AppColors.grisTexte,
                },
              ),
            ),
          ],
          if (statut == 'refuse' && '${p['motif_refus'] ?? ''}'.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Motif : ${p['motif_refus']}',
                style: const TextStyle(fontSize: 12.5, color: AppColors.rouge)),
          ],
          if (aValider) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRefuser,
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.rouge),
                    label: const Text('Refuser', style: TextStyle(color: AppColors.rouge)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprouver,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
