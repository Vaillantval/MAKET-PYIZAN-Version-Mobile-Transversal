// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pos_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PosItem _$PosItemFromJson(Map<String, dynamic> json) {
  return _PosItem.fromJson(json);
}

/// @nodoc
mixin _$PosItem {
  @JsonKey(name: 'produit_id')
  int get produitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'nom_produit')
  String get nomProduit => throw _privateConstructorUsedError;
  @JsonKey(name: 'lot_id')
  int? get lotId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: jsonToDouble)
  double get quantite => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
  double get prixUnitaire => throw _privateConstructorUsedError;
  @JsonKey(name: 'sous_total', fromJson: jsonToDouble)
  double get sousTotal => throw _privateConstructorUsedError;

  /// Serializes this PosItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosItemCopyWith<PosItem> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosItemCopyWith<$Res> {
  factory $PosItemCopyWith(PosItem value, $Res Function(PosItem) then) =
      _$PosItemCopyWithImpl<$Res, PosItem>;
  @useResult
  $Res call(
      {@JsonKey(name: 'produit_id') int produitId,
      @JsonKey(name: 'nom_produit') String nomProduit,
      @JsonKey(name: 'lot_id') int? lotId,
      @JsonKey(fromJson: jsonToDouble) double quantite,
      @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
      double prixUnitaire,
      @JsonKey(name: 'sous_total', fromJson: jsonToDouble) double sousTotal});
}

/// @nodoc
class _$PosItemCopyWithImpl<$Res, $Val extends PosItem>
    implements $PosItemCopyWith<$Res> {
  _$PosItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? produitId = null,
    Object? nomProduit = null,
    Object? lotId = freezed,
    Object? quantite = null,
    Object? prixUnitaire = null,
    Object? sousTotal = null,
  }) {
    return _then(_value.copyWith(
      produitId: null == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as int,
      nomProduit: null == nomProduit
          ? _value.nomProduit
          : nomProduit // ignore: cast_nullable_to_non_nullable
              as String,
      lotId: freezed == lotId
          ? _value.lotId
          : lotId // ignore: cast_nullable_to_non_nullable
              as int?,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as double,
      prixUnitaire: null == prixUnitaire
          ? _value.prixUnitaire
          : prixUnitaire // ignore: cast_nullable_to_non_nullable
              as double,
      sousTotal: null == sousTotal
          ? _value.sousTotal
          : sousTotal // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PosItemImplCopyWith<$Res> implements $PosItemCopyWith<$Res> {
  factory _$$PosItemImplCopyWith(
          _$PosItemImpl value, $Res Function(_$PosItemImpl) then) =
      __$$PosItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'produit_id') int produitId,
      @JsonKey(name: 'nom_produit') String nomProduit,
      @JsonKey(name: 'lot_id') int? lotId,
      @JsonKey(fromJson: jsonToDouble) double quantite,
      @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
      double prixUnitaire,
      @JsonKey(name: 'sous_total', fromJson: jsonToDouble) double sousTotal});
}

/// @nodoc
class __$$PosItemImplCopyWithImpl<$Res>
    extends _$PosItemCopyWithImpl<$Res, _$PosItemImpl>
    implements _$$PosItemImplCopyWith<$Res> {
  __$$PosItemImplCopyWithImpl(
      _$PosItemImpl _value, $Res Function(_$PosItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of PosItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? produitId = null,
    Object? nomProduit = null,
    Object? lotId = freezed,
    Object? quantite = null,
    Object? prixUnitaire = null,
    Object? sousTotal = null,
  }) {
    return _then(_$PosItemImpl(
      produitId: null == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as int,
      nomProduit: null == nomProduit
          ? _value.nomProduit
          : nomProduit // ignore: cast_nullable_to_non_nullable
              as String,
      lotId: freezed == lotId
          ? _value.lotId
          : lotId // ignore: cast_nullable_to_non_nullable
              as int?,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as double,
      prixUnitaire: null == prixUnitaire
          ? _value.prixUnitaire
          : prixUnitaire // ignore: cast_nullable_to_non_nullable
              as double,
      sousTotal: null == sousTotal
          ? _value.sousTotal
          : sousTotal // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PosItemImpl implements _PosItem {
  const _$PosItemImpl(
      {@JsonKey(name: 'produit_id') required this.produitId,
      @JsonKey(name: 'nom_produit') this.nomProduit = '',
      @JsonKey(name: 'lot_id') this.lotId,
      @JsonKey(fromJson: jsonToDouble) required this.quantite,
      @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
      required this.prixUnitaire,
      @JsonKey(name: 'sous_total', fromJson: jsonToDouble) this.sousTotal = 0});

  factory _$PosItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosItemImplFromJson(json);

  @override
  @JsonKey(name: 'produit_id')
  final int produitId;
  @override
  @JsonKey(name: 'nom_produit')
  final String nomProduit;
  @override
  @JsonKey(name: 'lot_id')
  final int? lotId;
  @override
  @JsonKey(fromJson: jsonToDouble)
  final double quantite;
  @override
  @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
  final double prixUnitaire;
  @override
  @JsonKey(name: 'sous_total', fromJson: jsonToDouble)
  final double sousTotal;

  @override
  String toString() {
    return 'PosItem(produitId: $produitId, nomProduit: $nomProduit, lotId: $lotId, quantite: $quantite, prixUnitaire: $prixUnitaire, sousTotal: $sousTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosItemImpl &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.nomProduit, nomProduit) ||
                other.nomProduit == nomProduit) &&
            (identical(other.lotId, lotId) || other.lotId == lotId) &&
            (identical(other.quantite, quantite) ||
                other.quantite == quantite) &&
            (identical(other.prixUnitaire, prixUnitaire) ||
                other.prixUnitaire == prixUnitaire) &&
            (identical(other.sousTotal, sousTotal) ||
                other.sousTotal == sousTotal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, produitId, nomProduit, lotId,
      quantite, prixUnitaire, sousTotal);

  /// Create a copy of PosItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosItemImplCopyWith<_$PosItemImpl> get copyWith =>
      __$$PosItemImplCopyWithImpl<_$PosItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PosItemImplToJson(
      this,
    );
  }
}

abstract class _PosItem implements PosItem {
  const factory _PosItem(
      {@JsonKey(name: 'produit_id') required final int produitId,
      @JsonKey(name: 'nom_produit') final String nomProduit,
      @JsonKey(name: 'lot_id') final int? lotId,
      @JsonKey(fromJson: jsonToDouble) required final double quantite,
      @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
      required final double prixUnitaire,
      @JsonKey(name: 'sous_total', fromJson: jsonToDouble)
      final double sousTotal}) = _$PosItemImpl;

  factory _PosItem.fromJson(Map<String, dynamic> json) = _$PosItemImpl.fromJson;

  @override
  @JsonKey(name: 'produit_id')
  int get produitId;
  @override
  @JsonKey(name: 'nom_produit')
  String get nomProduit;
  @override
  @JsonKey(name: 'lot_id')
  int? get lotId;
  @override
  @JsonKey(fromJson: jsonToDouble)
  double get quantite;
  @override
  @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
  double get prixUnitaire;
  @override
  @JsonKey(name: 'sous_total', fromJson: jsonToDouble)
  double get sousTotal;

  /// Create a copy of PosItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosItemImplCopyWith<_$PosItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
