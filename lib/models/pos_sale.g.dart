// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PosSaleImpl _$$PosSaleImplFromJson(Map<String, dynamic> json) =>
    _$PosSaleImpl(
      idempotencyKey: json['idempotency_key'] as String,
      numeroVente: json['numero_vente'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PosItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      montantTotal: jsonToDouble(json['montant_total']),
      methodePaiement: json['methode_paiement'] as String? ?? 'cash',
      montantWallet: json['montant_wallet'] == null
          ? 0
          : jsonToDouble(json['montant_wallet']),
      statut: json['statut'] as String? ?? 'en_attente',
      vendueLe: json['vendue_le'] as String,
      syncStatus: json['syncStatus'] as String? ?? 'enAttente',
    );

Map<String, dynamic> _$$PosSaleImplToJson(_$PosSaleImpl instance) =>
    <String, dynamic>{
      'idempotency_key': instance.idempotencyKey,
      'numero_vente': instance.numeroVente,
      'items': instance.items,
      'montant_total': instance.montantTotal,
      'methode_paiement': instance.methodePaiement,
      'montant_wallet': instance.montantWallet,
      'statut': instance.statut,
      'vendue_le': instance.vendueLe,
      'syncStatus': instance.syncStatus,
    };
