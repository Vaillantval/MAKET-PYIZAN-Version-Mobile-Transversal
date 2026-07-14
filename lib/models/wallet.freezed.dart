// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WalletCashback _$WalletCashbackFromJson(Map<String, dynamic> json) {
  return _WalletCashback.fromJson(json);
}

/// @nodoc
mixin _$WalletCashback {
  bool get actif => throw _privateConstructorUsedError;
  @JsonKey(fromJson: jsonToDouble)
  double get taux =>
      throw _privateConstructorUsedError; // plafond == 0 signifie "pas de plafond"
  @JsonKey(fromJson: jsonToDouble)
  double get plafond => throw _privateConstructorUsedError;

  /// Serializes this WalletCashback to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletCashback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletCashbackCopyWith<WalletCashback> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletCashbackCopyWith<$Res> {
  factory $WalletCashbackCopyWith(
          WalletCashback value, $Res Function(WalletCashback) then) =
      _$WalletCashbackCopyWithImpl<$Res, WalletCashback>;
  @useResult
  $Res call(
      {bool actif,
      @JsonKey(fromJson: jsonToDouble) double taux,
      @JsonKey(fromJson: jsonToDouble) double plafond});
}

/// @nodoc
class _$WalletCashbackCopyWithImpl<$Res, $Val extends WalletCashback>
    implements $WalletCashbackCopyWith<$Res> {
  _$WalletCashbackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletCashback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actif = null,
    Object? taux = null,
    Object? plafond = null,
  }) {
    return _then(_value.copyWith(
      actif: null == actif
          ? _value.actif
          : actif // ignore: cast_nullable_to_non_nullable
              as bool,
      taux: null == taux
          ? _value.taux
          : taux // ignore: cast_nullable_to_non_nullable
              as double,
      plafond: null == plafond
          ? _value.plafond
          : plafond // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletCashbackImplCopyWith<$Res>
    implements $WalletCashbackCopyWith<$Res> {
  factory _$$WalletCashbackImplCopyWith(_$WalletCashbackImpl value,
          $Res Function(_$WalletCashbackImpl) then) =
      __$$WalletCashbackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool actif,
      @JsonKey(fromJson: jsonToDouble) double taux,
      @JsonKey(fromJson: jsonToDouble) double plafond});
}

/// @nodoc
class __$$WalletCashbackImplCopyWithImpl<$Res>
    extends _$WalletCashbackCopyWithImpl<$Res, _$WalletCashbackImpl>
    implements _$$WalletCashbackImplCopyWith<$Res> {
  __$$WalletCashbackImplCopyWithImpl(
      _$WalletCashbackImpl _value, $Res Function(_$WalletCashbackImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletCashback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actif = null,
    Object? taux = null,
    Object? plafond = null,
  }) {
    return _then(_$WalletCashbackImpl(
      actif: null == actif
          ? _value.actif
          : actif // ignore: cast_nullable_to_non_nullable
              as bool,
      taux: null == taux
          ? _value.taux
          : taux // ignore: cast_nullable_to_non_nullable
              as double,
      plafond: null == plafond
          ? _value.plafond
          : plafond // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletCashbackImpl implements _WalletCashback {
  const _$WalletCashbackImpl(
      {this.actif = false,
      @JsonKey(fromJson: jsonToDouble) this.taux = 0,
      @JsonKey(fromJson: jsonToDouble) this.plafond = 0});

  factory _$WalletCashbackImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletCashbackImplFromJson(json);

  @override
  @JsonKey()
  final bool actif;
  @override
  @JsonKey(fromJson: jsonToDouble)
  final double taux;
// plafond == 0 signifie "pas de plafond"
  @override
  @JsonKey(fromJson: jsonToDouble)
  final double plafond;

  @override
  String toString() {
    return 'WalletCashback(actif: $actif, taux: $taux, plafond: $plafond)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletCashbackImpl &&
            (identical(other.actif, actif) || other.actif == actif) &&
            (identical(other.taux, taux) || other.taux == taux) &&
            (identical(other.plafond, plafond) || other.plafond == plafond));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, actif, taux, plafond);

  /// Create a copy of WalletCashback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletCashbackImplCopyWith<_$WalletCashbackImpl> get copyWith =>
      __$$WalletCashbackImplCopyWithImpl<_$WalletCashbackImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletCashbackImplToJson(
      this,
    );
  }
}

abstract class _WalletCashback implements WalletCashback {
  const factory _WalletCashback(
          {final bool actif,
          @JsonKey(fromJson: jsonToDouble) final double taux,
          @JsonKey(fromJson: jsonToDouble) final double plafond}) =
      _$WalletCashbackImpl;

  factory _WalletCashback.fromJson(Map<String, dynamic> json) =
      _$WalletCashbackImpl.fromJson;

  @override
  bool get actif;
  @override
  @JsonKey(fromJson: jsonToDouble)
  double get taux; // plafond == 0 signifie "pas de plafond"
  @override
  @JsonKey(fromJson: jsonToDouble)
  double get plafond;

  /// Create a copy of WalletCashback
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletCashbackImplCopyWith<_$WalletCashbackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WalletParrainage _$WalletParrainageFromJson(Map<String, dynamic> json) {
  return _WalletParrainage.fromJson(json);
}

/// @nodoc
mixin _$WalletParrainage {
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'taux_bonus', fromJson: jsonToDouble)
  double get tauxBonus => throw _privateConstructorUsedError;

  /// Serializes this WalletParrainage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletParrainage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletParrainageCopyWith<WalletParrainage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletParrainageCopyWith<$Res> {
  factory $WalletParrainageCopyWith(
          WalletParrainage value, $Res Function(WalletParrainage) then) =
      _$WalletParrainageCopyWithImpl<$Res, WalletParrainage>;
  @useResult
  $Res call(
      {String code,
      @JsonKey(name: 'taux_bonus', fromJson: jsonToDouble) double tauxBonus});
}

/// @nodoc
class _$WalletParrainageCopyWithImpl<$Res, $Val extends WalletParrainage>
    implements $WalletParrainageCopyWith<$Res> {
  _$WalletParrainageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletParrainage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? tauxBonus = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      tauxBonus: null == tauxBonus
          ? _value.tauxBonus
          : tauxBonus // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletParrainageImplCopyWith<$Res>
    implements $WalletParrainageCopyWith<$Res> {
  factory _$$WalletParrainageImplCopyWith(_$WalletParrainageImpl value,
          $Res Function(_$WalletParrainageImpl) then) =
      __$$WalletParrainageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      @JsonKey(name: 'taux_bonus', fromJson: jsonToDouble) double tauxBonus});
}

/// @nodoc
class __$$WalletParrainageImplCopyWithImpl<$Res>
    extends _$WalletParrainageCopyWithImpl<$Res, _$WalletParrainageImpl>
    implements _$$WalletParrainageImplCopyWith<$Res> {
  __$$WalletParrainageImplCopyWithImpl(_$WalletParrainageImpl _value,
      $Res Function(_$WalletParrainageImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletParrainage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? tauxBonus = null,
  }) {
    return _then(_$WalletParrainageImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      tauxBonus: null == tauxBonus
          ? _value.tauxBonus
          : tauxBonus // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletParrainageImpl implements _WalletParrainage {
  const _$WalletParrainageImpl(
      {required this.code,
      @JsonKey(name: 'taux_bonus', fromJson: jsonToDouble) this.tauxBonus = 0});

  factory _$WalletParrainageImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletParrainageImplFromJson(json);

  @override
  final String code;
  @override
  @JsonKey(name: 'taux_bonus', fromJson: jsonToDouble)
  final double tauxBonus;

  @override
  String toString() {
    return 'WalletParrainage(code: $code, tauxBonus: $tauxBonus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletParrainageImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.tauxBonus, tauxBonus) ||
                other.tauxBonus == tauxBonus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, tauxBonus);

  /// Create a copy of WalletParrainage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletParrainageImplCopyWith<_$WalletParrainageImpl> get copyWith =>
      __$$WalletParrainageImplCopyWithImpl<_$WalletParrainageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletParrainageImplToJson(
      this,
    );
  }
}

abstract class _WalletParrainage implements WalletParrainage {
  const factory _WalletParrainage(
      {required final String code,
      @JsonKey(name: 'taux_bonus', fromJson: jsonToDouble)
      final double tauxBonus}) = _$WalletParrainageImpl;

  factory _WalletParrainage.fromJson(Map<String, dynamic> json) =
      _$WalletParrainageImpl.fromJson;

  @override
  String get code;
  @override
  @JsonKey(name: 'taux_bonus', fromJson: jsonToDouble)
  double get tauxBonus;

  /// Create a copy of WalletParrainage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletParrainageImplCopyWith<_$WalletParrainageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WalletDepotHorsLigne _$WalletDepotHorsLigneFromJson(Map<String, dynamic> json) {
  return _WalletDepotHorsLigne.fromJson(json);
}

/// @nodoc
mixin _$WalletDepotHorsLigne {
  @JsonKey(name: 'numero_moncash')
  String? get numeroMoncash => throw _privateConstructorUsedError;
  @JsonKey(name: 'numero_natcash')
  String? get numeroNatcash => throw _privateConstructorUsedError;

  /// Serializes this WalletDepotHorsLigne to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletDepotHorsLigne
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletDepotHorsLigneCopyWith<WalletDepotHorsLigne> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletDepotHorsLigneCopyWith<$Res> {
  factory $WalletDepotHorsLigneCopyWith(WalletDepotHorsLigne value,
          $Res Function(WalletDepotHorsLigne) then) =
      _$WalletDepotHorsLigneCopyWithImpl<$Res, WalletDepotHorsLigne>;
  @useResult
  $Res call(
      {@JsonKey(name: 'numero_moncash') String? numeroMoncash,
      @JsonKey(name: 'numero_natcash') String? numeroNatcash});
}

/// @nodoc
class _$WalletDepotHorsLigneCopyWithImpl<$Res,
        $Val extends WalletDepotHorsLigne>
    implements $WalletDepotHorsLigneCopyWith<$Res> {
  _$WalletDepotHorsLigneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletDepotHorsLigne
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? numeroMoncash = freezed,
    Object? numeroNatcash = freezed,
  }) {
    return _then(_value.copyWith(
      numeroMoncash: freezed == numeroMoncash
          ? _value.numeroMoncash
          : numeroMoncash // ignore: cast_nullable_to_non_nullable
              as String?,
      numeroNatcash: freezed == numeroNatcash
          ? _value.numeroNatcash
          : numeroNatcash // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletDepotHorsLigneImplCopyWith<$Res>
    implements $WalletDepotHorsLigneCopyWith<$Res> {
  factory _$$WalletDepotHorsLigneImplCopyWith(_$WalletDepotHorsLigneImpl value,
          $Res Function(_$WalletDepotHorsLigneImpl) then) =
      __$$WalletDepotHorsLigneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'numero_moncash') String? numeroMoncash,
      @JsonKey(name: 'numero_natcash') String? numeroNatcash});
}

/// @nodoc
class __$$WalletDepotHorsLigneImplCopyWithImpl<$Res>
    extends _$WalletDepotHorsLigneCopyWithImpl<$Res, _$WalletDepotHorsLigneImpl>
    implements _$$WalletDepotHorsLigneImplCopyWith<$Res> {
  __$$WalletDepotHorsLigneImplCopyWithImpl(_$WalletDepotHorsLigneImpl _value,
      $Res Function(_$WalletDepotHorsLigneImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletDepotHorsLigne
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? numeroMoncash = freezed,
    Object? numeroNatcash = freezed,
  }) {
    return _then(_$WalletDepotHorsLigneImpl(
      numeroMoncash: freezed == numeroMoncash
          ? _value.numeroMoncash
          : numeroMoncash // ignore: cast_nullable_to_non_nullable
              as String?,
      numeroNatcash: freezed == numeroNatcash
          ? _value.numeroNatcash
          : numeroNatcash // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletDepotHorsLigneImpl implements _WalletDepotHorsLigne {
  const _$WalletDepotHorsLigneImpl(
      {@JsonKey(name: 'numero_moncash') this.numeroMoncash,
      @JsonKey(name: 'numero_natcash') this.numeroNatcash});

  factory _$WalletDepotHorsLigneImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletDepotHorsLigneImplFromJson(json);

  @override
  @JsonKey(name: 'numero_moncash')
  final String? numeroMoncash;
  @override
  @JsonKey(name: 'numero_natcash')
  final String? numeroNatcash;

  @override
  String toString() {
    return 'WalletDepotHorsLigne(numeroMoncash: $numeroMoncash, numeroNatcash: $numeroNatcash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletDepotHorsLigneImpl &&
            (identical(other.numeroMoncash, numeroMoncash) ||
                other.numeroMoncash == numeroMoncash) &&
            (identical(other.numeroNatcash, numeroNatcash) ||
                other.numeroNatcash == numeroNatcash));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, numeroMoncash, numeroNatcash);

  /// Create a copy of WalletDepotHorsLigne
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletDepotHorsLigneImplCopyWith<_$WalletDepotHorsLigneImpl>
      get copyWith =>
          __$$WalletDepotHorsLigneImplCopyWithImpl<_$WalletDepotHorsLigneImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletDepotHorsLigneImplToJson(
      this,
    );
  }
}

abstract class _WalletDepotHorsLigne implements WalletDepotHorsLigne {
  const factory _WalletDepotHorsLigne(
          {@JsonKey(name: 'numero_moncash') final String? numeroMoncash,
          @JsonKey(name: 'numero_natcash') final String? numeroNatcash}) =
      _$WalletDepotHorsLigneImpl;

  factory _WalletDepotHorsLigne.fromJson(Map<String, dynamic> json) =
      _$WalletDepotHorsLigneImpl.fromJson;

  @override
  @JsonKey(name: 'numero_moncash')
  String? get numeroMoncash;
  @override
  @JsonKey(name: 'numero_natcash')
  String? get numeroNatcash;

  /// Create a copy of WalletDepotHorsLigne
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletDepotHorsLigneImplCopyWith<_$WalletDepotHorsLigneImpl>
      get copyWith => throw _privateConstructorUsedError;
}

Wallet _$WalletFromJson(Map<String, dynamic> json) {
  return _Wallet.fromJson(json);
}

/// @nodoc
mixin _$Wallet {
  @JsonKey(fromJson: jsonToDouble)
  double get solde => throw _privateConstructorUsedError;
  String get devise => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  WalletCashback? get cashback =>
      throw _privateConstructorUsedError; // null si la fonctionnalité de parrainage est désactivée
  WalletParrainage? get parrainage => throw _privateConstructorUsedError;
  @JsonKey(name: 'depot_hors_ligne')
  WalletDepotHorsLigne? get depotHorsLigne =>
      throw _privateConstructorUsedError;

  /// Serializes this Wallet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletCopyWith<Wallet> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletCopyWith<$Res> {
  factory $WalletCopyWith(Wallet value, $Res Function(Wallet) then) =
      _$WalletCopyWithImpl<$Res, Wallet>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: jsonToDouble) double solde,
      String devise,
      @JsonKey(name: 'is_active') bool isActive,
      WalletCashback? cashback,
      WalletParrainage? parrainage,
      @JsonKey(name: 'depot_hors_ligne') WalletDepotHorsLigne? depotHorsLigne});

  $WalletCashbackCopyWith<$Res>? get cashback;
  $WalletParrainageCopyWith<$Res>? get parrainage;
  $WalletDepotHorsLigneCopyWith<$Res>? get depotHorsLigne;
}

/// @nodoc
class _$WalletCopyWithImpl<$Res, $Val extends Wallet>
    implements $WalletCopyWith<$Res> {
  _$WalletCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? solde = null,
    Object? devise = null,
    Object? isActive = null,
    Object? cashback = freezed,
    Object? parrainage = freezed,
    Object? depotHorsLigne = freezed,
  }) {
    return _then(_value.copyWith(
      solde: null == solde
          ? _value.solde
          : solde // ignore: cast_nullable_to_non_nullable
              as double,
      devise: null == devise
          ? _value.devise
          : devise // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      cashback: freezed == cashback
          ? _value.cashback
          : cashback // ignore: cast_nullable_to_non_nullable
              as WalletCashback?,
      parrainage: freezed == parrainage
          ? _value.parrainage
          : parrainage // ignore: cast_nullable_to_non_nullable
              as WalletParrainage?,
      depotHorsLigne: freezed == depotHorsLigne
          ? _value.depotHorsLigne
          : depotHorsLigne // ignore: cast_nullable_to_non_nullable
              as WalletDepotHorsLigne?,
    ) as $Val);
  }

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WalletCashbackCopyWith<$Res>? get cashback {
    if (_value.cashback == null) {
      return null;
    }

    return $WalletCashbackCopyWith<$Res>(_value.cashback!, (value) {
      return _then(_value.copyWith(cashback: value) as $Val);
    });
  }

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WalletParrainageCopyWith<$Res>? get parrainage {
    if (_value.parrainage == null) {
      return null;
    }

    return $WalletParrainageCopyWith<$Res>(_value.parrainage!, (value) {
      return _then(_value.copyWith(parrainage: value) as $Val);
    });
  }

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WalletDepotHorsLigneCopyWith<$Res>? get depotHorsLigne {
    if (_value.depotHorsLigne == null) {
      return null;
    }

    return $WalletDepotHorsLigneCopyWith<$Res>(_value.depotHorsLigne!, (value) {
      return _then(_value.copyWith(depotHorsLigne: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WalletImplCopyWith<$Res> implements $WalletCopyWith<$Res> {
  factory _$$WalletImplCopyWith(
          _$WalletImpl value, $Res Function(_$WalletImpl) then) =
      __$$WalletImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: jsonToDouble) double solde,
      String devise,
      @JsonKey(name: 'is_active') bool isActive,
      WalletCashback? cashback,
      WalletParrainage? parrainage,
      @JsonKey(name: 'depot_hors_ligne') WalletDepotHorsLigne? depotHorsLigne});

  @override
  $WalletCashbackCopyWith<$Res>? get cashback;
  @override
  $WalletParrainageCopyWith<$Res>? get parrainage;
  @override
  $WalletDepotHorsLigneCopyWith<$Res>? get depotHorsLigne;
}

/// @nodoc
class __$$WalletImplCopyWithImpl<$Res>
    extends _$WalletCopyWithImpl<$Res, _$WalletImpl>
    implements _$$WalletImplCopyWith<$Res> {
  __$$WalletImplCopyWithImpl(
      _$WalletImpl _value, $Res Function(_$WalletImpl) _then)
      : super(_value, _then);

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? solde = null,
    Object? devise = null,
    Object? isActive = null,
    Object? cashback = freezed,
    Object? parrainage = freezed,
    Object? depotHorsLigne = freezed,
  }) {
    return _then(_$WalletImpl(
      solde: null == solde
          ? _value.solde
          : solde // ignore: cast_nullable_to_non_nullable
              as double,
      devise: null == devise
          ? _value.devise
          : devise // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      cashback: freezed == cashback
          ? _value.cashback
          : cashback // ignore: cast_nullable_to_non_nullable
              as WalletCashback?,
      parrainage: freezed == parrainage
          ? _value.parrainage
          : parrainage // ignore: cast_nullable_to_non_nullable
              as WalletParrainage?,
      depotHorsLigne: freezed == depotHorsLigne
          ? _value.depotHorsLigne
          : depotHorsLigne // ignore: cast_nullable_to_non_nullable
              as WalletDepotHorsLigne?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletImpl implements _Wallet {
  const _$WalletImpl(
      {@JsonKey(fromJson: jsonToDouble) required this.solde,
      this.devise = 'HTG',
      @JsonKey(name: 'is_active') this.isActive = true,
      this.cashback,
      this.parrainage,
      @JsonKey(name: 'depot_hors_ligne') this.depotHorsLigne});

  factory _$WalletImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletImplFromJson(json);

  @override
  @JsonKey(fromJson: jsonToDouble)
  final double solde;
  @override
  @JsonKey()
  final String devise;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  final WalletCashback? cashback;
// null si la fonctionnalité de parrainage est désactivée
  @override
  final WalletParrainage? parrainage;
  @override
  @JsonKey(name: 'depot_hors_ligne')
  final WalletDepotHorsLigne? depotHorsLigne;

  @override
  String toString() {
    return 'Wallet(solde: $solde, devise: $devise, isActive: $isActive, cashback: $cashback, parrainage: $parrainage, depotHorsLigne: $depotHorsLigne)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletImpl &&
            (identical(other.solde, solde) || other.solde == solde) &&
            (identical(other.devise, devise) || other.devise == devise) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.cashback, cashback) ||
                other.cashback == cashback) &&
            (identical(other.parrainage, parrainage) ||
                other.parrainage == parrainage) &&
            (identical(other.depotHorsLigne, depotHorsLigne) ||
                other.depotHorsLigne == depotHorsLigne));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, solde, devise, isActive,
      cashback, parrainage, depotHorsLigne);

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletImplCopyWith<_$WalletImpl> get copyWith =>
      __$$WalletImplCopyWithImpl<_$WalletImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletImplToJson(
      this,
    );
  }
}

abstract class _Wallet implements Wallet {
  const factory _Wallet(
      {@JsonKey(fromJson: jsonToDouble) required final double solde,
      final String devise,
      @JsonKey(name: 'is_active') final bool isActive,
      final WalletCashback? cashback,
      final WalletParrainage? parrainage,
      @JsonKey(name: 'depot_hors_ligne')
      final WalletDepotHorsLigne? depotHorsLigne}) = _$WalletImpl;

  factory _Wallet.fromJson(Map<String, dynamic> json) = _$WalletImpl.fromJson;

  @override
  @JsonKey(fromJson: jsonToDouble)
  double get solde;
  @override
  String get devise;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  WalletCashback?
      get cashback; // null si la fonctionnalité de parrainage est désactivée
  @override
  WalletParrainage? get parrainage;
  @override
  @JsonKey(name: 'depot_hors_ligne')
  WalletDepotHorsLigne? get depotHorsLigne;

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletImplCopyWith<_$WalletImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
