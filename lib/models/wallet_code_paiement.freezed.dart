// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_code_paiement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WalletCodePaiement _$WalletCodePaiementFromJson(Map<String, dynamic> json) {
  return _WalletCodePaiement.fromJson(json);
}

/// @nodoc
mixin _$WalletCodePaiement {
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'expire_dans')
  int get expireDans => throw _privateConstructorUsedError; // secondes
  double get solde => throw _privateConstructorUsedError;

  /// Serializes this WalletCodePaiement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletCodePaiement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletCodePaiementCopyWith<WalletCodePaiement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletCodePaiementCopyWith<$Res> {
  factory $WalletCodePaiementCopyWith(
          WalletCodePaiement value, $Res Function(WalletCodePaiement) then) =
      _$WalletCodePaiementCopyWithImpl<$Res, WalletCodePaiement>;
  @useResult
  $Res call(
      {String code,
      @JsonKey(name: 'expire_dans') int expireDans,
      double solde});
}

/// @nodoc
class _$WalletCodePaiementCopyWithImpl<$Res, $Val extends WalletCodePaiement>
    implements $WalletCodePaiementCopyWith<$Res> {
  _$WalletCodePaiementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletCodePaiement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? expireDans = null,
    Object? solde = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      expireDans: null == expireDans
          ? _value.expireDans
          : expireDans // ignore: cast_nullable_to_non_nullable
              as int,
      solde: null == solde
          ? _value.solde
          : solde // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletCodePaiementImplCopyWith<$Res>
    implements $WalletCodePaiementCopyWith<$Res> {
  factory _$$WalletCodePaiementImplCopyWith(_$WalletCodePaiementImpl value,
          $Res Function(_$WalletCodePaiementImpl) then) =
      __$$WalletCodePaiementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      @JsonKey(name: 'expire_dans') int expireDans,
      double solde});
}

/// @nodoc
class __$$WalletCodePaiementImplCopyWithImpl<$Res>
    extends _$WalletCodePaiementCopyWithImpl<$Res, _$WalletCodePaiementImpl>
    implements _$$WalletCodePaiementImplCopyWith<$Res> {
  __$$WalletCodePaiementImplCopyWithImpl(_$WalletCodePaiementImpl _value,
      $Res Function(_$WalletCodePaiementImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletCodePaiement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? expireDans = null,
    Object? solde = null,
  }) {
    return _then(_$WalletCodePaiementImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      expireDans: null == expireDans
          ? _value.expireDans
          : expireDans // ignore: cast_nullable_to_non_nullable
              as int,
      solde: null == solde
          ? _value.solde
          : solde // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletCodePaiementImpl implements _WalletCodePaiement {
  const _$WalletCodePaiementImpl(
      {required this.code,
      @JsonKey(name: 'expire_dans') required this.expireDans,
      required this.solde});

  factory _$WalletCodePaiementImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletCodePaiementImplFromJson(json);

  @override
  final String code;
  @override
  @JsonKey(name: 'expire_dans')
  final int expireDans;
// secondes
  @override
  final double solde;

  @override
  String toString() {
    return 'WalletCodePaiement(code: $code, expireDans: $expireDans, solde: $solde)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletCodePaiementImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.expireDans, expireDans) ||
                other.expireDans == expireDans) &&
            (identical(other.solde, solde) || other.solde == solde));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, expireDans, solde);

  /// Create a copy of WalletCodePaiement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletCodePaiementImplCopyWith<_$WalletCodePaiementImpl> get copyWith =>
      __$$WalletCodePaiementImplCopyWithImpl<_$WalletCodePaiementImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletCodePaiementImplToJson(
      this,
    );
  }
}

abstract class _WalletCodePaiement implements WalletCodePaiement {
  const factory _WalletCodePaiement(
      {required final String code,
      @JsonKey(name: 'expire_dans') required final int expireDans,
      required final double solde}) = _$WalletCodePaiementImpl;

  factory _WalletCodePaiement.fromJson(Map<String, dynamic> json) =
      _$WalletCodePaiementImpl.fromJson;

  @override
  String get code;
  @override
  @JsonKey(name: 'expire_dans')
  int get expireDans; // secondes
  @override
  double get solde;

  /// Create a copy of WalletCodePaiement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletCodePaiementImplCopyWith<_$WalletCodePaiementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
