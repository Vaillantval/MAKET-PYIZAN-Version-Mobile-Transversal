import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/produit.dart';
import '../providers/mes_produits_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/ui/ui.dart';

class MesProduitsScreen extends ConsumerWidget {
  const MesProduitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mesProduitsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/producteur/produit/nouveau'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Produit'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EnTeteEcran('Mes produits',
                surtitre: state.whenOrNull(
                    data: (l) => '${l.length} produit(s)')),
            Expanded(
              child: state.when(
                loading: () => const LoadingWidget(),
                error:   (e, _) => ErreurChargement(e),
                data:    (produits) {
                  if (produits.isEmpty) {
                    return EmptyState(
                      icone:       Icons.inventory_2_outlined,
                      titre:       'Aucun produit',
                      description: 'Ajoutez votre premier produit.',
                      boutonLabel: 'Ajouter un produit',
                      onBouton: () =>
                          context.push('/producteur/produit/nouveau'),
                    );
                  }

                  return RefreshIndicator(
                    color:     AppColors.vertFonce,
                    onRefresh: () =>
                        ref.read(mesProduitsProvider.notifier).charger(),
                    child: ListView.separated(
                      padding:   const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: produits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final p = produits[i];
                        final vignette = Container(
                          width: 64, height: 64,
                          color: AppColors.surface2,
                          child: const Icon(Icons.image_outlined,
                              color: AppColors.grisLeger),
                        );
                        return Surface(
                          onTap: () => context.push(
                            '/producteur/produit/${p.slug}/modifier',
                          ),
                          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: p.imagePrincipale != null
                                    ? CachedNetworkImage(
                                        imageUrl: ImageUtils.imageUrl(
                                            p.imagePrincipale),
                                        width: 64, height: 64,
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
                                    Text(p.nom,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize:   14.5,
                                      ),
                                    ),
                                    Text(
                                      '${FormatUtils.htg(p.prixUnitaire)} / ${p.uniteVenteLabel}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color:    AppColors.grisTexte,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        _BadgeModeration(produit: p),
                                        if (p.statut == 'actif') _StockBadge(stock: p.stockReel),
                                      ],
                                    ),
                                    if (p.enValidation || p.refuse) ...[
                                      const SizedBox(height: 8),
                                      _NoteModeration(produit: p),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded,
                                    color: AppColors.grisTexte),
                                onSelected: (v) => v == 'modifier'
                                    ? context.push('/producteur/produit/${p.slug}/modifier')
                                    : _confirmerSuppression(context, ref, p.slug),
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'modifier', child: Text('Modifier')),
                                  PopupMenuItem(value: 'supprimer', child: Text('Supprimer')),
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
            ),
          ],
        ),
      ),
    );
  }

  void _confirmerSuppression(
    BuildContext ctx, WidgetRef ref, String slug,
  ) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title:   const Text('Supprimer ce produit ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(mesProduitsProvider.notifier)
                  .supprimer(slug);
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.rouge),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

/// Statut de modération (statut_label du serveur) : orange en validation,
/// rouge refusé, vert publié.
class _BadgeModeration extends StatelessWidget {
  final Produit produit;
  const _BadgeModeration({required this.produit});

  @override
  Widget build(BuildContext context) {
    final couleur = switch (produit.statut) {
      'en_attente'        => AppColors.orange,
      'refuse'            => AppColors.rouge,
      'actif' || 'epuise' => AppColors.vertVif,
      _                   => AppColors.grisTexte,
    };
    final libelle = produit.statutLabel.isNotEmpty
        ? produit.statutLabel
        : switch (produit.statut) {
            'en_attente' => 'En attente de validation',
            'refuse'     => 'Refusé',
            'actif'      => 'Publié',
            'epuise'     => 'Épuisé',
            ''           => '—',
            final s      => s,
          };
    return PuceStatut(libelle, couleur: couleur);
  }
}

class _NoteModeration extends StatelessWidget {
  final Produit produit;
  const _NoteModeration({required this.produit});

  @override
  Widget build(BuildContext context) {
    final refuse = produit.refuse;
    final couleur = refuse ? AppColors.rouge : AppColors.orange;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.teinte(couleur),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        refuse
            ? '${produit.motifRefus.isNotEmpty ? 'Motif : ${produit.motifRefus}\n' : ''}'
                'Modifiez le produit : il sera soumis à nouveau.'
            : 'En cours de validation : invisible aux acheteurs pour le moment.',
        style: TextStyle(fontSize: 12.5, height: 1.35, color: refuse ? AppColors.rouge : AppColors.noir),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;
  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    if (stock == 0) return const PuceStatut('Épuisé', couleur: AppColors.rouge);
    if (stock <= 5) {
      return PuceStatut('Stock faible · $stock', couleur: AppColors.orange);
    }
    return PuceStatut('En stock · $stock', couleur: AppColors.vertVif);
  }
}
