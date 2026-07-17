// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adresse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdresseImpl _$$AdresseImplFromJson(Map<String, dynamic> json) =>
    _$AdresseImpl(
      id: (json['id'] as num).toInt(),
      rue: json['rue'] as String,
      commune: json['commune'] as String,
      departement: json['departement'] as String,
      sectionCommunale: json['section_communale'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      instructions: json['details'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
    );

Map<String, dynamic> _$$AdresseImplToJson(_$AdresseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rue': instance.rue,
      'commune': instance.commune,
      'departement': instance.departement,
      'section_communale': instance.sectionCommunale,
      'telephone': instance.telephone,
      'details': instance.instructions,
      'is_default': instance.isDefault,
    };
