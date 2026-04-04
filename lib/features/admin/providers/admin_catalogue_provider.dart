import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminCatalogueProvider =
    StateNotifierProvider<AdminCatalogueNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AdminCatalogueNotifier(ref.read(apiClientProvider));
});

class AdminCatalogueNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;
  String _statut     = '';
  String _producteur = '';

  AdminCatalogueNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger({String? statut, String? producteur}) async {
    _statut     = statut     ?? _statut;
    _producteur = producteur ?? _producteur;
    state       = const AsyncValue.loading();
    try {
      final params = <String, dynamic>{};
      if (_statut.isNotEmpty)     params['statut']     = _statut;
      if (_producteur.isNotEmpty) params['producteur'] = _producteur;
      final res  = await _api.get(AppEndpoints.adminCatalogue,
          queryParameters: params);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          List<Map<String, dynamic>>.from(data['data'] as List),
        );
      }
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<bool> toggleActif(String slug) async {
    try {
      final res  = await _api.patch(
        '${AppEndpoints.adminCatalogue}$slug/toggle-actif/',
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }

  Future<bool> toggleVedette(String slug) async {
    try {
      final res  = await _api.patch(
        '${AppEndpoints.adminCatalogue}$slug/toggle-vedette/',
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
