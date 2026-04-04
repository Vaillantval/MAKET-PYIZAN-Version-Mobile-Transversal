import 'package:freezed_annotation/freezed_annotation.dart';

part 'produit.freezed.dart';
part 'produit.g.dart';

@freezed
class Produit with _$Produit {
  const factory Produit({
    required int    id,
    required String nom,
    required String slug,
    @Default('') String variete,
    @Default('') String description,
    required String prixUnitaire,
    String? prixGros,
    required String uniteVente,
    required String uniteVenteLabel,
    @Default(1) int quantiteMinCommande,
    @Default(0) int stockReel,
    @Default(false) bool isFeatured,
    String? imagePrincipale,
    Map<String, dynamic>? categorie,
    Map<String, dynamic>? producteur,
    @Default('') String origine,
    @Default('') String saison,
    String? createdAt,
  }) = _Produit;

  factory Produit.fromJson(Map<String, dynamic> json) =>
      _$ProduitFromJson(json);
}
