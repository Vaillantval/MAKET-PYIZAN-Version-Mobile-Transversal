import 'package:flutter/material.dart';
import '../../../shared/widgets/categorie_chip.dart';
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
import '../../entreprise/widgets/espace_entreprise.dart';

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
                          colors: [AppColors.vertFonce, AppColors.vertDegrade],
                          begin:  Alignment.topLeft,
                          end:    Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Flexible : sur petit écran le prénom se tronque
                              // au lieu de pousser les raccourcis hors de l'écran
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjou ${user?.firstName ?? ''} 👋',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Solde du portefeuille sous la salutation :
                                    // la ligne du haut garde la place pour le prénom
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
                                          mainAxisSize: MainAxisSize.min,
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
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  // Accès à l'espace entreprise (membres d'au
                                  // moins une entreprise ; la création se fait
                                  // depuis le Profil)
                                  if ((ref.watch(authProvider).user?.entreprises ??
                                          const [])
                                      .isNotEmpty) ...[
                                    Tooltip(
                                      message: 'Espace entreprise',
                                      child: GestureDetector(
                                        onTap: () =>
                                            ouvrirEspaceEntreprise(context, ref),
                                        child: const CircleAvatar(
                                          backgroundColor: Color(0x33FFFFFF),
                                          child: Icon(
                                            Icons.storefront_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
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
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.search,
                                    color: AppColors.vertFonce),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Chercher haricot, maïs, légumes...',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color:   AppColors.grisTexte,
                                        fontSize: 14,
                                      ),
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
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text(
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
                              return CategorieChip(
                                categorie: null,
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
                            return CategorieChip(
                              categorie: cat,
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
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
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
