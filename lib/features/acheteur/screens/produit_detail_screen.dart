import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/sons/sons_app.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../../../models/produit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/catalogue_provider.dart';
import '../providers/panier_provider.dart';
import '../widgets/produit_card.dart';
import '../widgets/choix_unite.dart';
import '../providers/favoris_provider.dart';
import '../../../shared/widgets/loading_widget.dart';

class ProduitDetailScreen extends ConsumerWidget {
  final String slug;
  const ProduitDetailScreen({required this.slug, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitAsync   = ref.watch(produitDetailProvider(slug));
    final catalogueAsync = ref.watch(catalogueProvider);

    return produitAsync.when(
      loading: () => const Scaffold(body: LoadingWidget(message: 'Chargement…')),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erreur : $e')),
      ),
      data: (produit) {
        if (produit == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icone: Icons.search_off_rounded,
              titre: 'Produit introuvable',
              boutonLabel: 'Retour à la boutique',
              onBouton: () => context.go('/acheteur/catalogue'),
            ),
          );
        }
        final similaires = catalogueAsync.produits
            .where((p) =>
                p.categorie?['slug'] == produit.categorie?['slug'] &&
                p.slug != produit.slug)
            .take(6)
            .toList();
        return _Fiche(produit: produit, similaires: similaires);
      },
    );
  }
}

class _Fiche extends ConsumerStatefulWidget {
  final Produit produit;
  final List<Produit> similaires;
  const _Fiche({required this.produit, required this.similaires});

  @override
  ConsumerState<_Fiche> createState() => _FicheState();
}

class _FicheState extends ConsumerState<_Fiche> {
  // Unités de vente du produit (base + prix_supplementaires), comme le
  // sélecteur d'unité de la fiche produit du site
  late final List<OptionUnite> _options = OptionUnite.pour(widget.produit);
  late OptionUnite _unite = _options.first;
  late int _quantite = _minimum.clamp(1, _maximum < 1 ? 1 : _maximum);
  bool _envoi = false;

  /// Le minimum de commande s'exprime dans l'unité de base.
  int get _minimum => identical(_unite, _options.first)
      ? widget.produit.quantiteMinCommande.clamp(1, 1 << 30)
      : 1;
  int get _maximum => _unite.maxPour(widget.produit.stockReel);

  void _choisirUnite(OptionUnite u) => setState(() {
        _unite = u;
        _quantite = _minimum.clamp(1, _maximum < 1 ? 1 : _maximum);
      });

  Future<void> _ajouter() async {
    setState(() => _envoi = true);
    final err = await ref
        .read(panierProvider.notifier)
        .ajouter(widget.produit, _quantite, unite: _unite);
    if (!mounted) return;
    setState(() => _envoi = false);
    // Succès : le panier s'ouvre (pas de message qui masquerait sa
    // barre de commande)
    if (err != null) {
      afficherMessage(context, err, succes: false);
    } else {
      SonsApp.jouer(SonApp.panier);
      context.go('/acheteur/panier');
    }
  }

  @override
  Widget build(BuildContext context) {
    final produit   = widget.produit;
    final remise    = produit.remisePourcent;
    final imageUrl  = ImageUtils.imageUrl(produit.imagePrincipale);
    final enStock   = _maximum > 0;
    final vendeur   = (produit.producteur?['nom'] ?? '').toString();
    final lieu      = [produit.producteur?['commune'], produit.origine]
        .where((v) => (v ?? '').toString().isNotEmpty)
        .toSet()
        .join(' · ');
    final minimum   = _minimum;

    return Scaffold(
      backgroundColor: AppColors.blanc,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.surface2,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: BoutonRond(Icons.arrow_back_rounded,
                  taille: 40,
                  tooltip: 'Retour',
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go('/acheteur/catalogue')),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: BoutonRond(
                    ref.watch(favorisProvider).contains(produit.id)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    taille: 40,
                    tooltip: 'Favori',
                    onTap: () => ref
                        .read(favorisProvider.notifier)
                        .basculer(produit.id)),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: BoutonRond(Icons.shopping_bag_outlined,
                    taille: 40,
                    tooltip: 'Panier',
                    onTap: () => context.go('/acheteur/panier')),
              ),
              const SizedBox(width: 8),
            ],
            // Panneau blanc arrondi qui chevauche le bas de l'image
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(26),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.blanc,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SizedBox(height: 26, width: double.infinity),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl.isNotEmpty
                  ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                  : const ColoredBox(
                      color: AppColors.surface2,
                      child: Center(
                        child: Icon(Icons.image_outlined,
                            size: 64, color: AppColors.grisLeger),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (produit.categorie != null)
                        PuceStatut(produit.categorie!['nom']?.toString() ?? '',
                            couleur: AppColors.grisTexte),
                      if (produit.isFeatured) ...[
                        const SizedBox(width: 6),
                        const PuceStatut('Sélection', couleur: AppColors.vertVif),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(produit.nom,
                            style: const TextStyle(
                                fontSize: 22,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Promotion : sur l'unité de base seulement
                          if (remise != null && identical(_unite, _options.first))
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(FormatUtils.htg(produit.prixOriginal!),
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.grisLeger,
                                        decoration: TextDecoration.lineThrough)),
                                const SizedBox(width: 6),
                                PuceStatut('-$remise%', couleur: AppColors.vertVif),
                              ],
                            ),
                          Text(FormatUtils.htg(_unite.prix),
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w700)),
                          Text(_unite.libelle,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.grisTexte)),
                        ],
                      ),
                    ],
                  ),
                  if (vendeur.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(vendeur.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11.5,
                            letterSpacing: 0.9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.grisLeger)),
                  ],
                  if (_options.length > 1) ...[
                    const SizedBox(height: 18),
                    const Text('Unité',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ChoixUnite(
                      options: _options,
                      valeur: _unite,
                      stockBase: produit.stockReel,
                      onChanged: _choisirUnite,
                    ),
                  ],
                  if (produit.description.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(produit.description,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.grisTexte)),
                  ],
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 8),
                  _Info(
                    enStock ? Icons.inventory_2_outlined : Icons.remove_shopping_cart_outlined,
                    produit.stockReel > 0
                        ? '${produit.stockReel} ${produit.uniteVenteLabel} disponible(s)'
                        : 'Rupture de stock',
                    couleur: produit.stockReel > 0 ? null : AppColors.rouge,
                  ),
                  if (lieu.isNotEmpty) _Info(Icons.place_outlined, lieu),
                  if (produit.saison.isNotEmpty)
                    _Info(Icons.wb_sunny_outlined, 'Saison : ${produit.saison}'),
                  if (minimum > 1)
                    _Info(Icons.shopping_basket_outlined,
                        'Minimum de commande : $minimum'),
                  if (widget.similaires.isNotEmpty) ...[
                    const TitreSection('Vous aimerez aussi'),
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.similaires.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final p = widget.similaires[i];
                          return SizedBox(
                            width: 160,
                            child: ProduitCard(
                              produit: p,
                              onTap: () =>
                                  context.go('/acheteur/produit/${p.slug}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Barre d'achat ───────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: AppColors.blanc,
            border: Border(top: BorderSide(color: AppColors.grisBord)),
          ),
          child: Row(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.grisBord),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Moins',
                      icon: const Icon(Icons.remove_rounded, size: 20),
                      onPressed: enStock && _quantite > minimum
                          ? () => setState(() => _quantite--)
                          : null,
                    ),
                    SizedBox(
                      width: 26,
                      child: Text('$_quantite',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                    IconButton(
                      tooltip: 'Plus',
                      icon: const Icon(Icons.add_rounded, size: 20),
                      onPressed: enStock && _quantite < _maximum
                          ? () => setState(() => _quantite++)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: enStock && !_envoi ? _ajouter : null,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 50)),
                  child: _envoi
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.blanc))
                      : Text(enStock ? 'Ajouter au panier' : 'Indisponible'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icone;
  final String texte;
  final Color? couleur;
  const _Info(this.icone, this.texte, {this.couleur});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icone, size: 19, color: couleur ?? AppColors.noir),
            const SizedBox(width: 12),
            Expanded(
              child: Text(texte,
                  style: TextStyle(
                      fontSize: 13.5, color: couleur ?? AppColors.noir)),
            ),
          ],
        ),
      );
}
