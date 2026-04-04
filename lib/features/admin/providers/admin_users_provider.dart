import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AdminUsersNotifier(ref.read(apiClientProvider));
});

class AdminUsersNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;
  String _search = '';
  String _role   = '';

  AdminUsersNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger({String? search, String? role}) async {
    _search = search ?? _search;
    _role   = role   ?? _role;
    state   = const AsyncValue.loading();
    try {
      final params = <String, dynamic>{};
      if (_search.isNotEmpty) params['search'] = _search;
      if (_role.isNotEmpty)   params['role']   = _role;

      final res  = await _api.get(AppEndpoints.adminUsers,
          queryParameters: params);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          List<Map<String, dynamic>>.from(data['data'] as List),
        );
      }
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<bool> toggle(int id) async {
    try {
      final res  = await _api.patch(
        '${AppEndpoints.adminUsers}$id/toggle/',
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
