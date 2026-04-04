// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      telephone: json['telephone'] as String? ?? '',
      photo: json['photo'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isSuperuser: json['isSuperuser'] as bool? ?? false,
      isStaff: json['isStaff'] as bool? ?? false,
      profilProducteurStatut: json['profilProducteurStatut'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': instance.role,
      'telephone': instance.telephone,
      'photo': instance.photo,
      'isVerified': instance.isVerified,
      'isSuperuser': instance.isSuperuser,
      'isStaff': instance.isStaff,
      'profilProducteurStatut': instance.profilProducteurStatut,
    };
