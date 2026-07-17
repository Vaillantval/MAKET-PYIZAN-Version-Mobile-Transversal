// ignore_for_file: invalid_annotation_target
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
    @JsonKey(name: 'prix_unitaire')     required String prixUnitaire,
    @JsonKey(name: 'prix_gros')         String? prixGros,
    @JsonKey(name: 'unite_vente')       required String uniteVente,
    @JsonKey(name: 'unite_vente_label') required String uniteVenteLabel,
    @JsonKey(name: 'quantite_min_commande') @Default(1) int quantiteMinCommande,
    @JsonKey(name: 'stock_reel')        @Default(0) int stockReel,
    @JsonKey(name: 'is_featured')       @Default(false) bool isFeatured,
    @JsonKey(name: 'image_principale')  String? imagePrincipale,
    Map<String, dynamic>? categorie,
    Map<String, dynamic>? producteur,
    @Default('') String origine,
    @Default('') String saison,
    @JsonKey(name: 'created_at')        String? createdAt,
  }) = _Produit;

  factory Produit.fromJson(Map<String, dynamic> json) =>
      _$ProduitFromJson(json);
}
