// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entreprise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EntrepriseMembre _$EntrepriseMembreFromJson(Map<String, dynamic> json) {
  return _EntrepriseMembre.fromJson(json);
}

/// @nodoc
mixin _$EntrepriseMembre {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'membre_id')
  int? get membreId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;

  /// producteur | fournisseur | entreprise
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'type_label')
  String get typeLabel => throw _privateConstructorUsedError;

  /// en_attente | actif | suspendu | inactif
  String get statut => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;

  /// proprietaire | gestionnaire
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'role_label')
  String get roleLabel => throw _privateConstructorUsedError;

  /// Serializes this EntrepriseMembre to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EntrepriseMembre
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntrepriseMembreCopyWith<EntrepriseMembre> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntrepriseMembreCopyWith<$Res> {
  factory $EntrepriseMembreCopyWith(
          EntrepriseMembre value, $Res Function(EntrepriseMembre) then) =
      _$EntrepriseMembreCopyWithImpl<$Res, EntrepriseMembre>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'membre_id') int? membreId,
      String nom,
      String type,
      @JsonKey(name: 'type_label') String typeLabel,
      String statut,
      String code,
      String role,
      @JsonKey(name: 'role_label') String roleLabel});
}

/// @nodoc
class _$EntrepriseMembreCopyWithImpl<$Res, $Val extends EntrepriseMembre>
    implements $EntrepriseMembreCopyWith<$Res> {
  _$EntrepriseMembreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EntrepriseMembre
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? membreId = freezed,
    Object? nom = null,
    Object? type = null,
    Object? typeLabel = null,
    Object? statut = null,
    Object? code = null,
    Object? role = null,
    Object? roleLabel = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      membreId: freezed == membreId
          ? _value.membreId
          : membreId // ignore: cast_nullable_to_non_nullable
              as int?,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      typeLabel: null == typeLabel
          ? _value.typeLabel
          : typeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      roleLabel: null == roleLabel
          ? _value.roleLabel
          : roleLabel // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EntrepriseMembreImplCopyWith<$Res>
    implements $EntrepriseMembreCopyWith<$Res> {
  factory _$$EntrepriseMembreImplCopyWith(_$EntrepriseMembreImpl value,
          $Res Function(_$EntrepriseMembreImpl) then) =
      __$$EntrepriseMembreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'membre_id') int? membreId,
      String nom,
      String type,
      @JsonKey(name: 'type_label') String typeLabel,
      String statut,
      String code,
      String role,
      @JsonKey(name: 'role_label') String roleLabel});
}

/// @nodoc
class __$$EntrepriseMembreImplCopyWithImpl<$Res>
    extends _$EntrepriseMembreCopyWithImpl<$Res, _$EntrepriseMembreImpl>
    implements _$$EntrepriseMembreImplCopyWith<$Res> {
  __$$EntrepriseMembreImplCopyWithImpl(_$EntrepriseMembreImpl _value,
      $Res Function(_$EntrepriseMembreImpl) _then)
      : super(_value, _then);

  /// Create a copy of EntrepriseMembre
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? membreId = freezed,
    Object? nom = null,
    Object? type = null,
    Object? typeLabel = null,
    Object? statut = null,
    Object? code = null,
    Object? role = null,
    Object? roleLabel = null,
  }) {
    return _then(_$EntrepriseMembreImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      membreId: freezed == membreId
          ? _value.membreId
          : membreId // ignore: cast_nullable_to_non_nullable
              as int?,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      typeLabel: null == typeLabel
          ? _value.typeLabel
          : typeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      roleLabel: null == roleLabel
          ? _value.roleLabel
          : roleLabel // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EntrepriseMembreImpl extends _EntrepriseMembre {
  const _$EntrepriseMembreImpl(
      {required this.id,
      @JsonKey(name: 'membre_id') this.membreId,
      this.nom = '',
      this.type = 'producteur',
      @JsonKey(name: 'type_label') this.typeLabel = '',
      this.statut = 'en_attente',
      this.code = '',
      this.role = 'gestionnaire',
      @JsonKey(name: 'role_label') this.roleLabel = ''})
      : super._();

  factory _$EntrepriseMembreImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntrepriseMembreImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'membre_id')
  final int? membreId;
  @override
  @JsonKey()
  final String nom;

  /// producteur | fournisseur | entreprise
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey(name: 'type_label')
  final String typeLabel;

  /// en_attente | actif | suspendu | inactif
  @override
  @JsonKey()
  final String statut;
  @override
  @JsonKey()
  final String code;

  /// proprietaire | gestionnaire
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey(name: 'role_label')
  final String roleLabel;

  @override
  String toString() {
    return 'EntrepriseMembre(id: $id, membreId: $membreId, nom: $nom, type: $type, typeLabel: $typeLabel, statut: $statut, code: $code, role: $role, roleLabel: $roleLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntrepriseMembreImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.membreId, membreId) ||
                other.membreId == membreId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.typeLabel, typeLabel) ||
                other.typeLabel == typeLabel) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.roleLabel, roleLabel) ||
                other.roleLabel == roleLabel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, membreId, nom, type,
      typeLabel, statut, code, role, roleLabel);

  /// Create a copy of EntrepriseMembre
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntrepriseMembreImplCopyWith<_$EntrepriseMembreImpl> get copyWith =>
      __$$EntrepriseMembreImplCopyWithImpl<_$EntrepriseMembreImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntrepriseMembreImplToJson(
      this,
    );
  }
}

abstract class _EntrepriseMembre extends EntrepriseMembre {
  const factory _EntrepriseMembre(
          {required final int id,
          @JsonKey(name: 'membre_id') final int? membreId,
          final String nom,
          final String type,
          @JsonKey(name: 'type_label') final String typeLabel,
          final String statut,
          final String code,
          final String role,
          @JsonKey(name: 'role_label') final String roleLabel}) =
      _$EntrepriseMembreImpl;
  const _EntrepriseMembre._() : super._();

  factory _EntrepriseMembre.fromJson(Map<String, dynamic> json) =
      _$EntrepriseMembreImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'membre_id')
  int? get membreId;
  @override
  String get nom;

  /// producteur | fournisseur | entreprise
  @override
  String get type;
  @override
  @JsonKey(name: 'type_label')
  String get typeLabel;

  /// en_attente | actif | suspendu | inactif
  @override
  String get statut;
  @override
  String get code;

  /// proprietaire | gestionnaire
  @override
  String get role;
  @override
  @JsonKey(name: 'role_label')
  String get roleLabel;

  /// Create a copy of EntrepriseMembre
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntrepriseMembreImplCopyWith<_$EntrepriseMembreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
