// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_recharge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletRechargeImpl _$$WalletRechargeImplFromJson(Map<String, dynamic> json) =>
    _$WalletRechargeImpl(
      id: (json['id'] as num).toInt(),
      montant: jsonToDouble(json['montant']),
      methode: json['methode'] as String,
      methodeDisplay: json['methode_display'] as String? ?? '',
      statut: json['statut'] as String,
      statutDisplay: json['statut_display'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$WalletRechargeImplToJson(
        _$WalletRechargeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'montant': instance.montant,
      'methode': instance.methode,
      'methode_display': instance.methodeDisplay,
      'statut': instance.statut,
      'statut_display': instance.statutDisplay,
      'reference': instance.reference,
      'created_at': instance.createdAt,
    };
