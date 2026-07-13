// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bon_cadeau.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BonCadeau _$BonCadeauFromJson(Map<String, dynamic> json) {
  return _BonCadeau.fromJson(json);
}

/// @nodoc
mixin _$BonCadeau {
  int get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  @JsonKey(fromJson: jsonToDouble)
  double get montant => throw _privateConstructorUsedError;
  String get statut => throw _privateConstructorUsedError;
  @JsonKey(name: 'statut_display')
  String get statutDisplay => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_destinataire')
  String? get emailDestinataire => throw _privateConstructorUsedError;
  @JsonKey(name: 'offert_par')
  String? get offertPar => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BonCadeau to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BonCadeau
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BonCadeauCopyWith<BonCadeau> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BonCadeauCopyWith<$Res> {
  factory $BonCadeauCopyWith(BonCadeau value, $Res Function(BonCadeau) then) =
      _$BonCadeauCopyWithImpl<$Res, BonCadeau>;
  @useResult
  $Res call(
      {int id,
      String code,
      @JsonKey(fromJson: jsonToDouble) double montant,
      String statut,
      @JsonKey(name: 'statut_display') String statutDisplay,
      @JsonKey(name: 'email_destinataire') String? emailDestinataire,
      @JsonKey(name: 'offert_par') String? offertPar,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class _$BonCadeauCopyWithImpl<$Res, $Val extends BonCadeau>
    implements $BonCadeauCopyWith<$Res> {
  _$BonCadeauCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BonCadeau
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? montant = null,
    Object? statut = null,
    Object? statutDisplay = null,
    Object? emailDestinataire = freezed,
    Object? offertPar = freezed,
    Object? createdAt = null,
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
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      statutDisplay: null == statutDisplay
          ? _value.statutDisplay
          : statutDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      emailDestinataire: freezed == emailDestinataire
          ? _value.emailDestinataire
          : emailDestinataire // ignore: cast_nullable_to_non_nullable
              as String?,
      offertPar: freezed == offertPar
          ? _value.offertPar
          : offertPar // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BonCadeauImplCopyWith<$Res>
    implements $BonCadeauCopyWith<$Res> {
  factory _$$BonCadeauImplCopyWith(
          _$BonCadeauImpl value, $Res Function(_$BonCadeauImpl) then) =
      __$$BonCadeauImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String code,
      @JsonKey(fromJson: jsonToDouble) double montant,
      String statut,
      @JsonKey(name: 'statut_display') String statutDisplay,
      @JsonKey(name: 'email_destinataire') String? emailDestinataire,
      @JsonKey(name: 'offert_par') String? offertPar,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class __$$BonCadeauImplCopyWithImpl<$Res>
    extends _$BonCadeauCopyWithImpl<$Res, _$BonCadeauImpl>
    implements _$$BonCadeauImplCopyWith<$Res> {
  __$$BonCadeauImplCopyWithImpl(
      _$BonCadeauImpl _value, $Res Function(_$BonCadeauImpl) _then)
      : super(_value, _then);

  /// Create a copy of BonCadeau
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? montant = null,
    Object? statut = null,
    Object? statutDisplay = null,
    Object? emailDestinataire = freezed,
    Object? offertPar = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$BonCadeauImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      statutDisplay: null == statutDisplay
          ? _value.statutDisplay
          : statutDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      emailDestinataire: freezed == emailDestinataire
          ? _value.emailDestinataire
          : emailDestinataire // ignore: cast_nullable_to_non_nullable
              as String?,
      offertPar: freezed == offertPar
          ? _value.offertPar
          : offertPar // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BonCadeauImpl implements _BonCadeau {
  const _$BonCadeauImpl(
      {required this.id,
      required this.code,
      @JsonKey(fromJson: jsonToDouble) required this.montant,
      required this.statut,
      @JsonKey(name: 'statut_display') this.statutDisplay = '',
      @JsonKey(name: 'email_destinataire') this.emailDestinataire,
      @JsonKey(name: 'offert_par') this.offertPar,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$BonCadeauImpl.fromJson(Map<String, dynamic> json) =>
      _$$BonCadeauImplFromJson(json);

  @override
  final int id;
  @override
  final String code;
  @override
  @JsonKey(fromJson: jsonToDouble)
  final double montant;
  @override
  final String statut;
  @override
  @JsonKey(name: 'statut_display')
  final String statutDisplay;
  @override
  @JsonKey(name: 'email_destinataire')
  final String? emailDestinataire;
  @override
  @JsonKey(name: 'offert_par')
  final String? offertPar;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'BonCadeau(id: $id, code: $code, montant: $montant, statut: $statut, statutDisplay: $statutDisplay, emailDestinataire: $emailDestinataire, offertPar: $offertPar, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BonCadeauImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.montant, montant) || other.montant == montant) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.statutDisplay, statutDisplay) ||
                other.statutDisplay == statutDisplay) &&
            (identical(other.emailDestinataire, emailDestinataire) ||
                other.emailDestinataire == emailDestinataire) &&
            (identical(other.offertPar, offertPar) ||
                other.offertPar == offertPar) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, code, montant, statut,
      statutDisplay, emailDestinataire, offertPar, createdAt);

  /// Create a copy of BonCadeau
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BonCadeauImplCopyWith<_$BonCadeauImpl> get copyWith =>
      __$$BonCadeauImplCopyWithImpl<_$BonCadeauImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BonCadeauImplToJson(
      this,
    );
  }
}

abstract class _BonCadeau implements BonCadeau {
  const factory _BonCadeau(
          {required final int id,
          required final String code,
          @JsonKey(fromJson: jsonToDouble) required final double montant,
          required final String statut,
          @JsonKey(name: 'statut_display') final String statutDisplay,
          @JsonKey(name: 'email_destinataire') final String? emailDestinataire,
          @JsonKey(name: 'offert_par') final String? offertPar,
          @JsonKey(name: 'created_at') required final String createdAt}) =
      _$BonCadeauImpl;

  factory _BonCadeau.fromJson(Map<String, dynamic> json) =
      _$BonCadeauImpl.fromJson;

  @override
  int get id;
  @override
  String get code;
  @override
  @JsonKey(fromJson: jsonToDouble)
  double get montant;
  @override
  String get statut;
  @override
  @JsonKey(name: 'statut_display')
  String get statutDisplay;
  @override
  @JsonKey(name: 'email_destinataire')
  String? get emailDestinataire;
  @override
  @JsonKey(name: 'offert_par')
  String? get offertPar;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of BonCadeau
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BonCadeauImplCopyWith<_$BonCadeauImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
