// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_code_paiement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletCodePaiementImpl _$$WalletCodePaiementImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletCodePaiementImpl(
      code: json['code'] as String,
      expireDans: (json['expire_dans'] as num).toInt(),
      solde: jsonToDouble(json['solde']),
    );

Map<String, dynamic> _$$WalletCodePaiementImplToJson(
        _$WalletCodePaiementImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'expire_dans': instance.expireDans,
      'solde': instance.solde,
    };
