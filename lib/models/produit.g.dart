// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProduitImpl _$$ProduitImplFromJson(Map<String, dynamic> json) =>
    _$ProduitImpl(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      slug: json['slug'] as String,
      variete: json['variete'] as String? ?? '',
      description: json['description'] as String? ?? '',
      prixUnitaire: json['prix_unitaire'] as String,
      prixOriginal: json['prix_original'] as String?,
      uniteVente: json['unite_vente'] as String,
      uniteVenteLabel: json['unite_vente_label'] as String,
      uniteVenteId: (json['unite_vente_id'] as num?)?.toInt(),
      prixSupplementaires: (json['prix_supplementaires'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      quantiteMinCommande:
          (json['quantite_min_commande'] as num?)?.toInt() ?? 1,
      stockReel: (json['stock_reel'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      imagePrincipale: json['image_principale'] as String?,
      categorie: json['categorie'] as Map<String, dynamic>?,
      producteur: json['producteur'] as Map<String, dynamic>?,
      origine: json['origine'] as String? ?? '',
      saison: json['saison'] as String? ?? '',
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$ProduitImplToJson(_$ProduitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'slug': instance.slug,
      'variete': instance.variete,
      'description': instance.description,
      'prix_unitaire': instance.prixUnitaire,
      'prix_original': instance.prixOriginal,
      'unite_vente': instance.uniteVente,
      'unite_vente_label': instance.uniteVenteLabel,
      'unite_vente_id': instance.uniteVenteId,
      'prix_supplementaires': instance.prixSupplementaires,
      'quantite_min_commande': instance.quantiteMinCommande,
      'stock_reel': instance.stockReel,
      'is_featured': instance.isFeatured,
      'image_principale': instance.imagePrincipale,
      'categorie': instance.categorie,
      'producteur': instance.producteur,
      'origine': instance.origine,
      'saison': instance.saison,
      'created_at': instance.createdAt,
    };
