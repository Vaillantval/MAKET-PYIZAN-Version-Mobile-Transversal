import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../../../shared/ui/ui.dart';
import '../providers/panier_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_widget.dart';

class PanierScreen extends ConsumerWidget {
  const PanierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panierState = ref.watch(panierProvider);
    final nonVide = panierState.valueOrNull?.items.isNotEmpty ?? false;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EnTeteEcran(
              'Panier',
              surtitre: panierState.whenOrNull(
                  data: (p) => p.items.isEmpty
                      ? null
                      : '${p.nbArticles} article${p.nbArticles > 1 ? 's' : ''}'),
              actions: [
                if (nonVide)
                  TextButton(
                    onPressed: () => _confirmerVider(context, ref),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.grisTexte),
                    child: const Text('Vider'),
                  ),
              ],
            ),
            Expanded(
              child: panierState.when(
                loading: () => const LoadingWidget(message: 'Chargement du panier…'),
                error:   (e, _) => Center(child: Text('Erreur : $e')),
                data:    (panier) {
                  if (panier.items.isEmpty) {
                    return EmptyState(
                      icone:       Icons.shopping_bag_outlined,
                      titre:       'Votre panier est vide',
                      description: 'Ajoutez des produits depuis la boutique.',
                      boutonLabel: 'Voir la boutique',
                      onBouton:    () => context.go('/acheteur/catalogue'),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: panier.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final item = panier.items[i];
                            final vignette = Container(
                              width: 76, height: 76,
                              color: AppColors.surface2,
                              child: const Icon(Icons.image_outlined,
                                  color: AppColors.grisLeger),
                            );
                            return Surface(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: item.image != null
                                        ? CachedNetworkImage(
                                            imageUrl: ImageUtils.imageUrl(item.image),
                                            width: 76, height: 76,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) => vignette,
                                          )
                                        : vignette,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.producteurNom.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            letterSpacing: 0.8,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.grisLeger,
                                          ),
                                        ),
                                        Text(
                                          item.nom,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${FormatUtils.htg(item.prixUnitaire)} / ${item.uniteVente}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.grisTexte,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            _QuantiteControl(
                                              quantite:    item.quantite,
                                              stockMax:    item.stockReel,
                                              onIncrement: () => ref
                                                  .read(panierProvider.notifier)
                                                  .modifier(item.slug, item.quantite + 1),
                                              onDecrement: () {
                                                if (item.quantite <= 1) {
                                                  ref.read(panierProvider.notifier)
                                                      .retirer(item.slug);
                                                } else {
                                                  ref.read(panierProvider.notifier)
                                                      .modifier(item.slug, item.quantite - 1);
                                                }
                                              },
                                            ),
                                            const Spacer(),
                                            Flexible(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  FormatUtils.htg(item.sousTotal),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Récapitulatif ───────────────────────────
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        decoration: const BoxDecoration(
                          color: AppColors.blanc,
                          border: Border(top: BorderSide(color: AppColors.grisBord)),
                        ),
                        child: Column(
                          children: [
                            if (panier.producteurs.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline_rounded,
                                        size: 17, color: AppColors.grisTexte),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${panier.producteurs.length} vendeurs : '
                                        '${panier.producteurs.length} commandes seront créées.',
                                        style: const TextStyle(
                                            fontSize: 12.5,
                                            color: AppColors.grisTexte),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text('Sous-total',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.grisTexte)),
                                ),
                                Text(FormatUtils.htg(panier.total),
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () => context.go('/acheteur/checkout'),
                              child: const Text('Passer la commande'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmerVider(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vider le panier ?'),
        content: const Text('Tous les articles seront supprimés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(panierProvider.notifier).vider();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.rouge),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }
}

class _QuantiteControl extends StatelessWidget {
  final int quantite;
  final int stockMax;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantiteControl({
    required this.quantite,
    required this.stockMax,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.grisBord),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Btn(
          icon:  quantite <= 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
          onTap: onDecrement,
        ),
        SizedBox(
          width: 24,
          child: Text(
            '$quantite',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
        ),
        _Btn(
          icon:  Icons.add_rounded,
          onTap: quantite < stockMax ? onIncrement : null,
        ),
      ],
    ),
  );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _Btn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkResponse(
    onTap: onTap,
    radius: 18,
    child: SizedBox(
      width: 30, height: 30,
      child: Icon(icon,
        size:  16,
        color: onTap != null ? AppColors.noir : AppColors.grisLeger,
      ),
    ),
  );
}
