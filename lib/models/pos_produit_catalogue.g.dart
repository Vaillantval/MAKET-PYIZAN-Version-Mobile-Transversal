// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_produit_catalogue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PosLotImpl _$$PosLotImplFromJson(Map<String, dynamic> json) => _$PosLotImpl(
      id: (json['id'] as num).toInt(),
      codeBarres: json['code_barres'] as String?,
      quantiteActuelle: (json['quantite_actuelle'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$PosLotImplToJson(_$PosLotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code_barres': instance.codeBarres,
      'quantite_actuelle': instance.quantiteActuelle,
    };

_$PosProduitCatalogueImpl _$$PosProduitCatalogueImplFromJson(
        Map<String, dynamic> json) =>
    _$PosProduitCatalogueImpl(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      prixDetail: (json['prix_detail'] as num).toDouble(),
      prixGros: (json['prix_gros'] as num?)?.toDouble(),
      categorie: json['categorie'] as String? ?? '',
      lots: (json['lots'] as List<dynamic>?)
              ?.map((e) => PosLot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PosProduitCatalogueImplToJson(
        _$PosProduitCatalogueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prix_detail': instance.prixDetail,
      'prix_gros': instance.prixGros,
      'categorie': instance.categorie,
      'lots': instance.lots,
    };
