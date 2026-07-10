import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/pos_produit_catalogue.dart';
import '../providers/pos_catalogue_provider.dart';
import '../providers/pos_panier_provider.dart';
import '../providers/pos_session_provider.dart';

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
    final panier = ref.watch(posPanierProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Vente comptoir')),
      body: catalogueState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.vertVif)),
        error:   (e, _) => Center(child: Text('Erreur catalogue : $e')),
        data: (produits) {
          final notifier   = ref.read(posCatalogueProvider.notifier);
          final categories = ['Tous', ...notifier.categories];

          var visibles = _search.isEmpty ? produits : notifier.rechercher(_search);
          if (_categorieChoisie != 'Tous') {
            visibles = visibles.where((p) => p.categorie == _categorieChoisie).toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: categories.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _categorieChoisie == c,
                      selectedColor: AppColors.vertVif,
                      labelStyle: TextStyle(
                        color: _categorieChoisie == c ? Colors.white : AppColors.noir,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _categorieChoisie = c),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: visibles.isEmpty
                    ? const Center(
                        child: Text('Aucun produit trouvé.',
                            style: TextStyle(color: AppColors.grisTexte)),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: visibles.length,
                        itemBuilder: (_, i) => _ProduitTile(produit: visibles[i]),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: panier.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.vertFonce,
              icon: const Icon(Icons.shopping_cart),
              label: Text('${panier.length} — ${FormatUtils.htg(ref.read(posPanierProvider.notifier).total)}'),
              onPressed: () => _ouvrirPanier(context),
            ),
    );
  }

  void _ouvrirPanier(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _PanierSheet(),
    );
  }
}

// ── Tuile produit ─────────────────────────────────────────────────────

class _ProduitTile extends ConsumerWidget {
  final PosProduitCatalogue produit;
  const _ProduitTile({required this.produit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockTotal = produit.lots.fold<double>(0, (s, l) => s + l.quantiteActuelle);

    return GestureDetector(
      onTap: () => _ouvrirDialogueAjout(context, ref),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              produit.nom,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Stock : ${stockTotal.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 11, color: AppColors.grisTexte),
            ),
            HtgLabel(produit.prixDetail),
          ],
        ),
      ),
    );
  }

  void _ouvrirDialogueAjout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AjoutPanierDialog(produit: produit),
    );
  }
}

class HtgLabel extends StatelessWidget {
  final double montant;
  const HtgLabel(this.montant, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    FormatUtils.htg(montant),
    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.vertFonce),
  );
}

// ── Dialogue ajout produit ──────────────────────────────────────────────

class _AjoutPanierDialog extends ConsumerStatefulWidget {
  final PosProduitCatalogue produit;
  const _AjoutPanierDialog({required this.produit});

  @override
  ConsumerState<_AjoutPanierDialog> createState() => _AjoutPanierDialogState();
}

class _AjoutPanierDialogState extends ConsumerState<_AjoutPanierDialog> {
  int _quantite = 1;
  bool _prixGros = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.produit;
    final prixUnitaire = (_prixGros && p.prixGros != null) ? p.prixGros! : p.prixDetail;
    final lot = p.lots.isNotEmpty ? p.lots.first : null;

    return AlertDialog(
      title: Text(p.nom),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (p.prixGros != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Détail'),
                  selected: !_prixGros,
                  onSelected: (_) => setState(() => _prixGros = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Gros'),
                  selected: _prixGros,
                  onSelected: (_) => setState(() => _prixGros = true),
                ),
              ],
            ),
          const SizedBox(height: 12),
          HtgLabel(prixUnitaire),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 32),
                onPressed: _quantite > 1 ? () => setState(() => _quantite--) : null,
              ),
              SizedBox(
                width: 60,
                child: Text(
                  '$_quantite',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 32),
                onPressed: () => setState(() => _quantite++),
              ),
            ],
          ),
          const SizedBox(height: 8),
          HtgLabel(prixUnitaire * _quantite),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertFonce),
          onPressed: () {
            ref.read(posPanierProvider.notifier).ajouter(
              produitId: p.id,
              nomProduit: p.nom,
              lotId: lot?.id,
              quantite: _quantite.toDouble(),
              prixUnitaire: prixUnitaire,
            );
            Navigator.pop(context);
          },
          child: const Text('Ajouter au panier'),
        ),
      ],
    );
  }
}

// ── Panier (bottom sheet) ────────────────────────────────────────────

class _PanierSheet extends ConsumerWidget {
  const _PanierSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(posPanierProvider);
    final notifier = ref.read(posPanierProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Panier',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                TextButton(
                  onPressed: () {
                    notifier.vider();
                    Navigator.pop(context);
                  },
                  child: const Text('Vider', style: TextStyle(color: AppColors.rouge)),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Panier vide'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return ListTile(
                          title: Text(item.nomProduit),
                          subtitle: Text('${FormatUtils.htg(item.prixUnitaire)} x ${item.quantite.toStringAsFixed(0)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                onPressed: () => notifier.modifierQuantite(i, item.quantite - 1),
                              ),
                              Text(item.quantite.toStringAsFixed(0)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                onPressed: () => notifier.modifierQuantite(i, item.quantite + 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.rouge),
                                onPressed: () => notifier.retirer(i),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                HtgLabel(notifier.total),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: items.isEmpty ? null : () => _encaisser(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertFonce,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Encaisser', style: TextStyle(fontSize: 16)),
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
        builder: (_) => AlertDialog(
          title: const Text('Aucune session ouverte'),
          content: const Text(
            'Vous devez ouvrir une session de caisse avant de pouvoir encaisser une vente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
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
