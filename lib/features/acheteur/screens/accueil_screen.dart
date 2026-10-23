import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/sons/sons_app.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/offline/offline_banner.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/categorie_chip.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/logo_anime.dart';
import '../../entreprise/widgets/espace_entreprise.dart';
import '../providers/catalogue_provider.dart';
import '../providers/panier_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/carrousel_annonces.dart';
import '../widgets/produit_card.dart';

class AccueilScreen extends ConsumerWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user        = ref.watch(authProvider).user;
    final catState    = ref.watch(catalogueProvider);
    final categories  = ref.watch(categoriesProvider);
    final connecte    = user != null;
    // Visiteur : pas de portefeuille (il demande un compte) ; le panier,
    // lui, se remplit sans compte comme sur le site
    final walletState = connecte ? ref.watch(walletProvider) : null;
    ref.watch(panierProvider); // pastille du panier à jour
    final nbPanier    = ref.read(panierProvider.notifier).nbArticles;
    final membre      = (user?.entreprises ?? const []).isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ── Barre supérieure ─────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
                      child: Row(
                        children: [
                          const LogoAnime(),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Makèt Peyizan',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3)),
                          ),
                          // Accès à l'espace entreprise (membres d'au moins
                          // une entreprise ; la création se fait depuis le Profil)
                          if (membre) ...[
                            BoutonRond(Icons.storefront_outlined,
                                tooltip: 'Espace entreprise',
                                onTap: () => ouvrirEspaceEntreprise(context, ref)),
                            const SizedBox(width: 8),
                          ],
                          BoutonRond(Icons.shopping_bag_outlined,
                              tooltip: 'Panier',
                              badge: nbPanier,
                              onTap: () => context.go('/acheteur/panier')),
                          if (!connecte) ...[
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () => context.go('/login'),
                              style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  padding: const EdgeInsets.symmetric(horizontal: 16)),
                              child: const Text('Connexion'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── Salutation + recherche ───────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(connecte ? 'Bonjour ${user.firstName}' : 'Bienvenue',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.grisTexte)),
                          const SizedBox(height: 2),
                          const Text('Le marché local,\nlivré chez vous.',
                              style: TextStyle(
                                  fontSize: 28,
                                  height: 1.1,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.9)),
                          const SizedBox(height: 18),
                          Material(
                            color: AppColors.blanc,
                            shape: const StadiumBorder(
                                side: BorderSide(color: AppColors.grisBord)),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => context.go('/acheteur/catalogue'),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                child: Row(
                                  children: [
                                    Icon(Icons.search_rounded,
                                        size: 21, color: AppColors.noir),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Haricots, maïs, café, légumes…',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: AppColors.grisLeger,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Bandeau + portefeuille ───────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Annonces du site (slides) ; bandeau fixe à défaut
                          CarrouselAnnonces(
                            secours: _Bandeau(
                                onTap: () => context.go('/acheteur/catalogue')),
                          ),
                          if (walletState != null) ...[
                          const SizedBox(height: 10),
                          Surface(
                            onTap: () => context.push('/acheteur/wallet'),
                            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                            child: Row(
                              children: [
                                const TuileIcone(
                                    Icons.account_balance_wallet_outlined,
                                    couleur: AppColors.vertFonce, taille: 38),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text('Mon portefeuille',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                ),
                                walletState.when(
                                  data: (w) => Text(FormatUtils.htg(w.solde),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  loading: () => const SizedBox(
                                    width: 14, height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 1.5),
                                  ),
                                  error: (_, __) => const Text('—'),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.grisLeger),
                              ],
                            ),
                          ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── Catégories ───────────────────────────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TitreSection('Catégories'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 46,
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

                  // ── Produits ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TitreSection('À la une',
                          action: 'Voir tout',
                          onAction: () => context.go('/acheteur/catalogue')),
                    ),
                  ),
                  if (catState.isLoading)
                    const SliverFillRemaining(child: LoadingWidget())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              onTap:   () => context.go(
                                '/acheteur/produit/${p.slug}',
                              ),
                              onAjouter: (bouton) async {
                                final err = await ref
                                    .read(panierProvider.notifier)
                                    .ajouter(p, 1);
                                if (err != null) {
                                  if (ctx.mounted) afficherMessage(ctx, err, succes: false);
                                } else if (bouton.mounted) {
                                  // Le produit « vole » jusqu'à l'onglet Panier, qui rebondit
                                  volerVersPanier(bouton,
                                      aLArrivee: () => SonsApp.jouer(SonApp.panier));
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
                          mainAxisSpacing:  12,
                          crossAxisSpacing: 10,
                        ),
                      ),
                    ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bandeau d'accueil clair (cf. maquettes) menant à la boutique : texte et
/// bouton à gauche, panier de produits stylisé à droite.
class _Bandeau extends StatelessWidget {
  final VoidCallback onTap;
  const _Bandeau({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.vertMenthe,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 172),
            child: Stack(
              children: [
                // Visuel : halo, panier et feuilles
                Positioned(
                  right: -26, top: -10, bottom: -10,
                  child: Container(
                    width: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.blanc.withValues(alpha: 0.55),
                    ),
                  ),
                ),
                const Positioned(
                  right: 18, bottom: 22,
                  child: Icon(Icons.shopping_basket_rounded,
                      size: 92, color: AppColors.vertFonce),
                ),
                const Positioned(
                  right: 92, top: 22,
                  child: Icon(Icons.eco_rounded,
                      size: 34, color: AppColors.vertVif),
                ),
                const Positioned(
                  right: 16, top: 16,
                  child: Icon(Icons.wb_sunny_rounded,
                      size: 30, color: AppColors.jaune),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 140, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Direct producteur',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.vertVif)),
                      const SizedBox(height: 4),
                      const Text("Produits frais\nd'Haïti",
                            style: TextStyle(
                                fontSize: 22,
                                height: 1.12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: AppColors.noir)),
                      const SizedBox(height: 4),
                      const Text('Au juste prix, sans intermédiaire',
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.grisTexte)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.noir,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text('Découvrir',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blanc)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
