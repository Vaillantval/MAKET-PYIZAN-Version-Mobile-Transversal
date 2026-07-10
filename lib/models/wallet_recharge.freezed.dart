// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_recharge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WalletRecharge _$WalletRechargeFromJson(Map<String, dynamic> json) {
  return _WalletRecharge.fromJson(json);
}

/// @nodoc
mixin _$WalletRecharge {
  int get id => throw _privateConstructorUsedError;
  double get montant => throw _privateConstructorUsedError;
  String get methode => throw _privateConstructorUsedError;
  @JsonKey(name: 'methode_display')
  String get methodeDisplay => throw _privateConstructorUsedError;
  String get statut => throw _privateConstructorUsedError;
  @JsonKey(name: 'statut_display')
  String get statutDisplay => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WalletRecharge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletRecharge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletRechargeCopyWith<WalletRecharge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletRechargeCopyWith<$Res> {
  factory $WalletRechargeCopyWith(
          WalletRecharge value, $Res Function(WalletRecharge) then) =
      _$WalletRechargeCopyWithImpl<$Res, WalletRecharge>;
  @useResult
  $Res call(
      {int id,
      double montant,
      String methode,
      @JsonKey(name: 'methode_display') String methodeDisplay,
      String statut,
      @JsonKey(name: 'statut_display') String statutDisplay,
      String reference,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class _$WalletRechargeCopyWithImpl<$Res, $Val extends WalletRecharge>
    implements $WalletRechargeCopyWith<$Res> {
  _$WalletRechargeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletRecharge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? montant = null,
    Object? methode = null,
    Object? methodeDisplay = null,
    Object? statut = null,
    Object? statutDisplay = null,
    Object? reference = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      methode: null == methode
          ? _value.methode
          : methode // ignore: cast_nullable_to_non_nullable
              as String,
      methodeDisplay: null == methodeDisplay
          ? _value.methodeDisplay
          : methodeDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      statutDisplay: null == statutDisplay
          ? _value.statutDisplay
          : statutDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletRechargeImplCopyWith<$Res>
    implements $WalletRechargeCopyWith<$Res> {
  factory _$$WalletRechargeImplCopyWith(_$WalletRechargeImpl value,
          $Res Function(_$WalletRechargeImpl) then) =
      __$$WalletRechargeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      double montant,
      String methode,
      @JsonKey(name: 'methode_display') String methodeDisplay,
      String statut,
      @JsonKey(name: 'statut_display') String statutDisplay,
      String reference,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class __$$WalletRechargeImplCopyWithImpl<$Res>
    extends _$WalletRechargeCopyWithImpl<$Res, _$WalletRechargeImpl>
    implements _$$WalletRechargeImplCopyWith<$Res> {
  __$$WalletRechargeImplCopyWithImpl(
      _$WalletRechargeImpl _value, $Res Function(_$WalletRechargeImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletRecharge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? montant = null,
    Object? methode = null,
    Object? methodeDisplay = null,
    Object? statut = null,
    Object? statutDisplay = null,
    Object? reference = null,
    Object? createdAt = null,
  }) {
    return _then(_$WalletRechargeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      methode: null == methode
          ? _value.methode
          : methode // ignore: cast_nullable_to_non_nullable
              as String,
      methodeDisplay: null == methodeDisplay
          ? _value.methodeDisplay
          : methodeDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      statutDisplay: null == statutDisplay
          ? _value.statutDisplay
          : statutDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletRechargeImpl implements _WalletRecharge {
  const _$WalletRechargeImpl(
      {required this.id,
      required this.montant,
      required this.methode,
      @JsonKey(name: 'methode_display') this.methodeDisplay = '',
      required this.statut,
      @JsonKey(name: 'statut_display') this.statutDisplay = '',
      this.reference = '',
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$WalletRechargeImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletRechargeImplFromJson(json);

  @override
  final int id;
  @override
  final double montant;
  @override
  final String methode;
  @override
  @JsonKey(name: 'methode_display')
  final String methodeDisplay;
  @override
  final String statut;
  @override
  @JsonKey(name: 'statut_display')
  final String statutDisplay;
  @override
  @JsonKey()
  final String reference;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'WalletRecharge(id: $id, montant: $montant, methode: $methode, methodeDisplay: $methodeDisplay, statut: $statut, statutDisplay: $statutDisplay, reference: $reference, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletRechargeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.montant, montant) || other.montant == montant) &&
            (identical(other.methode, methode) || other.methode == methode) &&
            (identical(other.methodeDisplay, methodeDisplay) ||
                other.methodeDisplay == methodeDisplay) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.statutDisplay, statutDisplay) ||
                other.statutDisplay == statutDisplay) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, montant, methode,
      methodeDisplay, statut, statutDisplay, reference, createdAt);

  /// Create a copy of WalletRecharge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletRechargeImplCopyWith<_$WalletRechargeImpl> get copyWith =>
      __$$WalletRechargeImplCopyWithImpl<_$WalletRechargeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletRechargeImplToJson(
      this,
    );
  }
}

abstract class _WalletRecharge implements WalletRecharge {
  const factory _WalletRecharge(
          {required final int id,
          required final double montant,
          required final String methode,
          @JsonKey(name: 'methode_display') final String methodeDisplay,
          required final String statut,
          @JsonKey(name: 'statut_display') final String statutDisplay,
          final String reference,
          @JsonKey(name: 'created_at') required final String createdAt}) =
      _$WalletRechargeImpl;

  factory _WalletRecharge.fromJson(Map<String, dynamic> json) =
      _$WalletRechargeImpl.fromJson;

  @override
  int get id;
  @override
  double get montant;
  @override
  String get methode;
  @override
  @JsonKey(name: 'methode_display')
  String get methodeDisplay;
  @override
  String get statut;
  @override
  @JsonKey(name: 'statut_display')
  String get statutDisplay;
  @override
  String get reference;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of WalletRecharge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletRechargeImplCopyWith<_$WalletRechargeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
