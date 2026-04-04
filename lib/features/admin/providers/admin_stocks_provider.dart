import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminStocksProvider =
    StateNotifierProvider<AdminStocksNotifier,
        AsyncValue<Map<String, dynamic>>>((ref) {
  return AdminStocksNotifier(ref.read(apiClientProvider));
});

class AdminStocksNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ApiClient _api;

  AdminStocksNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final resLots    = await _api.get(AppEndpoints.adminStocks);
      final resAlertes = await _api.get(AppEndpoints.adminAlertes);

      final lots = (resLots.data['data'] as List?)
              ?.cast<Map<String, dynamic>>() ?? [];
      final alertes = (resAlertes.data['data'] as List?)
              ?.cast<Map<String, dynamic>>() ?? [];

      state = AsyncValue.data({
        'lots':    lots,
        'alertes': alertes,
      });
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }
}
