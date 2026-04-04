import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminCommandesProvider =
    StateNotifierProvider<AdminCommandesNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AdminCommandesNotifier(ref.read(apiClientProvider));
});

class AdminCommandesNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;
  String _statut = '';
  String _search = '';

  AdminCommandesNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger({String? statut, String? search}) async {
    _statut = statut ?? _statut;
    _search = search ?? _search;
    state   = const AsyncValue.loading();
    try {
      final params = <String, dynamic>{};
      if (_statut.isNotEmpty) params['statut'] = _statut;
      if (_search.isNotEmpty) params['search'] = _search;
      final res  = await _api.get(AppEndpoints.adminCommandes,
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
    String numero, String statut, {String commentaire = ''}
  ) async {
    try {
      final res = await _api.patch(
        '${AppEndpoints.adminCommandes}$numero/statut/',
        data: {
          'statut': statut,
          if (commentaire.isNotEmpty) 'commentaire': commentaire,
        },
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
