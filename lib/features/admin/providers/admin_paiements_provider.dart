import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminPaiementsProvider =
    StateNotifierProvider<AdminPaiementsNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AdminPaiementsNotifier(ref.read(apiClientProvider));
});

class AdminPaiementsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;

  AdminPaiementsNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger({String statut = 'soumis'}) async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.adminPaiements,
          queryParameters: {'statut': statut});
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          List<Map<String, dynamic>>.from(data['data'] as List),
        );
      }
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<bool> traiter(
    int id, String action, {String note = ''}
  ) async {
    try {
      final res = await _api.patch(
        '${AppEndpoints.adminPaiements}$id/statut/',
        data: {'action': action, if (note.isNotEmpty) 'note': note},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
