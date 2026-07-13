// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PosItemImpl _$$PosItemImplFromJson(Map<String, dynamic> json) =>
    _$PosItemImpl(
      produitId: (json['produit_id'] as num).toInt(),
      nomProduit: json['nom_produit'] as String? ?? '',
      lotId: (json['lot_id'] as num?)?.toInt(),
      quantite: jsonToDouble(json['quantite']),
      prixUnitaire: jsonToDouble(json['prix_unitaire']),
      sousTotal:
          json['sous_total'] == null ? 0 : jsonToDouble(json['sous_total']),
    );

Map<String, dynamic> _$$PosItemImplToJson(_$PosItemImpl instance) =>
    <String, dynamic>{
      'produit_id': instance.produitId,
      'nom_produit': instance.nomProduit,
      'lot_id': instance.lotId,
      'quantite': instance.quantite,
      'prix_unitaire': instance.prixUnitaire,
      'sous_total': instance.sousTotal,
    };
