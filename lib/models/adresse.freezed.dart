// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adresse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Adresse _$AdresseFromJson(Map<String, dynamic> json) {
  return _Adresse.fromJson(json);
}

/// @nodoc
mixin _$Adresse {
  int get id => throw _privateConstructorUsedError;
  String get rue => throw _privateConstructorUsedError;
  String get commune => throw _privateConstructorUsedError;
  String get departement => throw _privateConstructorUsedError;
  @JsonKey(name: 'section_communale')
  String get sectionCommunale => throw _privateConstructorUsedError;
  String get telephone =>
      throw _privateConstructorUsedError; // Backend : champ libre 'details' (pas 'instructions')
  @JsonKey(name: 'details')
  String get instructions => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_default')
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this Adresse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Adresse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdresseCopyWith<Adresse> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdresseCopyWith<$Res> {
  factory $AdresseCopyWith(Adresse value, $Res Function(Adresse) then) =
      _$AdresseCopyWithImpl<$Res, Adresse>;
  @useResult
  $Res call(
      {int id,
      String rue,
      String commune,
      String departement,
      @JsonKey(name: 'section_communale') String sectionCommunale,
      String telephone,
      @JsonKey(name: 'details') String instructions,
      @JsonKey(name: 'is_default') bool isDefault});
}

/// @nodoc
class _$AdresseCopyWithImpl<$Res, $Val extends Adresse>
    implements $AdresseCopyWith<$Res> {
  _$AdresseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Adresse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rue = null,
    Object? commune = null,
    Object? departement = null,
    Object? sectionCommunale = null,
    Object? telephone = null,
    Object? instructions = null,
    Object? isDefault = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      rue: null == rue
          ? _value.rue
          : rue // ignore: cast_nullable_to_non_nullable
              as String,
      commune: null == commune
          ? _value.commune
          : commune // ignore: cast_nullable_to_non_nullable
              as String,
      departement: null == departement
          ? _value.departement
          : departement // ignore: cast_nullable_to_non_nullable
              as String,
      sectionCommunale: null == sectionCommunale
          ? _value.sectionCommunale
          : sectionCommunale // ignore: cast_nullable_to_non_nullable
              as String,
      telephone: null == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdresseImplCopyWith<$Res> implements $AdresseCopyWith<$Res> {
  factory _$$AdresseImplCopyWith(
          _$AdresseImpl value, $Res Function(_$AdresseImpl) then) =
      __$$AdresseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String rue,
      String commune,
      String departement,
      @JsonKey(name: 'section_communale') String sectionCommunale,
      String telephone,
      @JsonKey(name: 'details') String instructions,
      @JsonKey(name: 'is_default') bool isDefault});
}

/// @nodoc
class __$$AdresseImplCopyWithImpl<$Res>
    extends _$AdresseCopyWithImpl<$Res, _$AdresseImpl>
    implements _$$AdresseImplCopyWith<$Res> {
  __$$AdresseImplCopyWithImpl(
      _$AdresseImpl _value, $Res Function(_$AdresseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Adresse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rue = null,
    Object? commune = null,
    Object? departement = null,
    Object? sectionCommunale = null,
    Object? telephone = null,
    Object? instructions = null,
    Object? isDefault = null,
  }) {
    return _then(_$AdresseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      rue: null == rue
          ? _value.rue
          : rue // ignore: cast_nullable_to_non_nullable
              as String,
      commune: null == commune
          ? _value.commune
          : commune // ignore: cast_nullable_to_non_nullable
              as String,
      departement: null == departement
          ? _value.departement
          : departement // ignore: cast_nullable_to_non_nullable
              as String,
      sectionCommunale: null == sectionCommunale
          ? _value.sectionCommunale
          : sectionCommunale // ignore: cast_nullable_to_non_nullable
              as String,
      telephone: null == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdresseImpl implements _Adresse {
  const _$AdresseImpl(
      {required this.id,
      required this.rue,
      required this.commune,
      required this.departement,
      @JsonKey(name: 'section_communale') this.sectionCommunale = '',
      this.telephone = '',
      @JsonKey(name: 'details') this.instructions = '',
      @JsonKey(name: 'is_default') this.isDefault = false});

  factory _$AdresseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdresseImplFromJson(json);

  @override
  final int id;
  @override
  final String rue;
  @override
  final String commune;
  @override
  final String departement;
  @override
  @JsonKey(name: 'section_communale')
  final String sectionCommunale;
  @override
  @JsonKey()
  final String telephone;
// Backend : champ libre 'details' (pas 'instructions')
  @override
  @JsonKey(name: 'details')
  final String instructions;
  @override
  @JsonKey(name: 'is_default')
  final bool isDefault;

  @override
  String toString() {
    return 'Adresse(id: $id, rue: $rue, commune: $commune, departement: $departement, sectionCommunale: $sectionCommunale, telephone: $telephone, instructions: $instructions, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdresseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rue, rue) || other.rue == rue) &&
            (identical(other.commune, commune) || other.commune == commune) &&
            (identical(other.departement, departement) ||
                other.departement == departement) &&
            (identical(other.sectionCommunale, sectionCommunale) ||
                other.sectionCommunale == sectionCommunale) &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, rue, commune, departement,
      sectionCommunale, telephone, instructions, isDefault);

  /// Create a copy of Adresse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdresseImplCopyWith<_$AdresseImpl> get copyWith =>
      __$$AdresseImplCopyWithImpl<_$AdresseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdresseImplToJson(
      this,
    );
  }
}

abstract class _Adresse implements Adresse {
  const factory _Adresse(
      {required final int id,
      required final String rue,
      required final String commune,
      required final String departement,
      @JsonKey(name: 'section_communale') final String sectionCommunale,
      final String telephone,
      @JsonKey(name: 'details') final String instructions,
      @JsonKey(name: 'is_default') final bool isDefault}) = _$AdresseImpl;

  factory _Adresse.fromJson(Map<String, dynamic> json) = _$AdresseImpl.fromJson;

  @override
  int get id;
  @override
  String get rue;
  @override
  String get commune;
  @override
  String get departement;
  @override
  @JsonKey(name: 'section_communale')
  String get sectionCommunale;
  @override
  String get telephone; // Backend : champ libre 'details' (pas 'instructions')
  @override
  @JsonKey(name: 'details')
  String get instructions;
  @override
  @JsonKey(name: 'is_default')
  bool get isDefault;

  /// Create a copy of Adresse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdresseImplCopyWith<_$AdresseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
