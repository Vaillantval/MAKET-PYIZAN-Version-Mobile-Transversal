import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/adresse.dart';

final adressesProvider =
    StateNotifierProvider<AdresseNotifier, AsyncValue<List<Adresse>>>((ref) {
  return AdresseNotifier(ref.read(apiClientProvider));
});

class AdresseNotifier
    extends StateNotifier<AsyncValue<List<Adresse>>> {
  final ApiClient _api;

  AdresseNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.adresses);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => Adresse.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> creer(Map<String, dynamic> body) async {
    try {
      final res  = await _api.post(AppEndpoints.adresses, data: body);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await charger();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> setDefault(int id) async {
    try {
      await _api.patch(AppEndpoints.adresseDefault(id), data: {});
      await charger();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> supprimer(int id) async {
    try {
      await _api.delete(AppEndpoints.adresseDetail(id));
      await charger();
      return true;
    } catch (_) {
      return false;
    }
  }

  Adresse? get adresseDefaut {
    return state.whenOrNull(
      data: (list) {
        if (list.isEmpty) return null;
        final defaultAddr = list.where((a) => a.isDefault).firstOrNull;
        return defaultAddr ?? (list.isNotEmpty ? list.first : null);
      },
    );
  }
}
