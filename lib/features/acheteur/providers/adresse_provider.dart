import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/adresse.dart';
import '../../../providers/auth_provider.dart';

final adressesProvider =
    StateNotifierProvider<AdresseNotifier, AsyncValue<List<Adresse>>>((ref) {
  ref.watch(sessionUtilisateurProvider); // recharger au changement de compte
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

  /// POST /api/auth/adresses/ — champs requis côté serveur : libelle,
  /// nom_complet, rue, commune, departement (slug). Renvoie null en cas de
  /// succès, sinon le message d'erreur du serveur.
  Future<String?> creer(Map<String, dynamic> body) async {
    const parDefaut = "L'adresse n'a pas pu être créée.";
    try {
      final res  = await _api.post(AppEndpoints.adresses, data: body);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await charger();
        return null;
      }
      return extraireMessageErreur(data['error'], parDefaut);
    } catch (e) {
      return messageErreurApi(e, parDefaut);
    }
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
