import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/catalogue_provider.dart';
import '../providers/panier_provider.dart';
import '../widgets/produit_card.dart';
import '../../../core/offline/offline_banner.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class CatalogueScreen extends ConsumerStatefulWidget {
  const CatalogueScreen({super.key});

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catState = ref.watch(catalogueProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Catalogue'),
        elevation: 0,
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Barre de recherche
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Chercher un produit...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  ref
                                      .read(catalogueProvider.notifier)
                                      .reinitialiser();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        if (value.isNotEmpty) {
                          ref
                              .read(catalogueProvider.notifier)
                              .appliquerFiltre(
                                catState.filtre.copyWith(search: value),
                              );
                        }
                      },
                    ),
                  ),
                ),

                // Catégories filtre
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: categories.when(
                      data: (cats) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: cats.length + 1,
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            return _FilterChip(
                              label: '🛒 Tout',
                              selected: catState.filtre.categorieSlug.isEmpty,
                              onTap: () => ref
                                  .read(catalogueProvider.notifier)
                                  .appliquerFiltre(
                                    catState.filtre
                                        .copyWith(categorieSlug: ''),
                                  ),
                            );
                          }
                          final cat = cats[i - 1];
                          final slug = cat['slug'] as String;
                          return _FilterChip(
                            label:
                                '${cat['icone'] ?? '🌿'} ${cat['nom']}',
                            selected:
                                catState.filtre.categorieSlug == slug,
                            onTap: () => ref
                                .read(catalogueProvider.notifier)
                                .appliquerFiltre(
                                  catState.filtre
                                      .copyWith(categorieSlug: slug),
                                ),
                          );
                        },
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                ),

                // Grille produits
                if (catState.isLoading)
                  const SliverFillRemaining(
                    child: LoadingWidget(
                      message: 'Chargement du catalogue...',
                    ),
                  )
                else if (catState.produits.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      emoji: '🔍',
                      titre: 'Aucun produit trouvé',
                      description: 'Essayez une autre recherche.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          if (i == catState.produits.length) {
                            if (!catState.hasMore) return null;
                            return Center(
                              child: catState.isLoadingMore
                                  ? const CircularProgressIndicator(
                                      color: AppColors.vertVif)
                                  : ElevatedButton(
                                      onPressed: () => ref
                                          .read(
                                              catalogueProvider.notifier)
                                          .chargerPlus(),
                                      child: const Text('Voir plus'),
                                    ),
                            );
                          }
                          final p = catState.produits[i];
                          return ProduitCard(
                            produit: p,
                            onTap: () => context
                                .go('/acheteur/produit/${p.slug}'),
                            onAjouter: () async {
                              final err = await ref
                                  .read(panierProvider.notifier)
                                  .ajouter(p.slug, 1);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      err == null
                                          ? '✅ ${p.nom} ajouté'
                                          : '❌ $err',
                                    ),
                                    backgroundColor: err == null
                                        ? AppColors.vertVif
                                        : AppColors.rouge,
                                    duration:
                                        const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          );
                        },
                        childCount: catState.produits.length +
                            (catState.hasMore ? 1 : 0),
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 10,
                      ),
                    ),
                  ),

                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 80),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.vertFonce : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.vertFonce : const Color(0xFFDDDDDD),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.noir,
        ),
      ),
    ),
  );
}
