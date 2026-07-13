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
    @JsonKey(name: 'prix_gros', fromJson: jsonToDoubleNullable)   double? prixGros,
    @JsonKey(name: 'categorie', fromJson: _categorieNomFromJson) @Default('') String categorie,
    @JsonKey(name: 'unite_vente')       @Default('') String uniteVente,
    @JsonKey(name: 'stock_disponible', fromJson: jsonToDouble) @Default(0) double stockDisponible,
    @Default([]) List<PosLot> lots,
  }) = _PosProduitCatalogue;

  factory PosProduitCatalogue.fromJson(Map<String, dynamic> json) =>
      _$PosProduitCatalogueFromJson(json);
}
