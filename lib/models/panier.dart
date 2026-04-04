import 'package:freezed_annotation/freezed_annotation.dart';

part 'panier.freezed.dart';
part 'panier.g.dart';

@freezed
class LignePanier with _$LignePanier {
  const factory LignePanier({
    required int    id,
    required String slug,
    required String nom,
    required int    quantite,
    required String prixUnitaire,
    required double sousTotal,
    required String uniteVente,
    required int    producteurId,
    required String producteurNom,
    String? image,
    @Default(0) int stockReel,
  }) = _LignePanier;

  factory LignePanier.fromJson(Map<String, dynamic> json) =>
      _$LignePanierFromJson(json);
}

@freezed
class Panier with _$Panier {
  const factory Panier({
    @Default([]) List<LignePanier> items,
    @Default(0.0) double total,
    @Default(0) int nbArticles,
    @Default(0) int nbItems,
    @Default([]) List<Map<String, dynamic>> producteurs,
  }) = _Panier;

  factory Panier.fromJson(Map<String, dynamic> json) =>
      _$PanierFromJson(json);
}
