// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pos_item.freezed.dart';
part 'pos_item.g.dart';

@freezed
class PosItem with _$PosItem {
  const factory PosItem({
    @JsonKey(name: 'produit_id')    required int    produitId,
    @JsonKey(name: 'nom_produit')   @Default('') String nomProduit,
    @JsonKey(name: 'lot_id')        int? lotId,
    required double quantite,
    @JsonKey(name: 'prix_unitaire') required double prixUnitaire,
    @JsonKey(name: 'sous_total')    @Default(0) double sousTotal,
  }) = _PosItem;

  factory PosItem.fromJson(Map<String, dynamic> json) =>
      _$PosItemFromJson(json);
}

/// Payload minimal attendu par le backend pour une ligne de vente
/// (exclut les champs d'affichage local : nom_produit, sous_total).
extension PosItemPayload on PosItem {
  Map<String, dynamic> toPayload() => {
    'produit_id': produitId,
    if (lotId != null) 'lot_id': lotId,
    'quantite': quantite,
    'prix_unitaire': prixUnitaire,
  };
}
