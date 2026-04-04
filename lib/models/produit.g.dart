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
      prixUnitaire: json['prixUnitaire'] as String,
      prixGros: json['prixGros'] as String?,
      uniteVente: json['uniteVente'] as String,
      uniteVenteLabel: json['uniteVenteLabel'] as String,
      quantiteMinCommande: (json['quantiteMinCommande'] as num?)?.toInt() ?? 1,
      stockReel: (json['stockReel'] as num?)?.toInt() ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      imagePrincipale: json['imagePrincipale'] as String?,
      categorie: json['categorie'] as Map<String, dynamic>?,
      producteur: json['producteur'] as Map<String, dynamic>?,
      origine: json['origine'] as String? ?? '',
      saison: json['saison'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$$ProduitImplToJson(_$ProduitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'slug': instance.slug,
      'variete': instance.variete,
      'description': instance.description,
      'prixUnitaire': instance.prixUnitaire,
      'prixGros': instance.prixGros,
      'uniteVente': instance.uniteVente,
      'uniteVenteLabel': instance.uniteVenteLabel,
      'quantiteMinCommande': instance.quantiteMinCommande,
      'stockReel': instance.stockReel,
      'isFeatured': instance.isFeatured,
      'imagePrincipale': instance.imagePrincipale,
      'categorie': instance.categorie,
      'producteur': instance.producteur,
      'origine': instance.origine,
      'saison': instance.saison,
      'createdAt': instance.createdAt,
    };
