import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminProducteursProvider =
    StateNotifierProvider<AdminProducteursNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AdminProducteursNotifier(ref.read(apiClientProvider));
});

class AdminProducteursNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;
  String _statut = '';

  AdminProducteursNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger({String? statut}) async {
    _statut = statut ?? _statut;
    state   = const AsyncValue.loading();
    try {
      final params = <String, dynamic>{};
      if (_statut.isNotEmpty) params['statut'] = _statut;
      final res  = await _api.get(AppEndpoints.adminProducteurs,
          queryParameters: params);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          List<Map<String, dynamic>>.from(data['data'] as List),
        );
      }
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<bool> changerStatut(
    int id, String statut, {String note = ''}
  ) async {
    try {
      final res = await _api.patch(
        '${AppEndpoints.adminProducteurs}$id/statut/',
        data: {'statut': statut, if (note.isNotEmpty) 'note': note},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
