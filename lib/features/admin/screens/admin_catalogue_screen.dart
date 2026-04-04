import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../providers/admin_catalogue_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class AdminCatalogueScreen extends ConsumerWidget {
  const AdminCatalogueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminCatalogueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue')),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('$e')),
        data:    (produits) {
          if (produits.isEmpty) {
            return const EmptyState(
              emoji: '🌿', titre: 'Aucun produit',
            );
          }

          return RefreshIndicator(
            color:     AppColors.vertVif,
            onRefresh: () =>
                ref.read(adminCatalogueProvider.notifier).charger(),
            child: ListView.builder(
              padding:   const EdgeInsets.all(12),
              itemCount: produits.length,
              itemBuilder: (_, i) {
                final p = produits[i];
                final imageUrl = p['image_principale'] as String?;
                return Container(
                  margin:  const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
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
                  child: Row(
                    children: [
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: ImageUtils.imageUrl(imageUrl),
                            width:  56, height: 56,
                            fit:    BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 56, height: 56,
                              color: AppColors.vertMenthe,
                              child: const Icon(Icons.eco,
                                color: AppColors.vertVif),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color:        AppColors.vertMenthe,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.eco,
                              color: AppColors.vertVif),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['nom'] as String? ?? '—',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color:      AppColors.vertFonce,
                              ),
                            ),
                            Text(
                              p['producteur_nom'] as String? ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color:    AppColors.grisTexte,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              p['is_active'] == true
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: p['is_active'] == true
                                  ? AppColors.vertVif
                                  : AppColors.grisTexte,
                            ),
                            onPressed: () => ref
                                .read(adminCatalogueProvider.notifier)
                                .toggleActif(
                                    p['slug'] as String? ?? ''),
                          ),
                          IconButton(
                            icon: Icon(
                              p['is_featured'] == true
                                  ? Icons.star
                                  : Icons.star_border,
                              color: p['is_featured'] == true
                                  ? AppColors.jaune
                                  : AppColors.grisTexte,
                            ),
                            onPressed: () => ref
                                .read(adminCatalogueProvider.notifier)
                                .toggleVedette(
                                    p['slug'] as String? ?? ''),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
