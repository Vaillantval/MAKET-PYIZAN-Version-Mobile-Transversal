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
      prixUnitaire: json['prix_unitaire'] as String,
      sousTotal: jsonToDouble(json['sous_total']),
      uniteVente: json['unite_vente'] as String,
      producteurId: (json['producteur_id'] as num).toInt(),
      producteurNom: json['producteur_nom'] as String,
      image: json['image'] as String?,
      stockReel: (json['stock_reel'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$LignePanierImplToJson(_$LignePanierImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'nom': instance.nom,
      'quantite': instance.quantite,
      'prix_unitaire': instance.prixUnitaire,
      'sous_total': instance.sousTotal,
      'unite_vente': instance.uniteVente,
      'producteur_id': instance.producteurId,
      'producteur_nom': instance.producteurNom,
      'image': instance.image,
      'stock_reel': instance.stockReel,
    };

_$PanierImpl _$$PanierImplFromJson(Map<String, dynamic> json) => _$PanierImpl(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => LignePanier.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: json['total'] == null ? 0.0 : jsonToDouble(json['total']),
      nbArticles: (json['nb_articles'] as num?)?.toInt() ?? 0,
      nbItems: (json['nb_items'] as num?)?.toInt() ?? 0,
      producteurs: (json['producteurs'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PanierImplToJson(_$PanierImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'nb_articles': instance.nbArticles,
      'nb_items': instance.nbItems,
      'producteurs': instance.producteurs,
    };
