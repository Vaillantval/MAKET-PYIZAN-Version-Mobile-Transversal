import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/produit.dart';

final mesProduitsProvider =
    StateNotifierProvider<MesProduitsNotifier, AsyncValue<List<Produit>>>((ref) {
  return MesProduitsNotifier(ref.read(apiClientProvider));
});

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

  Future<bool> creer(Map<String, dynamic> body, {String? imagePath}) async {
    try {
      if (imagePath != null) {
        final formData = await _buildFormData(body, imagePath);
        final res  = await _api.postMultipart(AppEndpoints.mesProduits, formData);
        final data = res.data as Map<String, dynamic>;
        if (data['success'] == true) { await charger(); return true; }
        return false;
      }
      final res  = await _api.post(AppEndpoints.mesProduits, data: body);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }

  Future<bool> modifier(
    String slug,
    Map<String, dynamic> body, {
    String? imagePath,
  }) async {
    try {
      if (imagePath != null) {
        final formData = await _buildFormData(body, imagePath);
        final res  = await _api.postMultipart(AppEndpoints.monProduit(slug), formData);
        final data = res.data as Map<String, dynamic>;
        if (data['success'] == true) { await charger(); return true; }
        return false;
      }
      final res  = await _api.patch(AppEndpoints.monProduit(slug), data: body);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }

  Future<bool> supprimer(String slug) async {
    try {
      await _api.delete(AppEndpoints.monProduit(slug));
      await charger();
      return true;
    } catch (_) { return false; }
  }

  Future<FormData> _buildFormData(
    Map<String, dynamic> body,
    String imagePath,
  ) async {
    final map = Map<String, dynamic>.from(body);
    map['image_principale'] = await MultipartFile.fromFile(
      imagePath, filename: 'image.jpg',
    );
    return FormData.fromMap(map);
  }
}
