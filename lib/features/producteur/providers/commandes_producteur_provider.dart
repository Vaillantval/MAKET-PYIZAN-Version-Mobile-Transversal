import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/commande.dart';

// Liste des commandes reçues
final commandesProducteurProvider = StateNotifierProvider
    .family<CommandesProducteurNotifier, AsyncValue<List<Commande>>, String>(
  (ref, statut) => CommandesProducteurNotifier(
    ref.read(apiClientProvider), statut,
  ),
);

class CommandesProducteurNotifier
    extends StateNotifier<AsyncValue<List<Commande>>> {
  final ApiClient _api;
  final String    _statut;

  CommandesProducteurNotifier(this._api, this._statut)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res = await _api.get(
        AppEndpoints.producteurCommandes,
        queryParameters: _statut.isNotEmpty
            ? {'statut': _statut} : null,
      );
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

  Future<Map<String, dynamic>?> changerStatut(
    String numero,
    String action, {
    String motif = '',
  }) async {
    try {
      final res = await _api.patch(
        AppEndpoints.producteurCommandeStatut(numero),
        data: {'action': action, if (motif.isNotEmpty) 'motif': motif},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) await charger();
      return data;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

// Détail d'une commande
final commandeProducteurDetailProvider =
    FutureProvider.family<Commande?, String>((ref, numero) async {
  final api = ref.read(apiClientProvider);
  try {
    final res  = await api.get(AppEndpoints.producteurCommande(numero));
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return Commande.fromJson(data['data'] as Map<String, dynamic>);
    }
  } catch (_) {}
  return null;
});
