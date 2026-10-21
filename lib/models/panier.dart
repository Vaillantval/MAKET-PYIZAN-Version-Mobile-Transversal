// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'panier.freezed.dart';
part 'panier.g.dart';

@freezed
class LignePanier with _$LignePanier {
  const factory LignePanier({
    required int    id,
    required String slug,
    required String nom,
    required int    quantite,
    @JsonKey(name: 'prix_unitaire')  required String prixUnitaire,
    @JsonKey(name: 'sous_total', fromJson: jsonToDouble) required double sousTotal,
    @JsonKey(name: 'unite_vente')    required String uniteVente,
    @JsonKey(name: 'unite_vente_id')    int? uniteVenteId,
    @JsonKey(name: 'unite_vente_label') @Default('') String uniteVenteLabel,
    @JsonKey(name: 'producteur_id')  required int producteurId,
    @JsonKey(name: 'producteur_nom') required String producteurNom,
    String? image,
    @JsonKey(name: 'stock_reel')     @Default(0) int stockReel,
    // Unités de base par unité choisie : contrôle du stock du panier local
    // (visiteur) ; absent des réponses du backend → 1
    @JsonKey(name: 'facteur_conversion', fromJson: jsonToDouble) @Default(1.0) double facteur,
  }) = _LignePanier;

  factory LignePanier.fromJson(Map<String, dynamic> json) =>
      _$LignePanierFromJson(json);
}

@freezed
class Panier with _$Panier {
  const factory Panier({
    @Default([]) List<LignePanier> items,
    @JsonKey(fromJson: jsonToDouble) @Default(0.0) double total,
    @JsonKey(name: 'nb_articles') @Default(0) int nbArticles,
    @JsonKey(name: 'nb_items')    @Default(0) int nbItems,
    @Default([]) List<Map<String, dynamic>> producteurs,
  }) = _Panier;

  factory Panier.fromJson(Map<String, dynamic> json) =>
      _$PanierFromJson(json);
}
