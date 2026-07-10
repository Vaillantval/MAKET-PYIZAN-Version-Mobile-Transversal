// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletTransactionImpl _$$WalletTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletTransactionImpl(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      typeDisplay: json['type_display'] as String? ?? '',
      montant: (json['montant'] as num).toDouble(),
      soldeApres: (json['solde_apres'] as num).toDouble(),
      commandeNumero: json['commande_numero'] as String?,
      description: json['description'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$WalletTransactionImplToJson(
        _$WalletTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'type_display': instance.typeDisplay,
      'montant': instance.montant,
      'solde_apres': instance.soldeApres,
      'commande_numero': instance.commandeNumero,
      'description': instance.description,
      'reference': instance.reference,
      'created_at': instance.createdAt,
    };
