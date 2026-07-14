// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pos_sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PosSale _$PosSaleFromJson(Map<String, dynamic> json) {
  return _PosSale.fromJson(json);
}

/// @nodoc
mixin _$PosSale {
  @JsonKey(name: 'idempotency_key')
  String get idempotencyKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'numero_vente')
  String? get numeroVente => throw _privateConstructorUsedError;
  List<PosItem> get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'montant_total', fromJson: jsonToDouble)
  double get montantTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'methode_paiement')
  String get methodePaiement => throw _privateConstructorUsedError;
  @JsonKey(name: 'montant_wallet', fromJson: jsonToDouble)
  double get montantWallet => throw _privateConstructorUsedError;
  String get statut => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendue_le')
  String get vendueLe =>
      throw _privateConstructorUsedError; // Statut LOCAL de synchronisation : enAttente | synchronisee | rejetee
  String get syncStatus =>
      throw _privateConstructorUsedError; // Champs LOCAUX renseignés par la réponse de POST /api/pos/sync/
  @JsonKey(name: 'stock_conflict')
  bool get stockConflict => throw _privateConstructorUsedError;
  @JsonKey(name: 'erreur_sync')
  String? get erreurSync => throw _privateConstructorUsedError;

  /// Serializes this PosSale to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosSale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosSaleCopyWith<PosSale> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosSaleCopyWith<$Res> {
  factory $PosSaleCopyWith(PosSale value, $Res Function(PosSale) then) =
      _$PosSaleCopyWithImpl<$Res, PosSale>;
  @useResult
  $Res call(
      {@JsonKey(name: 'idempotency_key') String idempotencyKey,
      @JsonKey(name: 'numero_vente') String? numeroVente,
      List<PosItem> items,
      @JsonKey(name: 'montant_total', fromJson: jsonToDouble)
      double montantTotal,
      @JsonKey(name: 'methode_paiement') String methodePaiement,
      @JsonKey(name: 'montant_wallet', fromJson: jsonToDouble)
      double montantWallet,
      String statut,
      @JsonKey(name: 'vendue_le') String vendueLe,
      String syncStatus,
      @JsonKey(name: 'stock_conflict') bool stockConflict,
      @JsonKey(name: 'erreur_sync') String? erreurSync});
}

/// @nodoc
class _$PosSaleCopyWithImpl<$Res, $Val extends PosSale>
    implements $PosSaleCopyWith<$Res> {
  _$PosSaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosSale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idempotencyKey = null,
    Object? numeroVente = freezed,
    Object? items = null,
    Object? montantTotal = null,
    Object? methodePaiement = null,
    Object? montantWallet = null,
    Object? statut = null,
    Object? vendueLe = null,
    Object? syncStatus = null,
    Object? stockConflict = null,
    Object? erreurSync = freezed,
  }) {
    return _then(_value.copyWith(
      idempotencyKey: null == idempotencyKey
          ? _value.idempotencyKey
          : idempotencyKey // ignore: cast_nullable_to_non_nullable
              as String,
      numeroVente: freezed == numeroVente
          ? _value.numeroVente
          : numeroVente // ignore: cast_nullable_to_non_nullable
              as String?,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PosItem>,
      montantTotal: null == montantTotal
          ? _value.montantTotal
          : montantTotal // ignore: cast_nullable_to_non_nullable
              as double,
      methodePaiement: null == methodePaiement
          ? _value.methodePaiement
          : methodePaiement // ignore: cast_nullable_to_non_nullable
              as String,
      montantWallet: null == montantWallet
          ? _value.montantWallet
          : montantWallet // ignore: cast_nullable_to_non_nullable
              as double,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      vendueLe: null == vendueLe
          ? _value.vendueLe
          : vendueLe // ignore: cast_nullable_to_non_nullable
              as String,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
      stockConflict: null == stockConflict
          ? _value.stockConflict
          : stockConflict // ignore: cast_nullable_to_non_nullable
              as bool,
      erreurSync: freezed == erreurSync
          ? _value.erreurSync
          : erreurSync // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PosSaleImplCopyWith<$Res> implements $PosSaleCopyWith<$Res> {
  factory _$$PosSaleImplCopyWith(
          _$PosSaleImpl value, $Res Function(_$PosSaleImpl) then) =
      __$$PosSaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'idempotency_key') String idempotencyKey,
      @JsonKey(name: 'numero_vente') String? numeroVente,
      List<PosItem> items,
      @JsonKey(name: 'montant_total', fromJson: jsonToDouble)
      double montantTotal,
      @JsonKey(name: 'methode_paiement') String methodePaiement,
      @JsonKey(name: 'montant_wallet', fromJson: jsonToDouble)
      double montantWallet,
      String statut,
      @JsonKey(name: 'vendue_le') String vendueLe,
      String syncStatus,
      @JsonKey(name: 'stock_conflict') bool stockConflict,
      @JsonKey(name: 'erreur_sync') String? erreurSync});
}

/// @nodoc
class __$$PosSaleImplCopyWithImpl<$Res>
    extends _$PosSaleCopyWithImpl<$Res, _$PosSaleImpl>
    implements _$$PosSaleImplCopyWith<$Res> {
  __$$PosSaleImplCopyWithImpl(
      _$PosSaleImpl _value, $Res Function(_$PosSaleImpl) _then)
      : super(_value, _then);

  /// Create a copy of PosSale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idempotencyKey = null,
    Object? numeroVente = freezed,
    Object? items = null,
    Object? montantTotal = null,
    Object? methodePaiement = null,
    Object? montantWallet = null,
    Object? statut = null,
    Object? vendueLe = null,
    Object? syncStatus = null,
    Object? stockConflict = null,
    Object? erreurSync = freezed,
  }) {
    return _then(_$PosSaleImpl(
      idempotencyKey: null == idempotencyKey
          ? _value.idempotencyKey
          : idempotencyKey // ignore: cast_nullable_to_non_nullable
              as String,
      numeroVente: freezed == numeroVente
          ? _value.numeroVente
          : numeroVente // ignore: cast_nullable_to_non_nullable
              as String?,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PosItem>,
      montantTotal: null == montantTotal
          ? _value.montantTotal
          : montantTotal // ignore: cast_nullable_to_non_nullable
              as double,
      methodePaiement: null == methodePaiement
          ? _value.methodePaiement
          : methodePaiement // ignore: cast_nullable_to_non_nullable
              as String,
      montantWallet: null == montantWallet
          ? _value.montantWallet
          : montantWallet // ignore: cast_nullable_to_non_nullable
              as double,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      vendueLe: null == vendueLe
          ? _value.vendueLe
          : vendueLe // ignore: cast_nullable_to_non_nullable
              as String,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
      stockConflict: null == stockConflict
          ? _value.stockConflict
          : stockConflict // ignore: cast_nullable_to_non_nullable
              as bool,
      erreurSync: freezed == erreurSync
          ? _value.erreurSync
          : erreurSync // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PosSaleImpl implements _PosSale {
  const _$PosSaleImpl(
      {@JsonKey(name: 'idempotency_key') required this.idempotencyKey,
      @JsonKey(name: 'numero_vente') this.numeroVente,
      final List<PosItem> items = const [],
      @JsonKey(name: 'montant_total', fromJson: jsonToDouble)
      required this.montantTotal,
      @JsonKey(name: 'methode_paiement') this.methodePaiement = 'cash',
      @JsonKey(name: 'montant_wallet', fromJson: jsonToDouble)
      this.montantWallet = 0,
      this.statut = 'en_attente',
      @JsonKey(name: 'vendue_le') required this.vendueLe,
      this.syncStatus = 'enAttente',
      @JsonKey(name: 'stock_conflict') this.stockConflict = false,
      @JsonKey(name: 'erreur_sync') this.erreurSync})
      : _items = items;

  factory _$PosSaleImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosSaleImplFromJson(json);

  @override
  @JsonKey(name: 'idempotency_key')
  final String idempotencyKey;
  @override
  @JsonKey(name: 'numero_vente')
  final String? numeroVente;
  final List<PosItem> _items;
  @override
  @JsonKey()
  List<PosItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey(name: 'montant_total', fromJson: jsonToDouble)
  final double montantTotal;
  @override
  @JsonKey(name: 'methode_paiement')
  final String methodePaiement;
  @override
  @JsonKey(name: 'montant_wallet', fromJson: jsonToDouble)
  final double montantWallet;
  @override
  @JsonKey()
  final String statut;
  @override
  @JsonKey(name: 'vendue_le')
  final String vendueLe;
// Statut LOCAL de synchronisation : enAttente | synchronisee | rejetee
  @override
  @JsonKey()
  final String syncStatus;
// Champs LOCAUX renseignés par la réponse de POST /api/pos/sync/
  @override
  @JsonKey(name: 'stock_conflict')
  final bool stockConflict;
  @override
  @JsonKey(name: 'erreur_sync')
  final String? erreurSync;

  @override
  String toString() {
    return 'PosSale(idempotencyKey: $idempotencyKey, numeroVente: $numeroVente, items: $items, montantTotal: $montantTotal, methodePaiement: $methodePaiement, montantWallet: $montantWallet, statut: $statut, vendueLe: $vendueLe, syncStatus: $syncStatus, stockConflict: $stockConflict, erreurSync: $erreurSync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosSaleImpl &&
            (identical(other.idempotencyKey, idempotencyKey) ||
                other.idempotencyKey == idempotencyKey) &&
            (identical(other.numeroVente, numeroVente) ||
                other.numeroVente == numeroVente) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.montantTotal, montantTotal) ||
                other.montantTotal == montantTotal) &&
            (identical(other.methodePaiement, methodePaiement) ||
                other.methodePaiement == methodePaiement) &&
            (identical(other.montantWallet, montantWallet) ||
                other.montantWallet == montantWallet) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.vendueLe, vendueLe) ||
                other.vendueLe == vendueLe) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.stockConflict, stockConflict) ||
                other.stockConflict == stockConflict) &&
            (identical(other.erreurSync, erreurSync) ||
                other.erreurSync == erreurSync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      idempotencyKey,
      numeroVente,
      const DeepCollectionEquality().hash(_items),
      montantTotal,
      methodePaiement,
      montantWallet,
      statut,
      vendueLe,
      syncStatus,
      stockConflict,
      erreurSync);

  /// Create a copy of PosSale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosSaleImplCopyWith<_$PosSaleImpl> get copyWith =>
      __$$PosSaleImplCopyWithImpl<_$PosSaleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PosSaleImplToJson(
      this,
    );
  }
}

abstract class _PosSale implements PosSale {
  const factory _PosSale(
      {@JsonKey(name: 'idempotency_key') required final String idempotencyKey,
      @JsonKey(name: 'numero_vente') final String? numeroVente,
      final List<PosItem> items,
      @JsonKey(name: 'montant_total', fromJson: jsonToDouble)
      required final double montantTotal,
      @JsonKey(name: 'methode_paiement') final String methodePaiement,
      @JsonKey(name: 'montant_wallet', fromJson: jsonToDouble)
      final double montantWallet,
      final String statut,
      @JsonKey(name: 'vendue_le') required final String vendueLe,
      final String syncStatus,
      @JsonKey(name: 'stock_conflict') final bool stockConflict,
      @JsonKey(name: 'erreur_sync') final String? erreurSync}) = _$PosSaleImpl;

  factory _PosSale.fromJson(Map<String, dynamic> json) = _$PosSaleImpl.fromJson;

  @override
  @JsonKey(name: 'idempotency_key')
  String get idempotencyKey;
  @override
  @JsonKey(name: 'numero_vente')
  String? get numeroVente;
  @override
  List<PosItem> get items;
  @override
  @JsonKey(name: 'montant_total', fromJson: jsonToDouble)
  double get montantTotal;
  @override
  @JsonKey(name: 'methode_paiement')
  String get methodePaiement;
  @override
  @JsonKey(name: 'montant_wallet', fromJson: jsonToDouble)
  double get montantWallet;
  @override
  String get statut;
  @override
  @JsonKey(name: 'vendue_le')
  String
      get vendueLe; // Statut LOCAL de synchronisation : enAttente | synchronisee | rejetee
  @override
  String
      get syncStatus; // Champs LOCAUX renseignés par la réponse de POST /api/pos/sync/
  @override
  @JsonKey(name: 'stock_conflict')
  bool get stockConflict;
  @override
  @JsonKey(name: 'erreur_sync')
  String? get erreurSync;

  /// Create a copy of PosSale
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosSaleImplCopyWith<_$PosSaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
