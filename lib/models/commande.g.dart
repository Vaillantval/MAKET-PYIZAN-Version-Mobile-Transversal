// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commande.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommandeImpl _$$CommandeImplFromJson(Map<String, dynamic> json) =>
    _$CommandeImpl(
      numeroCommande: json['numero_commande'] as String,
      producteur: json['producteur_nom'] as String? ?? '',
      total: json['total'] as String,
      statut: json['statut'] as String,
      statutLabel: json['statut_label'] as String,
      statutPaiement: json['statut_paiement'] as String,
      methodePaiement: json['methode_paiement'] as String? ?? '',
      modeLivraison: json['mode_livraison'] as String?,
      adresseLivraison: json['adresse_livraison'] as String?,
      notesAcheteur: json['notes_acheteur'] as String?,
      createdAt: json['created_at'] as String?,
      details: (json['details'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CommandeImplToJson(_$CommandeImpl instance) =>
    <String, dynamic>{
      'numero_commande': instance.numeroCommande,
      'producteur_nom': instance.producteur,
      'total': instance.total,
      'statut': instance.statut,
      'statut_label': instance.statutLabel,
      'statut_paiement': instance.statutPaiement,
      'methode_paiement': instance.methodePaiement,
      'mode_livraison': instance.modeLivraison,
      'adresse_livraison': instance.adresseLivraison,
      'notes_acheteur': instance.notesAcheteur,
      'created_at': instance.createdAt,
      'details': instance.details,
    };
