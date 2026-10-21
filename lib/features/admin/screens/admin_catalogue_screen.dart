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

class AdminCatalogueScreen extends ConsumerWidget {
  const AdminCatalogueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminCatalogueProvider);

    return AdminScaffold(
      titre: 'Catalogue',
      retour: '/admin/plus',
      corps: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('$e')),
        data:    (produits) {
          if (produits.isEmpty) {
            return const EmptyState(
              icone: Icons.inventory_2_outlined, titre: 'Aucun produit',
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
                onActif: () => _basculer(context, ref, produits[i], vedette: false),
                onVedette: () => _basculer(context, ref, produits[i], vedette: true),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _basculer(BuildContext ctx, WidgetRef ref,
      Map<String, dynamic> p, {required bool vedette}) async {
    final id = p['id'] as int?;
    if (id == null) return;
    final n = ref.read(adminCatalogueProvider.notifier);
    final ok = vedette ? await n.toggleVedette(id) : await n.toggleActif(id);
    if (!ok && ctx.mounted) {
      afficherMessage(ctx, 'Modification impossible', succes: false);
    }
  }
}

class _LigneProduit extends StatelessWidget {
  final Map<String, dynamic> produit;
  final VoidCallback onActif;
  final VoidCallback onVedette;
  const _LigneProduit({
    required this.produit, required this.onActif, required this.onVedette,
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

    final vignette = Container(
      width: 56, height: 56,
      color: AppColors.surface2,
      child: const Icon(Icons.image_outlined, color: AppColors.grisLeger),
    );

    return Surface(
      padding: const EdgeInsets.all(12),
      child: Row(
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
      ),
    );
  }
}
