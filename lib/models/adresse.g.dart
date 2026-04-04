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
      sectionCommunale: json['sectionCommunale'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$AdresseImplToJson(_$AdresseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rue': instance.rue,
      'commune': instance.commune,
      'departement': instance.departement,
      'sectionCommunale': instance.sectionCommunale,
      'telephone': instance.telephone,
      'instructions': instance.instructions,
      'isDefault': instance.isDefault,
    };
