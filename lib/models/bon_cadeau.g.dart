// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bon_cadeau.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BonCadeauImpl _$$BonCadeauImplFromJson(Map<String, dynamic> json) =>
    _$BonCadeauImpl(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      montant: jsonToDouble(json['montant']),
      statut: json['statut'] as String,
      statutDisplay: json['statut_display'] as String? ?? '',
      emailDestinataire: json['email_destinataire'] as String?,
      offertPar: json['offert_par'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$BonCadeauImplToJson(_$BonCadeauImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'montant': instance.montant,
      'statut': instance.statut,
      'statut_display': instance.statutDisplay,
      'email_destinataire': instance.emailDestinataire,
      'offert_par': instance.offertPar,
      'created_at': instance.createdAt,
    };
