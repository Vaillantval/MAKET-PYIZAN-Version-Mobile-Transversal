import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/produit.dart';
import '../../../providers/entreprise_provider.dart';

final mesProduitsProvider =
    StateNotifierProvider<MesProduitsNotifier, AsyncValue<List<Produit>>>((ref) {
  ref.watch(entrepriseActiveIdProvider);
  return MesProduitsNotifier(ref.read(apiClientProvider));
});

/// Résultat d'une création / modification : le produit renvoyé par le
/// serveur (dont son `statut` de modération), ou le message d'erreur.
class ResultatProduit {
  final Map<String, dynamic>? produit;
  final String? erreur;
  const ResultatProduit({this.produit, this.erreur});

  bool get ok => erreur == null;
  String get statut => produit?['statut']?.toString() ?? '';
}

/// Catalogue de l'entreprise active (en-tête X-Entreprise ajouté par
/// l'ApiClient). Le serveur décide du statut (modération) : `statut` et
/// `is_active` ne sont jamais envoyés.
class MesProduitsNotifier
    extends StateNotifier<AsyncValue<List<Produit>>> {
  final ApiClient _api;

  MesProduitsNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.mesProduits);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => Produit.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Détail brut d'un produit de l'entreprise (préremplissage du formulaire).
  Future<Map<String, dynamic>?> detail(String slug) async {
    try {
      final res  = await _api.get(AppEndpoints.monProduit(slug));
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) return data['data'] as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  /// POST /api/products/mes-produits/ (multipart si une photo est jointe).
  Future<ResultatProduit> creer(Map<String, dynamic> body, {String? imagePath}) =>
      _envoyer(() async => imagePath != null
          ? _api.postMultipart(AppEndpoints.mesProduits, await _formData(body, imagePath))
          : _api.post(AppEndpoints.mesProduits, data: body));

  /// PATCH /api/products/mes-produits/<slug>/ — le serveur n'accepte que
  /// PATCH sur cette route, y compris pour changer la photo (multipart).
  Future<ResultatProduit> modifier(
    String slug,
    Map<String, dynamic> body, {
    String? imagePath,
  }) =>
      _envoyer(() async => imagePath != null
          ? _api.patch(AppEndpoints.monProduit(slug),
              data: await _formData(body, imagePath),
              options: Options(contentType: 'multipart/form-data'))
          : _api.patch(AppEndpoints.monProduit(slug), data: body));

  Future<bool> supprimer(String slug) async {
    try {
      await _api.delete(AppEndpoints.monProduit(slug));
      await charger();
      return true;
    } catch (_) { return false; }
  }

  Future<ResultatProduit> _envoyer(Future<Response> Function() requete) async {
    const parDefaut = "Le produit n'a pas pu être enregistré.";
    try {
      final res  = await requete();
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await charger();
        return ResultatProduit(produit: data['data'] as Map<String, dynamic>?);
      }
      return ResultatProduit(erreur: extraireMessageErreur(data['error'], parDefaut));
    } catch (e) {
      return ResultatProduit(erreur: messageErreurApi(e, parDefaut));
    }
  }

  Future<FormData> _formData(Map<String, dynamic> body, String imagePath) async {
    final map = Map<String, dynamic>.from(body);
    map['image_principale'] = await MultipartFile.fromFile(
      imagePath, filename: 'image.jpg',
    );
    return FormData.fromMap(map);
  }
}
