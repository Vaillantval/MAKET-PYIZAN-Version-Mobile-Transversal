// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pos_produit_catalogue.freezed.dart';
part 'pos_produit_catalogue.g.dart';

@freezed
class PosLot with _$PosLot {
  const factory PosLot({
    required int    id,
    @JsonKey(name: 'code_barres')       String? codeBarres,
    @JsonKey(name: 'quantite_actuelle') @Default(0) double quantiteActuelle,
  }) = _PosLot;

  factory PosLot.fromJson(Map<String, dynamic> json) =>
      _$PosLotFromJson(json);
}

@freezed
class PosProduitCatalogue with _$PosProduitCatalogue {
  const factory PosProduitCatalogue({
    required int    id,
    required String nom,
    @JsonKey(name: 'prix_detail') required double prixDetail,
    @JsonKey(name: 'prix_gros')   double? prixGros,
    @Default('') String categorie,
    @Default([]) List<PosLot> lots,
  }) = _PosProduitCatalogue;

  factory PosProduitCatalogue.fromJson(Map<String, dynamic> json) =>
      _$PosProduitCatalogueFromJson(json);
}
