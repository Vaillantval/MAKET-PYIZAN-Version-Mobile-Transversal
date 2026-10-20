// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entreprise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntrepriseMembreImpl _$$EntrepriseMembreImplFromJson(
        Map<String, dynamic> json) =>
    _$EntrepriseMembreImpl(
      id: (json['id'] as num).toInt(),
      membreId: (json['membre_id'] as num?)?.toInt(),
      nom: json['nom'] as String? ?? '',
      type: json['type'] as String? ?? 'producteur',
      typeLabel: json['type_label'] as String? ?? '',
      statut: json['statut'] as String? ?? 'en_attente',
      code: json['code'] as String? ?? '',
      role: json['role'] as String? ?? 'gestionnaire',
      roleLabel: json['role_label'] as String? ?? '',
    );

Map<String, dynamic> _$$EntrepriseMembreImplToJson(
        _$EntrepriseMembreImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'membre_id': instance.membreId,
      'nom': instance.nom,
      'type': instance.type,
      'type_label': instance.typeLabel,
      'statut': instance.statut,
      'code': instance.code,
      'role': instance.role,
      'role_label': instance.roleLabel,
    };
