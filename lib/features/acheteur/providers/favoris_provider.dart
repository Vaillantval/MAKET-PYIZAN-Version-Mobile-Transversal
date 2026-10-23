import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_storage.dart';

/// Produits favoris (identifiants), gardés sur l'appareil — y compris pour
/// un visiteur. Pas encore synchronisés avec le compte côté serveur.
final favorisProvider = StateNotifierProvider<FavorisNotifier, Set<int>>(
    (ref) => FavorisNotifier(ref.read(localStorageProvider)));

class FavorisNotifier extends StateNotifier<Set<int>> {
  static const _cle = 'produits_favoris';
  final LocalStorage _storage;

  FavorisNotifier(this._storage)
      : super((_storage.getJsonList(_cle) ?? const [])
            .whereType<int>()
            .toSet());

  bool contient(int produitId) => state.contains(produitId);

  Future<void> basculer(int produitId) async {
    state = state.contains(produitId)
        ? ({...state}..remove(produitId))
        : {...state, produitId};
    await _storage.setJsonList(_cle, state.toList());
  }
}
