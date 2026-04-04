// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commande.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommandeImpl _$$CommandeImplFromJson(Map<String, dynamic> json) =>
    _$CommandeImpl(
      numeroCommande: json['numeroCommande'] as String,
      producteur: json['producteur'] as String,
      total: json['total'] as String,
      statut: json['statut'] as String,
      statutLabel: json['statutLabel'] as String,
      statutPaiement: json['statutPaiement'] as String,
      methodePaiement: json['methodePaiement'] as String? ?? '',
      modeLivraison: json['modeLivraison'] as String?,
      adresseLivraison: json['adresseLivraison'] as String?,
      notesAcheteur: json['notesAcheteur'] as String?,
      createdAt: json['createdAt'] as String?,
      details: (json['details'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CommandeImplToJson(_$CommandeImpl instance) =>
    <String, dynamic>{
      'numeroCommande': instance.numeroCommande,
      'producteur': instance.producteur,
      'total': instance.total,
      'statut': instance.statut,
      'statutLabel': instance.statutLabel,
      'statutPaiement': instance.statutPaiement,
      'methodePaiement': instance.methodePaiement,
      'modeLivraison': instance.modeLivraison,
      'adresseLivraison': instance.adresseLivraison,
      'notesAcheteur': instance.notesAcheteur,
      'createdAt': instance.createdAt,
      'details': instance.details,
    };
