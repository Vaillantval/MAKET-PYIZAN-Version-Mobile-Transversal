import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/commande.dart';
import '../../../providers/auth_provider.dart';

final commandesProvider =
    StateNotifierProvider<CommandeNotifier, AsyncValue<List<Commande>>>((ref) {
  ref.watch(sessionUtilisateurProvider); // recharger au changement de compte
  return CommandeNotifier(ref.read(apiClientProvider));
});

class CommandeNotifier
    extends StateNotifier<AsyncValue<List<Commande>>> {
  final ApiClient _api;

  CommandeNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.mesCommandes);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => Commande.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// POST /api/orders/commander/ — methode_paiement : moncash | natcash |
  /// hors_ligne | cash. [utiliserWallet] (moncash/natcash seulement) : le
  /// serveur débite le solde et ne redirige que pour le complément.
  /// [preuve] (hors_ligne) part avec la commande en multipart.
  Future<Map<String, dynamic>?> passer({
    required String methodePaiement,
    required String modeLivraison,
    int?    adresseId,
    String  adresseTexte = '',
    String  ville        = '',
    String  departement  = '',
    String  notes        = '',
    bool    utiliserWallet = false,
    XFile?  preuve,
  }) async {
    try {
      final body = <String, dynamic>{
        'methode_paiement': methodePaiement,
        'mode_livraison':   modeLivraison,
        'notes':            notes,
        if (utiliserWallet) 'utiliser_wallet': true,
      };
      if (adresseId != null) {
        body['adresse_livraison_id'] = adresseId;
      } else {
        body['adresse_livraison_text'] = adresseTexte;
        body['ville_livraison']        = ville;
        body['departement_livraison']  = departement;
      }

      final res = preuve != null
          ? await _api.postMultipart(
              AppEndpoints.commander,
              FormData.fromMap({
                ...body,
                'preuve_paiement': await MultipartFile.fromFile(
                    preuve.path, filename: preuve.name),
              }))
          : await _api.post(AppEndpoints.commander, data: body);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await charger(); // Rafraîchir la liste
      }
      return data;
    } catch (e) {
      return {
        'success': false,
        'error': messageErreurApi(e, 'Vérifiez votre connexion internet.'),
      };
    }
  }

  /// Confirme un paiement MonCash/NatCash au retour de la passerelle.
  /// Renvoie true (payé), false (non abouti) ou null (vérification
  /// impossible : réseau, passerelle).
  Future<bool?> verifierPaiementMobile(String commandeRef) async {
    try {
      final res = await _api.post(AppEndpoints.plopplopVerify,
          data: {'commande_ref': commandeRef});
      final data = res.data as Map<String, dynamic>;
      await charger();
      if (data['success'] != true) return null;
      return data['confirme'] == true;
    } catch (_) {
      return null;
    }
  }
}

// Détail d'une commande
final commandeDetailProvider =
    FutureProvider.family<Commande?, String>((ref, numero) async {
  ref.watch(sessionUtilisateurProvider); // recharger au changement de compte
  final api = ref.read(apiClientProvider);
  try {
    final res  = await api.get(AppEndpoints.maCommande(numero));
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return Commande.fromJson(data['data'] as Map<String, dynamic>);
    }
  } catch (_) {}
  return null;
});
