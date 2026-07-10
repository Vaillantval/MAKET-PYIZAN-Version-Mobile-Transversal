import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../providers/catalogue_provider.dart';
import '../providers/panier_provider.dart';
import '../widgets/produit_card.dart';
import '../../../core/offline/offline_banner.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/wallet_provider.dart';

class AccueilScreen extends ConsumerWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user       = ref.watch(authProvider).user;
    final catState   = ref.watch(catalogueProvider);
    final categories = ref.watch(categoriesProvider);
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ── Header ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.vertFonce, Color(0xFF1E8449)],
                          begin:  Alignment.topLeft,
                          end:    Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bonjou ${user?.firstName ?? ''} 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'PlayfairDisplay',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Text(
                                    'Kisa ou bezwen jodi a ?',
                                    style: TextStyle(
                                      color: Color(0xBBFFFFFF),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Badge Portefeuille
                                  GestureDetector(
                                    onTap: () => context.push('/acheteur/wallet'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x33FFFFFF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.account_balance_wallet_outlined,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          walletState.when(
                                            data: (w) => Text(
                                              FormatUtils.htg(w.solde),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            loading: () => const SizedBox(
                                              width: 12, height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                color: Colors.white,
                                              ),
                                            ),
                                            error: (_, __) => const Text(
                                              'Solde',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Badge panier
                                  GestureDetector(
                                    onTap: () => context.go('/acheteur/panier'),
                                    child: Stack(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Color(0x33FFFFFF),
                                          child: Icon(
                                            Icons.shopping_cart_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0, right: 0,
                                          child: Consumer(
                                            builder: (_, ref, __) {
                                              final nb = ref
                                                  .watch(panierProvider.notifier)
                                                  .nbArticles;
                                              if (nb == 0) return const SizedBox.shrink();
                                              return Container(
                                                width:  18, height: 18,
                                                decoration: const BoxDecoration(
                                                  color:  AppColors.jaune,
                                                  shape:  BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '$nb',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.noir,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Barre de recherche
                          GestureDetector(
                            onTap: () => context.go('/acheteur/catalogue'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:        Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.search,
                                    color: AppColors.grisTexte),
                                  SizedBox(width: 10),
                                  Text(
                                    'Chercher haricot, maïs, légumes...',
                                    style: TextStyle(
                                      color:   AppColors.grisTexte,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Catégories ───────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: const Text(
                        'Catégories',
                        style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800,
                          color: AppColors.vertFonce,
                        ),
                      ),
                    ),
                  ),
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
                              return _CategorieChip(
                                label:    '🛒 Tout',
                                selected: catState.filtre.categorieSlug.isEmpty,
                                onTap: () => ref
                                    .read(catalogueProvider.notifier)
                                    .appliquerFiltre(
                                      catState.filtre.copyWith(categorieSlug: ''),
                                    ),
                              );
                            }
                            final cat = cats[i - 1];
                            final slug = cat['slug'] as String;
                            return _CategorieChip(
                              label:    '${cat['icone'] ?? '🌿'} ${cat['nom']}',
                              selected: catState.filtre.categorieSlug == slug,
                              onTap: () => ref
                                  .read(catalogueProvider.notifier)
                                  .appliquerFiltre(
                                    catState.filtre.copyWith(categorieSlug: slug),
                                  ),
                            );
                          },
                        ),
                        loading: () => const SizedBox.shrink(),
                        error:   (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ),

                  // ── Produits en vedette ───────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '⭐ En vedette',
                            style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800,
                              color: AppColors.vertFonce,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/acheteur/catalogue'),
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Grille produits ───────────────────────────
                  if (catState.isLoading)
                    const SliverFillRemaining(child: LoadingWidget())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            if (i == catState.produits.length) {
                              // Bouton charger plus
                              if (!catState.hasMore) return null;
                              return Center(
                                child: catState.isLoadingMore
                                    ? const CircularProgressIndicator(
                                        color: AppColors.vertVif)
                                    : ElevatedButton(
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
                              onTap:   () => context.go(
                                '/acheteur/produit/${p.slug}',
                              ),
                              onAjouter: () async {
                                final err = await ref
                                    .read(panierProvider.notifier)
                                    .ajouter(p.slug, 1);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        err == null
                                            ? '✅ ${p.nom} ajouté au panier'
                                            : '❌ $err',
                                      ),
                                      backgroundColor: err == null
                                          ? AppColors.vertVif
                                          : AppColors.rouge,
                                      duration: const Duration(seconds: 2),
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
                          crossAxisCount:   2,
                          childAspectRatio: 0.72,
                          mainAxisSpacing:  12,
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
      ),
    );
  }
}

class _CategorieChip extends StatelessWidget {
  final String label;
  final bool   selected;
  final VoidCallback onTap;
  const _CategorieChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          fontSize:   13,
          fontWeight: FontWeight.w600,
          color:      selected ? Colors.white : AppColors.noir,
        ),
      ),
    ),
  );
}
