// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LignePanierImpl _$$LignePanierImplFromJson(Map<String, dynamic> json) =>
    _$LignePanierImpl(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String,
      nom: json['nom'] as String,
      quantite: (json['quantite'] as num).toInt(),
      prixUnitaire: json['prixUnitaire'] as String,
      sousTotal: (json['sousTotal'] as num).toDouble(),
      uniteVente: json['uniteVente'] as String,
      producteurId: (json['producteurId'] as num).toInt(),
      producteurNom: json['producteurNom'] as String,
      image: json['image'] as String?,
      stockReel: (json['stockReel'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$LignePanierImplToJson(_$LignePanierImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'nom': instance.nom,
      'quantite': instance.quantite,
      'prixUnitaire': instance.prixUnitaire,
      'sousTotal': instance.sousTotal,
      'uniteVente': instance.uniteVente,
      'producteurId': instance.producteurId,
      'producteurNom': instance.producteurNom,
      'image': instance.image,
      'stockReel': instance.stockReel,
    };

_$PanierImpl _$$PanierImplFromJson(Map<String, dynamic> json) => _$PanierImpl(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => LignePanier.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      nbArticles: (json['nbArticles'] as num?)?.toInt() ?? 0,
      nbItems: (json['nbItems'] as num?)?.toInt() ?? 0,
      producteurs: (json['producteurs'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PanierImplToJson(_$PanierImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'nbArticles': instance.nbArticles,
      'nbItems': instance.nbItems,
      'producteurs': instance.producteurs,
    };
