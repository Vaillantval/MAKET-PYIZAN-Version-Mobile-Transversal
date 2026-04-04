import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/offline_manager.dart';
import '../../../core/offline/sync_queue.dart';
import '../../../models/panier.dart';

final panierProvider =
    StateNotifierProvider<PanierNotifier, AsyncValue<Panier>>((ref) {
  return PanierNotifier(
    ref.read(apiClientProvider),
    ref.read(offlineManagerProvider),
  );
});

class PanierNotifier extends StateNotifier<AsyncValue<Panier>> {
  final ApiClient      _api;
  final OfflineManager _offline;

  PanierNotifier(this._api, this._offline)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.panier);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          Panier.fromJson(data['data'] as Map<String, dynamic>)
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> ajouter(String slug, int quantite) async {
    final result = await _offline.execute(SyncAction(
      type:     SyncActionType.panierAjouter,
      endpoint: AppEndpoints.panierAjouter,
      method:   'POST',
      payload:  {'slug': slug, 'quantite': quantite},
    ));

    if (result.isSuccess && !result.isQueued) {
      final data = result.data as Map<String, dynamic>?;
      if (data?['success'] == true) {
        state = AsyncValue.data(
          Panier.fromJson(data!['data'] as Map<String, dynamic>)
        );
        return null; // succès
      }
      return data?['error']?.toString() ?? 'Erreur';
    } else if (result.isQueued) {
      return null; // mis en queue offline
    }
    return result.error;
  }

  Future<void> modifier(String slug, int quantite) async {
    final result = await _offline.execute(SyncAction(
      type:     SyncActionType.panierModifier,
      endpoint: AppEndpoints.panierModifier(slug),
      method:   'PATCH',
      payload:  {'quantite': quantite},
    ));
    if (result.isSuccess && !result.isQueued) {
      final data = result.data as Map<String, dynamic>?;
      if (data?['success'] == true) {
        state = AsyncValue.data(
          Panier.fromJson(data!['data'] as Map<String, dynamic>)
        );
      }
    }
  }

  Future<void> retirer(String slug) async {
    await _offline.execute(SyncAction(
      type:     SyncActionType.panierRetirer,
      endpoint: AppEndpoints.panierRetirer(slug),
      method:   'DELETE',
      payload:  {},
    ));
    await charger();
  }

  Future<void> vider() async {
    await _offline.execute(SyncAction(
      type:     SyncActionType.panierVider,
      endpoint: AppEndpoints.panierVider,
      method:   'DELETE',
      payload:  {},
    ));
    await charger();
  }

  int get nbArticles {
    return state.whenOrNull(data: (p) => p.nbArticles) ?? 0;
  }
}
