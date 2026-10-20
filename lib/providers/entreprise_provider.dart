import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/secure_storage.dart';
import '../models/entreprise.dart';
import 'auth_provider.dart';

/// Id de l'entreprise active (espace entreprise), null dans l'espace
/// acheteur. Persisté pour que l'ApiClient puisse joindre l'en-tête
/// X-Entreprise et pour rouvrir l'app directement dans l'espace entreprise.
///
/// Les providers de l'espace entreprise (dashboard, produits, commandes
/// reçues, collectes, wallet) le surveillent : changer d'entreprise les
/// recharge automatiquement.
final entrepriseActiveIdProvider =
    StateNotifierProvider<EntrepriseActiveNotifier, int?>((ref) {
  return EntrepriseActiveNotifier(ref.read(secureStorageProvider));
});

/// Appartenance correspondant à l'entreprise active (null si aucune, ou si
/// le compte n'en est plus membre).
final entrepriseActiveProvider = Provider<EntrepriseMembre?>((ref) {
  final id = ref.watch(entrepriseActiveIdProvider);
  if (id == null) return null;
  final entreprises = ref.watch(authProvider).user?.entreprises ?? const [];
  for (final e in entreprises) {
    if (e.id == id) return e;
  }
  return null;
});

class EntrepriseActiveNotifier extends StateNotifier<int?> {
  final SecureStorage _storage;

  EntrepriseActiveNotifier(this._storage)
      : super(_storage.getEntrepriseActiveId());

  /// Entrer dans l'espace de [entreprise].
  Future<void> activer(EntrepriseMembre entreprise) async {
    await _storage.saveEntrepriseActive(entreprise.id, entreprise.role);
    state = entreprise.id;
  }

  /// Revenir à l'espace acheteur.
  Future<void> quitter() async {
    await _storage.clearEntrepriseActive();
    state = null;
  }

  /// Après un rafraîchissement du profil : garder le rôle à jour, ou
  /// sortir de l'entreprise si le compte n'en est plus membre.
  Future<void> synchroniser(List<EntrepriseMembre> entreprises) async {
    final id = state;
    if (id == null) return;
    for (final e in entreprises) {
      if (e.id == id) {
        await _storage.saveEntrepriseActive(e.id, e.role);
        return;
      }
    }
    await quitter();
  }
}
