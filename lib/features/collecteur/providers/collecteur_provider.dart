import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final collecteurProvider =
    StateNotifierProvider<CollecteurNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return CollecteurNotifier(ref.read(apiClientProvider));
});

class CollecteurNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;

  CollecteurNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.mesParticipations);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = List<Map<String, dynamic>>.from(
          data['data'] as List,
        );
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
