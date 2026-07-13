// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_retrait.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WalletRetrait _$WalletRetraitFromJson(Map<String, dynamic> json) {
  return _WalletRetrait.fromJson(json);
}

/// @nodoc
mixin _$WalletRetrait {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: jsonToDouble)
  double get montant => throw _privateConstructorUsedError;
  String get canal => throw _privateConstructorUsedError;
  @JsonKey(name: 'canal_display')
  String get canalDisplay => throw _privateConstructorUsedError;
  @JsonKey(name: 'numero_telephone')
  String get numeroTelephone => throw _privateConstructorUsedError;
  String get statut => throw _privateConstructorUsedError;
  @JsonKey(name: 'statut_display')
  String get statutDisplay => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WalletRetrait to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletRetrait
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletRetraitCopyWith<WalletRetrait> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletRetraitCopyWith<$Res> {
  factory $WalletRetraitCopyWith(
          WalletRetrait value, $Res Function(WalletRetrait) then) =
      _$WalletRetraitCopyWithImpl<$Res, WalletRetrait>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(fromJson: jsonToDouble) double montant,
      String canal,
      @JsonKey(name: 'canal_display') String canalDisplay,
      @JsonKey(name: 'numero_telephone') String numeroTelephone,
      String statut,
      @JsonKey(name: 'statut_display') String statutDisplay,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class _$WalletRetraitCopyWithImpl<$Res, $Val extends WalletRetrait>
    implements $WalletRetraitCopyWith<$Res> {
  _$WalletRetraitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletRetrait
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? montant = null,
    Object? canal = null,
    Object? canalDisplay = null,
    Object? numeroTelephone = null,
    Object? statut = null,
    Object? statutDisplay = null,
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
      canal: null == canal
          ? _value.canal
          : canal // ignore: cast_nullable_to_non_nullable
              as String,
      canalDisplay: null == canalDisplay
          ? _value.canalDisplay
          : canalDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      numeroTelephone: null == numeroTelephone
          ? _value.numeroTelephone
          : numeroTelephone // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      statutDisplay: null == statutDisplay
          ? _value.statutDisplay
          : statutDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletRetraitImplCopyWith<$Res>
    implements $WalletRetraitCopyWith<$Res> {
  factory _$$WalletRetraitImplCopyWith(
          _$WalletRetraitImpl value, $Res Function(_$WalletRetraitImpl) then) =
      __$$WalletRetraitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(fromJson: jsonToDouble) double montant,
      String canal,
      @JsonKey(name: 'canal_display') String canalDisplay,
      @JsonKey(name: 'numero_telephone') String numeroTelephone,
      String statut,
      @JsonKey(name: 'statut_display') String statutDisplay,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class __$$WalletRetraitImplCopyWithImpl<$Res>
    extends _$WalletRetraitCopyWithImpl<$Res, _$WalletRetraitImpl>
    implements _$$WalletRetraitImplCopyWith<$Res> {
  __$$WalletRetraitImplCopyWithImpl(
      _$WalletRetraitImpl _value, $Res Function(_$WalletRetraitImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletRetrait
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? montant = null,
    Object? canal = null,
    Object? canalDisplay = null,
    Object? numeroTelephone = null,
    Object? statut = null,
    Object? statutDisplay = null,
    Object? createdAt = null,
  }) {
    return _then(_$WalletRetraitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      canal: null == canal
          ? _value.canal
          : canal // ignore: cast_nullable_to_non_nullable
              as String,
      canalDisplay: null == canalDisplay
          ? _value.canalDisplay
          : canalDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      numeroTelephone: null == numeroTelephone
          ? _value.numeroTelephone
          : numeroTelephone // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      statutDisplay: null == statutDisplay
          ? _value.statutDisplay
          : statutDisplay // ignore: cast_nullable_to_non_nullable
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
class _$WalletRetraitImpl implements _WalletRetrait {
  const _$WalletRetraitImpl(
      {required this.id,
      @JsonKey(fromJson: jsonToDouble) required this.montant,
      required this.canal,
      @JsonKey(name: 'canal_display') this.canalDisplay = '',
      @JsonKey(name: 'numero_telephone') required this.numeroTelephone,
      required this.statut,
      @JsonKey(name: 'statut_display') this.statutDisplay = '',
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$WalletRetraitImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletRetraitImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(fromJson: jsonToDouble)
  final double montant;
  @override
  final String canal;
  @override
  @JsonKey(name: 'canal_display')
  final String canalDisplay;
  @override
  @JsonKey(name: 'numero_telephone')
  final String numeroTelephone;
  @override
  final String statut;
  @override
  @JsonKey(name: 'statut_display')
  final String statutDisplay;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'WalletRetrait(id: $id, montant: $montant, canal: $canal, canalDisplay: $canalDisplay, numeroTelephone: $numeroTelephone, statut: $statut, statutDisplay: $statutDisplay, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletRetraitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.montant, montant) || other.montant == montant) &&
            (identical(other.canal, canal) || other.canal == canal) &&
            (identical(other.canalDisplay, canalDisplay) ||
                other.canalDisplay == canalDisplay) &&
            (identical(other.numeroTelephone, numeroTelephone) ||
                other.numeroTelephone == numeroTelephone) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.statutDisplay, statutDisplay) ||
                other.statutDisplay == statutDisplay) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, montant, canal, canalDisplay,
      numeroTelephone, statut, statutDisplay, createdAt);

  /// Create a copy of WalletRetrait
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletRetraitImplCopyWith<_$WalletRetraitImpl> get copyWith =>
      __$$WalletRetraitImplCopyWithImpl<_$WalletRetraitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletRetraitImplToJson(
      this,
    );
  }
}

abstract class _WalletRetrait implements WalletRetrait {
  const factory _WalletRetrait(
      {required final int id,
      @JsonKey(fromJson: jsonToDouble) required final double montant,
      required final String canal,
      @JsonKey(name: 'canal_display') final String canalDisplay,
      @JsonKey(name: 'numero_telephone') required final String numeroTelephone,
      required final String statut,
      @JsonKey(name: 'statut_display') final String statutDisplay,
      @JsonKey(name: 'created_at')
      required final String createdAt}) = _$WalletRetraitImpl;

  factory _WalletRetrait.fromJson(Map<String, dynamic> json) =
      _$WalletRetraitImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(fromJson: jsonToDouble)
  double get montant;
  @override
  String get canal;
  @override
  @JsonKey(name: 'canal_display')
  String get canalDisplay;
  @override
  @JsonKey(name: 'numero_telephone')
  String get numeroTelephone;
  @override
  String get statut;
  @override
  @JsonKey(name: 'statut_display')
  String get statutDisplay;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of WalletRetrait
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletRetraitImplCopyWith<_$WalletRetraitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
