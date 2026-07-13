// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_produit_catalogue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PosLotImpl _$$PosLotImplFromJson(Map<String, dynamic> json) => _$PosLotImpl(
      id: (json['id'] as num).toInt(),
      codeBarres: json['code_barres'] as String?,
      quantiteActuelle: json['quantite_actuelle'] == null
          ? 0
          : jsonToDouble(json['quantite_actuelle']),
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
      prixDetail: jsonToDouble(json['prix_unitaire']),
      prixGros: jsonToDoubleNullable(json['prix_gros']),
      categorie: json['categorie'] == null
          ? ''
          : _categorieNomFromJson(json['categorie']),
      uniteVente: json['unite_vente'] as String? ?? '',
      stockDisponible: json['stock_disponible'] == null
          ? 0
          : jsonToDouble(json['stock_disponible']),
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
      'prix_unitaire': instance.prixDetail,
      'prix_gros': instance.prixGros,
      'categorie': instance.categorie,
      'unite_vente': instance.uniteVente,
      'stock_disponible': instance.stockDisponible,
      'lots': instance.lots,
    };
