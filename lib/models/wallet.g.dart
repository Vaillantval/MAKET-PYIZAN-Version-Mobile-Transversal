// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletCashbackImpl _$$WalletCashbackImplFromJson(Map<String, dynamic> json) =>
    _$WalletCashbackImpl(
      actif: json['actif'] as bool? ?? false,
      taux: json['taux'] == null ? 0 : jsonToDouble(json['taux']),
      plafond: json['plafond'] == null ? 0 : jsonToDouble(json['plafond']),
    );

Map<String, dynamic> _$$WalletCashbackImplToJson(
        _$WalletCashbackImpl instance) =>
    <String, dynamic>{
      'actif': instance.actif,
      'taux': instance.taux,
      'plafond': instance.plafond,
    };

_$WalletParrainageImpl _$$WalletParrainageImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletParrainageImpl(
      code: json['code'] as String,
      tauxBonus:
          json['taux_bonus'] == null ? 0 : jsonToDouble(json['taux_bonus']),
    );

Map<String, dynamic> _$$WalletParrainageImplToJson(
        _$WalletParrainageImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'taux_bonus': instance.tauxBonus,
    };

_$WalletDepotHorsLigneImpl _$$WalletDepotHorsLigneImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletDepotHorsLigneImpl(
      numeroMoncash: json['numero_moncash'] as String?,
      numeroNatcash: json['numero_natcash'] as String?,
    );

Map<String, dynamic> _$$WalletDepotHorsLigneImplToJson(
        _$WalletDepotHorsLigneImpl instance) =>
    <String, dynamic>{
      'numero_moncash': instance.numeroMoncash,
      'numero_natcash': instance.numeroNatcash,
    };

_$WalletImpl _$$WalletImplFromJson(Map<String, dynamic> json) => _$WalletImpl(
      solde: jsonToDouble(json['solde']),
      devise: json['devise'] as String? ?? 'HTG',
      isActive: json['is_active'] as bool? ?? true,
      cashback: json['cashback'] == null
          ? null
          : WalletCashback.fromJson(json['cashback'] as Map<String, dynamic>),
      parrainage: json['parrainage'] == null
          ? null
          : WalletParrainage.fromJson(
              json['parrainage'] as Map<String, dynamic>),
      depotHorsLigne: json['depot_hors_ligne'] == null
          ? null
          : WalletDepotHorsLigne.fromJson(
              json['depot_hors_ligne'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WalletImplToJson(_$WalletImpl instance) =>
    <String, dynamic>{
      'solde': instance.solde,
      'devise': instance.devise,
      'is_active': instance.isActive,
      'cashback': instance.cashback,
      'parrainage': instance.parrainage,
      'depot_hors_ligne': instance.depotHorsLigne,
    };
