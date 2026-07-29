// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'pos_produit_catalogue.freezed.dart';
part 'pos_produit_catalogue.g.dart';

/// La 'categorie' du catalogue POS est un objet {id, nom} — on n'en
/// garde que le nom pour rester compatible avec le champ String
/// existant (regroupement/filtrage par catégorie dans pos_vente_screen).
String _categorieNomFromJson(dynamic v) {
  if (v is Map) return (v['nom'] ?? '').toString();
  return v?.toString() ?? '';
}

/// unite_vente passe d'une chaîne ("kg") à un objet {id, code, nom} sur
/// ce contrat — on ne garde que le code, en tolérant les deux formats
/// pendant la bascule backend.
String _uniteVenteCodeFromJson(dynamic v) {
  if (v is Map) return (v['code'] ?? '').toString();
  return v?.toString() ?? '';
}

/// Une entrée du tableau prix[] du catalogue POS : le prix suggéré (le
/// catalogue) pour vendre ce produit dans une unité donnée — l'unité de
/// base (est_unite_base: true) ou une unité de prix_supplementaires
/// définie côté admin (ex: "Sac 50 kg"). L'opérateur choisit l'unité au
/// moment de la vente et reste libre d'ajuster le prix suggéré.
@freezed
class PosPrixUnite with _$PosPrixUnite {
  const factory PosPrixUnite({
    @JsonKey(name: 'unite_id')   required int    uniteId,
    @JsonKey(name: 'unite_code') required String uniteCode,
    @JsonKey(name: 'unite_nom')  required String uniteNom,
    @JsonKey(fromJson: jsonToDouble) required double prix,
    @JsonKey(name: 'facteur_conversion', fromJson: jsonToDouble) @Default(1) double facteurConversion,
    @JsonKey(name: 'est_unite_base') @Default(false) bool estUniteBase,
  }) = _PosPrixUnite;

  factory PosPrixUnite.fromJson(Map<String, dynamic> json) =>
      _$PosPrixUniteFromJson(json);
}

@freezed
class PosLot with _$PosLot {
  const factory PosLot({
    required int    id,
    @JsonKey(name: 'code_barres')       String? codeBarres,
    @JsonKey(name: 'quantite_actuelle', fromJson: jsonToDouble) @Default(0) double quantiteActuelle,
  }) = _PosLot;

  factory PosLot.fromJson(Map<String, dynamic> json) =>
      _$PosLotFromJson(json);
}

@freezed
class PosProduitCatalogue with _$PosProduitCatalogue {
  const factory PosProduitCatalogue({
    required int    id,
    required String nom,
    @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble) required double prixDetail,
    @JsonKey(name: 'categorie', fromJson: _categorieNomFromJson) @Default('') String categorie,
    @JsonKey(name: 'unite_vente', fromJson: _uniteVenteCodeFromJson) @Default('') String uniteVente,
    @JsonKey(name: 'stock_disponible', fromJson: jsonToDouble) @Default(0) double stockDisponible,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @Default([]) List<PosLot> lots,
    @Default([]) List<PosPrixUnite> prix,
  }) = _PosProduitCatalogue;

  factory PosProduitCatalogue.fromJson(Map<String, dynamic> json) =>
      _$PosProduitCatalogueFromJson(json);
}
