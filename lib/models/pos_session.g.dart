// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PosSessionImpl _$$PosSessionImplFromJson(Map<String, dynamic> json) =>
    _$PosSessionImpl(
      id: (json['id'] as num).toInt(),
      statut: json['statut'] as String,
      fondsOuverture: (json['fonds_ouverture'] as num).toDouble(),
      fondsFermeture: (json['fonds_fermeture'] as num?)?.toDouble(),
      ecartCaisse: (json['ecart_caisse'] as num?)?.toDouble(),
      ouverteLe: json['ouverte_le'] as String,
      fermeeLe: json['fermee_le'] as String?,
    );

Map<String, dynamic> _$$PosSessionImplToJson(_$PosSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'statut': instance.statut,
      'fonds_ouverture': instance.fondsOuverture,
      'fonds_fermeture': instance.fondsFermeture,
      'ecart_caisse': instance.ecartCaisse,
      'ouverte_le': instance.ouverteLe,
      'fermee_le': instance.fermeeLe,
    };
