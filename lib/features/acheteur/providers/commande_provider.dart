import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/commande.dart';

final commandesProvider =
    StateNotifierProvider<CommandeNotifier, AsyncValue<List<Commande>>>((ref) {
  return CommandeNotifier(ref.read(apiClientProvider));
});

class CommandeNotifier
    extends StateNotifier<AsyncValue<List<Commande>>> {
  final ApiClient _api;

  CommandeNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.mesCommandes);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => Commande.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Map<String, dynamic>?> passer({
    required String methodePaiement,
    required String modeLivraison,
    int?    adresseId,
    String  adresseTexte = '',
    String  ville        = '',
    String  departement  = '',
    String  notes        = '',
  }) async {
    try {
      final body = <String, dynamic>{
        'methode_paiement': methodePaiement,
        'mode_livraison':   modeLivraison,
        'notes':            notes,
      };
      if (adresseId != null) {
        body['adresse_livraison_id'] = adresseId;
      } else {
        body['adresse_livraison_text'] = adresseTexte;
        body['ville_livraison']        = ville;
        body['departement_livraison']  = departement;
      }

      final res  = await _api.post(AppEndpoints.commander, data: body);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await charger(); // Rafraîchir la liste
      }
      return data;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

// Détail d'une commande
final commandeDetailProvider =
    FutureProvider.family<Commande?, String>((ref, numero) async {
  final api = ref.read(apiClientProvider);
  try {
    final res  = await api.get(AppEndpoints.maCommande(numero));
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return Commande.fromJson(data['data'] as Map<String, dynamic>);
    }
  } catch (_) {}
  return null;
});
