// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) {
  return _WalletTransaction.fromJson(json);
}

/// @nodoc
mixin _$WalletTransaction {
  int get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'type_display')
  String get typeDisplay => throw _privateConstructorUsedError;
  @JsonKey(fromJson: jsonToDouble)
  double get montant => throw _privateConstructorUsedError;
  @JsonKey(name: 'solde_apres', fromJson: jsonToDouble)
  double get soldeApres => throw _privateConstructorUsedError;
  @JsonKey(name: 'commande_numero')
  String? get commandeNumero => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WalletTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletTransactionCopyWith<WalletTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletTransactionCopyWith<$Res> {
  factory $WalletTransactionCopyWith(
          WalletTransaction value, $Res Function(WalletTransaction) then) =
      _$WalletTransactionCopyWithImpl<$Res, WalletTransaction>;
  @useResult
  $Res call(
      {int id,
      String type,
      @JsonKey(name: 'type_display') String typeDisplay,
      @JsonKey(fromJson: jsonToDouble) double montant,
      @JsonKey(name: 'solde_apres', fromJson: jsonToDouble) double soldeApres,
      @JsonKey(name: 'commande_numero') String? commandeNumero,
      String description,
      String reference,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class _$WalletTransactionCopyWithImpl<$Res, $Val extends WalletTransaction>
    implements $WalletTransactionCopyWith<$Res> {
  _$WalletTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? typeDisplay = null,
    Object? montant = null,
    Object? soldeApres = null,
    Object? commandeNumero = freezed,
    Object? description = null,
    Object? reference = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      typeDisplay: null == typeDisplay
          ? _value.typeDisplay
          : typeDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      soldeApres: null == soldeApres
          ? _value.soldeApres
          : soldeApres // ignore: cast_nullable_to_non_nullable
              as double,
      commandeNumero: freezed == commandeNumero
          ? _value.commandeNumero
          : commandeNumero // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
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
abstract class _$$WalletTransactionImplCopyWith<$Res>
    implements $WalletTransactionCopyWith<$Res> {
  factory _$$WalletTransactionImplCopyWith(_$WalletTransactionImpl value,
          $Res Function(_$WalletTransactionImpl) then) =
      __$$WalletTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String type,
      @JsonKey(name: 'type_display') String typeDisplay,
      @JsonKey(fromJson: jsonToDouble) double montant,
      @JsonKey(name: 'solde_apres', fromJson: jsonToDouble) double soldeApres,
      @JsonKey(name: 'commande_numero') String? commandeNumero,
      String description,
      String reference,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class __$$WalletTransactionImplCopyWithImpl<$Res>
    extends _$WalletTransactionCopyWithImpl<$Res, _$WalletTransactionImpl>
    implements _$$WalletTransactionImplCopyWith<$Res> {
  __$$WalletTransactionImplCopyWithImpl(_$WalletTransactionImpl _value,
      $Res Function(_$WalletTransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? typeDisplay = null,
    Object? montant = null,
    Object? soldeApres = null,
    Object? commandeNumero = freezed,
    Object? description = null,
    Object? reference = null,
    Object? createdAt = null,
  }) {
    return _then(_$WalletTransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      typeDisplay: null == typeDisplay
          ? _value.typeDisplay
          : typeDisplay // ignore: cast_nullable_to_non_nullable
              as String,
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      soldeApres: null == soldeApres
          ? _value.soldeApres
          : soldeApres // ignore: cast_nullable_to_non_nullable
              as double,
      commandeNumero: freezed == commandeNumero
          ? _value.commandeNumero
          : commandeNumero // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
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
class _$WalletTransactionImpl implements _WalletTransaction {
  const _$WalletTransactionImpl(
      {required this.id,
      required this.type,
      @JsonKey(name: 'type_display') this.typeDisplay = '',
      @JsonKey(fromJson: jsonToDouble) required this.montant,
      @JsonKey(name: 'solde_apres', fromJson: jsonToDouble)
      required this.soldeApres,
      @JsonKey(name: 'commande_numero') this.commandeNumero,
      this.description = '',
      this.reference = '',
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$WalletTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletTransactionImplFromJson(json);

  @override
  final int id;
  @override
  final String type;
  @override
  @JsonKey(name: 'type_display')
  final String typeDisplay;
  @override
  @JsonKey(fromJson: jsonToDouble)
  final double montant;
  @override
  @JsonKey(name: 'solde_apres', fromJson: jsonToDouble)
  final double soldeApres;
  @override
  @JsonKey(name: 'commande_numero')
  final String? commandeNumero;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String reference;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'WalletTransaction(id: $id, type: $type, typeDisplay: $typeDisplay, montant: $montant, soldeApres: $soldeApres, commandeNumero: $commandeNumero, description: $description, reference: $reference, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.typeDisplay, typeDisplay) ||
                other.typeDisplay == typeDisplay) &&
            (identical(other.montant, montant) || other.montant == montant) &&
            (identical(other.soldeApres, soldeApres) ||
                other.soldeApres == soldeApres) &&
            (identical(other.commandeNumero, commandeNumero) ||
                other.commandeNumero == commandeNumero) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, typeDisplay, montant,
      soldeApres, commandeNumero, description, reference, createdAt);

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletTransactionImplCopyWith<_$WalletTransactionImpl> get copyWith =>
      __$$WalletTransactionImplCopyWithImpl<_$WalletTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletTransactionImplToJson(
      this,
    );
  }
}

abstract class _WalletTransaction implements WalletTransaction {
  const factory _WalletTransaction(
          {required final int id,
          required final String type,
          @JsonKey(name: 'type_display') final String typeDisplay,
          @JsonKey(fromJson: jsonToDouble) required final double montant,
          @JsonKey(name: 'solde_apres', fromJson: jsonToDouble)
          required final double soldeApres,
          @JsonKey(name: 'commande_numero') final String? commandeNumero,
          final String description,
          final String reference,
          @JsonKey(name: 'created_at') required final String createdAt}) =
      _$WalletTransactionImpl;

  factory _WalletTransaction.fromJson(Map<String, dynamic> json) =
      _$WalletTransactionImpl.fromJson;

  @override
  int get id;
  @override
  String get type;
  @override
  @JsonKey(name: 'type_display')
  String get typeDisplay;
  @override
  @JsonKey(fromJson: jsonToDouble)
  double get montant;
  @override
  @JsonKey(name: 'solde_apres', fromJson: jsonToDouble)
  double get soldeApres;
  @override
  @JsonKey(name: 'commande_numero')
  String? get commandeNumero;
  @override
  String get description;
  @override
  String get reference;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletTransactionImplCopyWith<_$WalletTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
