import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminCollectesProvider =
    StateNotifierProvider<AdminCollectesNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AdminCollectesNotifier(ref.read(apiClientProvider));
});

class AdminCollectesNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;
  String _statut = '';

  AdminCollectesNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger({String? statut}) async {
    _statut = statut ?? _statut;
    state   = const AsyncValue.loading();
    try {
      final params = <String, dynamic>{};
      if (_statut.isNotEmpty) params['statut'] = _statut;
      final res  = await _api.get(AppEndpoints.adminCollectes,
          queryParameters: params);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          List<Map<String, dynamic>>.from(data['data'] as List),
        );
      }
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<bool> changerStatut(int id, String action) async {
    try {
      final res  = await _api.patch(
        '${AppEndpoints.adminCollectes}$id/$action/',
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
