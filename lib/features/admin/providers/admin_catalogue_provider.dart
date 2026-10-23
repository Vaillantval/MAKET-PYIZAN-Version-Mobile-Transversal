import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/utils/api_error.dart';
import '../../../providers/auth_provider.dart';

final adminCatalogueProvider =
    StateNotifierProvider<AdminCatalogueNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  ref.watch(sessionUtilisateurProvider); // recharger au changement de compte
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

  String get statut => _statut;

  /// POST /api/admin/catalogue/<id>/moderer/ — action « approuver » ou
  /// « refuser » (motif obligatoire, transmis à l'entreprise par email et
  /// push). Renvoie null en cas de succès, sinon le message du serveur.
  Future<String?> moderer(int id, {required bool approuver, String motif = ''}) async {
    const parDefaut = 'La décision n\'a pas pu être enregistrée.';
    try {
      final res = await _api.post('${AppEndpoints.adminCatalogue}$id/moderer/', data: {
        'action': approuver ? 'approuver' : 'refuser',
        if (!approuver) 'motif': motif,
      });
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return null; }
      return extraireMessageErreur(data['error'], parDefaut);
    } catch (e) {
      return messageErreurApi(e, parDefaut);
    }
  }

  Future<bool> toggleActif(int id) => _basculer(id, 'is_active');

  Future<bool> toggleVedette(int id) => _basculer(id, 'is_featured');

  Future<bool> _basculer(int id, String champ) async {
    try {
      final res  = await _api.patch(
        '${AppEndpoints.adminCatalogue}$id/toggle/',
        data: {'champ': champ},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
