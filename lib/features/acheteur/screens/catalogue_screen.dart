import 'package:flutter/material.dart';
import '../../../shared/widgets/categorie_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/catalogue_provider.dart';
import '../providers/panier_provider.dart';
import '../widgets/produit_card.dart';
import '../../../core/offline/offline_banner.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/ui/ui.dart';

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OfflineBanner(),
            EnTeteEcran('Boutique',
                surtitre: catState.isLoading
                    ? null
                    : '${catState.produits.length}${catState.hasMore ? '+' : ''} produit(s)'),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Barre de recherche
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: TextField(
                        controller: _searchCtrl,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Chercher un produit…',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.noir),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(color: AppColors.grisBord),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(color: AppColors.grisBord),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide:
                                BorderSide(color: AppColors.noir, width: 1.4),
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    ref
                                        .read(catalogueProvider.notifier)
                                        .reinitialiser();
                                  },
                                )
                              : null,
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
                      height: 42,
                      child: categories.when(
                        data: (cats) => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: cats.length + 1,
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              return CategorieChip(
                                categorie: null,
                                compact: true,
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
                            return CategorieChip(
                              categorie: cat,
                              compact: true,
                              selected: catState.filtre.categorieSlug == slug,
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
                    const SliverFillRemaining(
                      child: EmptyState(
                        icone: Icons.search_off_rounded,
                        titre: 'Aucun produit trouvé',
                        description: 'Essayez une autre recherche.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            if (i == catState.produits.length) {
                              if (!catState.hasMore) return null;
                              return Center(
                                child: catState.isLoadingMore
                                    ? const CircularProgressIndicator()
                                    : OutlinedButton(
                                        onPressed: () => ref
                                            .read(catalogueProvider.notifier)
                                            .chargerPlus(),
                                        child: const Text('Voir plus'),
                                      ),
                              );
                            }
                            final p = catState.produits[i];
                            return ProduitCard(
                              produit: p,
                              onTap: () =>
                                  context.go('/acheteur/produit/${p.slug}'),
                              onAjouter: () async {
                                final err = await ref
                                    .read(panierProvider.notifier)
                                    .ajouter(p, 1);
                                if (ctx.mounted) {
                                  afficherMessage(
                                      ctx, err ?? '${p.nom} ajouté au panier',
                                      succes: err == null);
                                }
                              },
                            );
                          },
                          childCount: catState.produits.length +
                              (catState.hasMore ? 1 : 0),
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 0.66,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 10,
                        ),
                      ),
                    ),

                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
