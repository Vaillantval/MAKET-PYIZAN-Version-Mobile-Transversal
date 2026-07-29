// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unite_mesure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UniteMesureImpl _$$UniteMesureImplFromJson(Map<String, dynamic> json) =>
    _$UniteMesureImpl(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      nom: json['nom'] as String,
      ordre: (json['ordre'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$UniteMesureImplToJson(_$UniteMesureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'nom': instance.nom,
      'ordre': instance.ordre,
      'is_active': instance.isActive,
    };
