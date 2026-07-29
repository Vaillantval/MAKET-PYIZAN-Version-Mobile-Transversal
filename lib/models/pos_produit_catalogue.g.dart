// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_produit_catalogue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PosPrixUniteImpl _$$PosPrixUniteImplFromJson(Map<String, dynamic> json) =>
    _$PosPrixUniteImpl(
      uniteId: (json['unite_id'] as num).toInt(),
      uniteCode: json['unite_code'] as String,
      uniteNom: json['unite_nom'] as String,
      prix: jsonToDouble(json['prix']),
      facteurConversion: json['facteur_conversion'] == null
          ? 1
          : jsonToDouble(json['facteur_conversion']),
      estUniteBase: json['est_unite_base'] as bool? ?? false,
    );

Map<String, dynamic> _$$PosPrixUniteImplToJson(_$PosPrixUniteImpl instance) =>
    <String, dynamic>{
      'unite_id': instance.uniteId,
      'unite_code': instance.uniteCode,
      'unite_nom': instance.uniteNom,
      'prix': instance.prix,
      'facteur_conversion': instance.facteurConversion,
      'est_unite_base': instance.estUniteBase,
    };

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
      categorie: json['categorie'] == null
          ? ''
          : _categorieNomFromJson(json['categorie']),
      uniteVente: json['unite_vente'] == null
          ? ''
          : _uniteVenteCodeFromJson(json['unite_vente']),
      stockDisponible: json['stock_disponible'] == null
          ? 0
          : jsonToDouble(json['stock_disponible']),
      photoUrl: json['photo_url'] as String?,
      lots: (json['lots'] as List<dynamic>?)
              ?.map((e) => PosLot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      prix: (json['prix'] as List<dynamic>?)
              ?.map((e) => PosPrixUnite.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PosProduitCatalogueImplToJson(
        _$PosProduitCatalogueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prix_unitaire': instance.prixDetail,
      'categorie': instance.categorie,
      'unite_vente': instance.uniteVente,
      'stock_disponible': instance.stockDisponible,
      'photo_url': instance.photoUrl,
      'lots': instance.lots,
      'prix': instance.prix,
    };
