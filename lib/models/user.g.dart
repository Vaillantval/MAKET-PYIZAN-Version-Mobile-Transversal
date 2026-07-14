// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      telephone: json['telephone'] as String? ?? '',
      photo: json['photo'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      isStaff: json['is_staff'] as bool? ?? false,
      profilProducteurStatut: json['profil_producteur_statut'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'role': instance.role,
      'telephone': instance.telephone,
      'photo': instance.photo,
      'is_verified': instance.isVerified,
      'is_superuser': instance.isSuperuser,
      'is_staff': instance.isStaff,
      'profil_producteur_statut': instance.profilProducteurStatut,
    };
