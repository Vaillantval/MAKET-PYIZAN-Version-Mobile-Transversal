import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/pos_item.dart';

/// Panier POS — état purement LOCAL (pas d'appel serveur par ligne,
/// contrairement au panier acheteur). La vente entière est soumise
/// en un seul appel à l'encaissement.
final posPanierProvider =
    StateNotifierProvider<PosPanierNotifier, List<PosItem>>((ref) {
  return PosPanierNotifier();
});

class PosPanierNotifier extends StateNotifier<List<PosItem>> {
  PosPanierNotifier() : super(const []);

  void ajouter({
    required int produitId,
    required String nomProduit,
    int? lotId,
    required double quantite,
    required double prixUnitaire,
  }) {
    final index = state.indexWhere(
      (i) => i.produitId == produitId && i.lotId == lotId,
    );
    if (index != -1) {
      modifierQuantite(index, state[index].quantite + quantite);
      return;
    }
    state = [
      ...state,
      PosItem(
        produitId: produitId,
        nomProduit: nomProduit,
        lotId: lotId,
        quantite: quantite,
        prixUnitaire: prixUnitaire,
        sousTotal: quantite * prixUnitaire,
      ),
    ];
  }

  void modifierQuantite(int index, double quantite) {
    if (index < 0 || index >= state.length) return;
    if (quantite <= 0) {
      retirer(index);
      return;
    }
    final item = state[index];
    final updated = [...state];
    updated[index] = item.copyWith(
      quantite: quantite,
      sousTotal: quantite * item.prixUnitaire,
    );
    state = updated;
  }

  void retirer(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
  }

  void vider() => state = const [];

  double get total => state.fold(0.0, (sum, i) => sum + i.sousTotal);

  int get nbArticles => state.length;
}
