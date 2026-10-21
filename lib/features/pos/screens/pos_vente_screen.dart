import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/api_error.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../../../models/pos_produit_catalogue.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/pos_catalogue_provider.dart';
import '../providers/pos_panier_provider.dart';
import '../providers/pos_session_provider.dart';
import '../providers/pos_terminal_status_provider.dart';

class PosVenteScreen extends ConsumerStatefulWidget {
  const PosVenteScreen({super.key});

  @override
  ConsumerState<PosVenteScreen> createState() => _PosVenteScreenState();
}

class _PosVenteScreenState extends ConsumerState<PosVenteScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _categorieChoisie = 'Tous';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogueState = ref.watch(posCatalogueProvider);
    final panier  = ref.watch(posPanierProvider);
    final session = ref.watch(posSessionProvider).valueOrNull;
    final ouverte = session != null && session.statut == 'ouverte';
    final terminal = ref.watch(posTerminalStatusProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EnTeteEcran(
              'Vente',
              // (« Aucune session ouverte » : déjà dans le bandeau cliquable)
              surtitre: ouverte
                  ? 'Session ouverte depuis ${FormatUtils.heure(session.ouverteLe)}'
                  : [terminal.nom, terminal.commune]
                      .where((v) => (v ?? '').isNotEmpty)
                      .join(' · '),
              actions: [
                BoutonRond(Icons.refresh_rounded,
                    tooltip: 'Actualiser le catalogue',
                    onTap: () => ref.read(posCatalogueProvider.notifier).charger()),
              ],
            ),
            Expanded(
              child: catalogueState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                // Message lisible (jamais l'exception brute) + nouvelle tentative
                error: (e, _) => EmptyState(
                  icone:       Icons.cloud_off_outlined,
                  titre:       'Catalogue indisponible',
                  description: messagePosErreur(e) ??
                      messageErreurApi(e, 'Vérifiez la connexion internet puis réessayez.'),
                  boutonLabel: 'Réessayer',
                  onBouton:    () {
                    ref.read(posTerminalStatusProvider.notifier).verifier();
                    ref.read(posCatalogueProvider.notifier).charger();
                  },
                ),
                data: (produits) => _catalogue(produits, panier.isNotEmpty),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: panier.isEmpty
          ? null
          : _BarrePanier(
              nbArticles: panier.length,
              total: ref.read(posPanierProvider.notifier).total,
              onTap: () => _ouvrirPanier(context),
            ),
    );
  }

  Widget _catalogue(List<PosProduitCatalogue> produits, bool panierNonVide) {
    final notifier   = ref.read(posCatalogueProvider.notifier);
    final categories = ['Tous', ...notifier.categories];

    var visibles = _search.isEmpty ? produits : notifier.rechercher(_search);
    if (_categorieChoisie != 'Tous') {
      visibles = visibles.where((p) => p.categorie == _categorieChoisie).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit…',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.noir),
              suffixIcon: _search.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(() {
                        _searchCtrl.clear();
                        _search = '';
                      }),
                    ),
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
                borderSide: BorderSide(color: AppColors.noir, width: 1.4),
              ),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        PastillesFiltre(
          options: [for (final c in categories) (c, c)],
          valeur: _categorieChoisie,
          onChanged: (c) => setState(() => _categorieChoisie = c),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: visibles.isEmpty
              ? const EmptyState(
                  icone: Icons.search_off_rounded,
                  titre: 'Aucun produit trouvé',
                )
              : GridView.builder(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, panierNonVide ? 24 : 32),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 232,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: visibles.length,
                  itemBuilder: (_, i) => _ProduitTile(produit: visibles[i]),
                ),
        ),
      ],
    );
  }

  void _ouvrirPanier(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _PanierSheet(),
    );
  }
}

// ── Barre du panier ───────────────────────────────────────────────────

class _BarrePanier extends StatelessWidget {
  final int nbArticles;
  final double total;
  final VoidCallback onTap;
  const _BarrePanier({required this.nbArticles, required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Material(
            color: AppColors.noir,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.blanc,
                      child: Text('$nbArticles',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, color: AppColors.noir)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Voir le panier',
                          style: TextStyle(
                              color: AppColors.blanc,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text(FormatUtils.htg(total),
                        style: const TextStyle(
                            color: AppColors.blanc,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.blanc),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

// ── Tuile produit ─────────────────────────────────────────────────────

class _ProduitTile extends ConsumerWidget {
  final PosProduitCatalogue produit;
  const _ProduitTile({required this.produit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // stock_disponible (scalaire) est la source de vérité du catalogue
    // POS ; 'lots' est renvoyé vide par ce contrat backend — sommer les
    // lots affichait donc toujours 0.
    final stock    = produit.stockDisponible;
    final epuise   = stock <= 0;
    final imageUrl = ImageUtils.imageUrl(produit.photoUrl);
    const vide = ColoredBox(
      color: AppColors.surface2,
      child: Center(child: Icon(Icons.image_outlined, size: 30, color: AppColors.grisLeger)),
    );

    return Material(
      color: AppColors.blanc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.grisBord),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _ouvrirAjout(context),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Shimmer.fromColors(
                                baseColor:      AppColors.surface2,
                                highlightColor: AppColors.grisClair,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (_, __, ___) => vide,
                            )
                          : vide,
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: epuise ? AppColors.noir : AppColors.blanc,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            epuise ? 'Épuisé' : 'Stock ${stock.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700,
                              color: epuise
                                  ? AppColors.blanc
                                  : stock <= 5 ? AppColors.rouge : AppColors.noir,
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 6, bottom: 6,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.noir,
                          child: Icon(Icons.add_rounded, size: 19, color: AppColors.blanc),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deux lignes : les variantes d'un même produit ne se
                    // distinguent souvent que par la fin du nom (« — 12 (sachet) »)
                    Text(
                      produit.nom,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13, height: 1.2),
                    ),
                    const SizedBox(height: 2),
                    HtgLabel(produit.prixDetail, fontSize: 14.5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _ouvrirAjout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AjoutPanierSheet(produit: produit),
    );
  }
}

class HtgLabel extends StatelessWidget {
  final double montant;
  final double fontSize;
  const HtgLabel(this.montant, {this.fontSize = 14, super.key});

  @override
  Widget build(BuildContext context) => Text(
    FormatUtils.htg(montant),
    style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize, color: AppColors.noir),
  );
}

// ── Ajout au panier (feuille) ─────────────────────────────────────────

class _AjoutPanierSheet extends ConsumerStatefulWidget {
  final PosProduitCatalogue produit;
  const _AjoutPanierSheet({required this.produit});

  @override
  ConsumerState<_AjoutPanierSheet> createState() => _AjoutPanierSheetState();
}

class _AjoutPanierSheetState extends ConsumerState<_AjoutPanierSheet> {
  int _quantite = 1;
  PosPrixUnite? _unite;

  @override
  void initState() {
    super.initState();
    final prix = widget.produit.prix;
    if (prix.isNotEmpty) {
      _unite = prix.firstWhere((u) => u.estUniteBase, orElse: () => prix.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.produit;
    // Prix suggéré du catalogue pour l'unité choisie — prixDetail reste
    // la source de vérité pour l'unité de base (au cas où elle
    // divergerait de son entrée dans prix[]).
    final uniteChoisieNonBase = _unite != null && !_unite!.estUniteBase;
    final prixUnitaire = uniteChoisieNonBase ? _unite!.prix : p.prixDetail;
    final lot = p.lots.isNotEmpty ? p.lots.first : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(p.nom,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Stock ${p.stockDisponible.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, color: AppColors.grisTexte)),
            // Le sélecteur ne s'affiche que si un admin a défini des
            // prix_supplementaires — la majorité des produits n'ont que
            // leur unité de base, l'écran reste identique pour eux.
            if (p.prix.length > 1) ...[
              const SizedBox(height: 16),
              const Text('Unité',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final u in p.prix)
                    _OptionUnite(
                      libelle: u.uniteNom,
                      prix: u.estUniteBase ? p.prixDetail : u.prix,
                      actif: _unite?.uniteId == u.uniteId,
                      onTap: () => setState(() => _unite = u),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
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
                        icon: const Icon(Icons.remove_rounded),
                        onPressed: _quantite > 1 ? () => setState(() => _quantite--) : null,
                      ),
                      SizedBox(
                        width: 34,
                        child: Text('$_quantite',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () => setState(() => _quantite++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Sous-total',
                          style: TextStyle(fontSize: 12, color: AppColors.grisTexte)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: HtgLabel(prixUnitaire * _quantite, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(posPanierProvider.notifier).ajouter(
                  produitId: p.id,
                  nomProduit: p.nom,
                  lotId: lot?.id,
                  uniteId: uniteChoisieNonBase ? _unite!.uniteId : null,
                  uniteCode: uniteChoisieNonBase ? _unite!.uniteCode : null,
                  uniteNom: uniteChoisieNonBase ? _unite!.uniteNom : null,
                  facteurConversion: uniteChoisieNonBase ? _unite!.facteurConversion : 1,
                  quantite: _quantite.toDouble(),
                  prixUnitaire: prixUnitaire,
                );
                Navigator.pop(context);
              },
              child: const Text('Ajouter au panier'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionUnite extends StatelessWidget {
  final String libelle;
  final double prix;
  final bool actif;
  final VoidCallback onTap;
  const _OptionUnite({
    required this.libelle, required this.prix, required this.actif, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: actif ? AppColors.noir : AppColors.blanc,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: actif ? BorderSide.none : const BorderSide(color: AppColors.grisBord),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(libelle,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: actif ? AppColors.blanc : AppColors.noir)),
                Text(FormatUtils.htg(prix),
                    style: TextStyle(
                        fontSize: 11.5,
                        color: actif ? const Color(0xB3FFFFFF) : AppColors.grisTexte)),
              ],
            ),
          ),
        ),
      );
}

// ── Panier (feuille) ──────────────────────────────────────────────────

class _PanierSheet extends ConsumerWidget {
  const _PanierSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(posPanierProvider);
    final notifier = ref.read(posPanierProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Panier · ${items.length} article(s)',
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                ),
                TextButton(
                  onPressed: () {
                    notifier.vider();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.rouge),
                  child: const Text('Vider'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(icone: Icons.shopping_bag_outlined, titre: 'Panier vide')
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.nomProduit,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14.5, fontWeight: FontWeight.w600)),
                                    Text(
                                      [
                                        if (item.uniteNom != null) item.uniteNom!,
                                        FormatUtils.htg(item.prixUnitaire),
                                      ].join(' · '),
                                      style: const TextStyle(
                                          fontSize: 12.5, color: AppColors.grisTexte),
                                    ),
                                    const SizedBox(height: 4),
                                    HtgLabel(item.prixUnitaire * item.quantite, fontSize: 14),
                                  ],
                                ),
                              ),
                              Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.grisBord),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(
                                          item.quantite <= 1
                                              ? Icons.delete_outline_rounded
                                              : Icons.remove_rounded,
                                          size: 18),
                                      onPressed: () => item.quantite <= 1
                                          ? notifier.retirer(i)
                                          : notifier.modifierQuantite(i, item.quantite - 1),
                                    ),
                                    Text(item.quantite.toStringAsFixed(0),
                                        style: const TextStyle(fontWeight: FontWeight.w700)),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.add_rounded, size: 18),
                                      onPressed: () =>
                                          notifier.modifierQuantite(i, item.quantite + 1),
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
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: Text('Total',
                      style: TextStyle(fontSize: 15, color: AppColors.grisTexte)),
                ),
                HtgLabel(notifier.total, fontSize: 22),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: items.isEmpty ? null : () => _encaisser(context, ref),
              child: const Text('Encaisser'),
            ),
          ],
        ),
      ),
    );
  }

  void _encaisser(BuildContext context, WidgetRef ref) {
    final sessionOuverte = ref.read(posSessionProvider.notifier).isOuverte;
    if (!sessionOuverte) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Aucune session ouverte'),
          content: const Text(
            'Ouvrez une session de caisse avant d\'encaisser une vente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Plus tard'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // fermer le panier
                context.go('/pos/session');
              },
              child: const Text('Ouvrir une session'),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.pop(context); // fermer le panier
    context.push('/pos/paiement');
  }
}
