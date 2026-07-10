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
      quantite: (json['quantite'] as num).toDouble(),
      prixUnitaire: (json['prix_unitaire'] as num).toDouble(),
      sousTotal: (json['sous_total'] as num?)?.toDouble() ?? 0,
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
