import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/unite_mesure.dart';

/// GET /api/products/unites-mesure/ (public, pas d'auth requise) —
/// utilisées pour peupler le sélecteur d'unité du formulaire produit.
/// Change rarement : un FutureProvider suffit, pas besoin de recharger
/// à chaque ouverture du formulaire.
final unitesMesureProvider = FutureProvider<List<UniteMesure>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get(AppEndpoints.unitesMesure);
  final data = res.data as Map<String, dynamic>;
  if (data['success'] != true) return [];
  return (data['data'] as List)
      .map((e) => UniteMesure.fromJson(e as Map<String, dynamic>))
      .where((u) => u.isActive)
      .toList()
    ..sort((a, b) => a.ordre.compareTo(b.ordre));
});
