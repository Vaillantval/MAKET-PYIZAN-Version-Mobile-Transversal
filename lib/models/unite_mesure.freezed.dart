// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unite_mesure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UniteMesure _$UniteMesureFromJson(Map<String, dynamic> json) {
  return _UniteMesure.fromJson(json);
}

/// @nodoc
mixin _$UniteMesure {
  int get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  int get ordre => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this UniteMesure to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UniteMesure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UniteMesureCopyWith<UniteMesure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UniteMesureCopyWith<$Res> {
  factory $UniteMesureCopyWith(
          UniteMesure value, $Res Function(UniteMesure) then) =
      _$UniteMesureCopyWithImpl<$Res, UniteMesure>;
  @useResult
  $Res call(
      {int id,
      String code,
      String nom,
      int ordre,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class _$UniteMesureCopyWithImpl<$Res, $Val extends UniteMesure>
    implements $UniteMesureCopyWith<$Res> {
  _$UniteMesureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UniteMesure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? nom = null,
    Object? ordre = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      ordre: null == ordre
          ? _value.ordre
          : ordre // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UniteMesureImplCopyWith<$Res>
    implements $UniteMesureCopyWith<$Res> {
  factory _$$UniteMesureImplCopyWith(
          _$UniteMesureImpl value, $Res Function(_$UniteMesureImpl) then) =
      __$$UniteMesureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String code,
      String nom,
      int ordre,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class __$$UniteMesureImplCopyWithImpl<$Res>
    extends _$UniteMesureCopyWithImpl<$Res, _$UniteMesureImpl>
    implements _$$UniteMesureImplCopyWith<$Res> {
  __$$UniteMesureImplCopyWithImpl(
      _$UniteMesureImpl _value, $Res Function(_$UniteMesureImpl) _then)
      : super(_value, _then);

  /// Create a copy of UniteMesure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? nom = null,
    Object? ordre = null,
    Object? isActive = null,
  }) {
    return _then(_$UniteMesureImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      ordre: null == ordre
          ? _value.ordre
          : ordre // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UniteMesureImpl implements _UniteMesure {
  const _$UniteMesureImpl(
      {required this.id,
      required this.code,
      required this.nom,
      this.ordre = 0,
      @JsonKey(name: 'is_active') this.isActive = true});

  factory _$UniteMesureImpl.fromJson(Map<String, dynamic> json) =>
      _$$UniteMesureImplFromJson(json);

  @override
  final int id;
  @override
  final String code;
  @override
  final String nom;
  @override
  @JsonKey()
  final int ordre;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'UniteMesure(id: $id, code: $code, nom: $nom, ordre: $ordre, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UniteMesureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.ordre, ordre) || other.ordre == ordre) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, code, nom, ordre, isActive);

  /// Create a copy of UniteMesure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UniteMesureImplCopyWith<_$UniteMesureImpl> get copyWith =>
      __$$UniteMesureImplCopyWithImpl<_$UniteMesureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UniteMesureImplToJson(
      this,
    );
  }
}

abstract class _UniteMesure implements UniteMesure {
  const factory _UniteMesure(
      {required final int id,
      required final String code,
      required final String nom,
      final int ordre,
      @JsonKey(name: 'is_active') final bool isActive}) = _$UniteMesureImpl;

  factory _UniteMesure.fromJson(Map<String, dynamic> json) =
      _$UniteMesureImpl.fromJson;

  @override
  int get id;
  @override
  String get code;
  @override
  String get nom;
  @override
  int get ordre;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of UniteMesure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UniteMesureImplCopyWith<_$UniteMesureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
