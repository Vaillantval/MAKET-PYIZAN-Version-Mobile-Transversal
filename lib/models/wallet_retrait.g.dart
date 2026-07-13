// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_retrait.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletRetraitImpl _$$WalletRetraitImplFromJson(Map<String, dynamic> json) =>
    _$WalletRetraitImpl(
      id: (json['id'] as num).toInt(),
      montant: jsonToDouble(json['montant']),
      canal: json['canal'] as String,
      canalDisplay: json['canal_display'] as String? ?? '',
      numeroTelephone: json['numero_telephone'] as String,
      statut: json['statut'] as String,
      statutDisplay: json['statut_display'] as String? ?? '',
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$WalletRetraitImplToJson(_$WalletRetraitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'montant': instance.montant,
      'canal': instance.canal,
      'canal_display': instance.canalDisplay,
      'numero_telephone': instance.numeroTelephone,
      'statut': instance.statut,
      'statut_display': instance.statutDisplay,
      'created_at': instance.createdAt,
    };
