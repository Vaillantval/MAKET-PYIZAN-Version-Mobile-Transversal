// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pos_produit_catalogue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PosLot _$PosLotFromJson(Map<String, dynamic> json) {
  return _PosLot.fromJson(json);
}

/// @nodoc
mixin _$PosLot {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'code_barres')
  String? get codeBarres => throw _privateConstructorUsedError;
  @JsonKey(name: 'quantite_actuelle')
  double get quantiteActuelle => throw _privateConstructorUsedError;

  /// Serializes this PosLot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosLot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosLotCopyWith<PosLot> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosLotCopyWith<$Res> {
  factory $PosLotCopyWith(PosLot value, $Res Function(PosLot) then) =
      _$PosLotCopyWithImpl<$Res, PosLot>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'code_barres') String? codeBarres,
      @JsonKey(name: 'quantite_actuelle') double quantiteActuelle});
}

/// @nodoc
class _$PosLotCopyWithImpl<$Res, $Val extends PosLot>
    implements $PosLotCopyWith<$Res> {
  _$PosLotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosLot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codeBarres = freezed,
    Object? quantiteActuelle = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      codeBarres: freezed == codeBarres
          ? _value.codeBarres
          : codeBarres // ignore: cast_nullable_to_non_nullable
              as String?,
      quantiteActuelle: null == quantiteActuelle
          ? _value.quantiteActuelle
          : quantiteActuelle // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PosLotImplCopyWith<$Res> implements $PosLotCopyWith<$Res> {
  factory _$$PosLotImplCopyWith(
          _$PosLotImpl value, $Res Function(_$PosLotImpl) then) =
      __$$PosLotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'code_barres') String? codeBarres,
      @JsonKey(name: 'quantite_actuelle') double quantiteActuelle});
}

/// @nodoc
class __$$PosLotImplCopyWithImpl<$Res>
    extends _$PosLotCopyWithImpl<$Res, _$PosLotImpl>
    implements _$$PosLotImplCopyWith<$Res> {
  __$$PosLotImplCopyWithImpl(
      _$PosLotImpl _value, $Res Function(_$PosLotImpl) _then)
      : super(_value, _then);

  /// Create a copy of PosLot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codeBarres = freezed,
    Object? quantiteActuelle = null,
  }) {
    return _then(_$PosLotImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      codeBarres: freezed == codeBarres
          ? _value.codeBarres
          : codeBarres // ignore: cast_nullable_to_non_nullable
              as String?,
      quantiteActuelle: null == quantiteActuelle
          ? _value.quantiteActuelle
          : quantiteActuelle // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PosLotImpl implements _PosLot {
  const _$PosLotImpl(
      {required this.id,
      @JsonKey(name: 'code_barres') this.codeBarres,
      @JsonKey(name: 'quantite_actuelle') this.quantiteActuelle = 0});

  factory _$PosLotImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosLotImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'code_barres')
  final String? codeBarres;
  @override
  @JsonKey(name: 'quantite_actuelle')
  final double quantiteActuelle;

  @override
  String toString() {
    return 'PosLot(id: $id, codeBarres: $codeBarres, quantiteActuelle: $quantiteActuelle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosLotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codeBarres, codeBarres) ||
                other.codeBarres == codeBarres) &&
            (identical(other.quantiteActuelle, quantiteActuelle) ||
                other.quantiteActuelle == quantiteActuelle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, codeBarres, quantiteActuelle);

  /// Create a copy of PosLot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosLotImplCopyWith<_$PosLotImpl> get copyWith =>
      __$$PosLotImplCopyWithImpl<_$PosLotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PosLotImplToJson(
      this,
    );
  }
}

abstract class _PosLot implements PosLot {
  const factory _PosLot(
          {required final int id,
          @JsonKey(name: 'code_barres') final String? codeBarres,
          @JsonKey(name: 'quantite_actuelle') final double quantiteActuelle}) =
      _$PosLotImpl;

  factory _PosLot.fromJson(Map<String, dynamic> json) = _$PosLotImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'code_barres')
  String? get codeBarres;
  @override
  @JsonKey(name: 'quantite_actuelle')
  double get quantiteActuelle;

  /// Create a copy of PosLot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosLotImplCopyWith<_$PosLotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PosProduitCatalogue _$PosProduitCatalogueFromJson(Map<String, dynamic> json) {
  return _PosProduitCatalogue.fromJson(json);
}

/// @nodoc
mixin _$PosProduitCatalogue {
  int get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_detail')
  double get prixDetail => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_gros')
  double? get prixGros => throw _privateConstructorUsedError;
  String get categorie => throw _privateConstructorUsedError;
  List<PosLot> get lots => throw _privateConstructorUsedError;

  /// Serializes this PosProduitCatalogue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosProduitCatalogue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosProduitCatalogueCopyWith<PosProduitCatalogue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosProduitCatalogueCopyWith<$Res> {
  factory $PosProduitCatalogueCopyWith(
          PosProduitCatalogue value, $Res Function(PosProduitCatalogue) then) =
      _$PosProduitCatalogueCopyWithImpl<$Res, PosProduitCatalogue>;
  @useResult
  $Res call(
      {int id,
      String nom,
      @JsonKey(name: 'prix_detail') double prixDetail,
      @JsonKey(name: 'prix_gros') double? prixGros,
      String categorie,
      List<PosLot> lots});
}

/// @nodoc
class _$PosProduitCatalogueCopyWithImpl<$Res, $Val extends PosProduitCatalogue>
    implements $PosProduitCatalogueCopyWith<$Res> {
  _$PosProduitCatalogueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosProduitCatalogue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? prixDetail = null,
    Object? prixGros = freezed,
    Object? categorie = null,
    Object? lots = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      prixDetail: null == prixDetail
          ? _value.prixDetail
          : prixDetail // ignore: cast_nullable_to_non_nullable
              as double,
      prixGros: freezed == prixGros
          ? _value.prixGros
          : prixGros // ignore: cast_nullable_to_non_nullable
              as double?,
      categorie: null == categorie
          ? _value.categorie
          : categorie // ignore: cast_nullable_to_non_nullable
              as String,
      lots: null == lots
          ? _value.lots
          : lots // ignore: cast_nullable_to_non_nullable
              as List<PosLot>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PosProduitCatalogueImplCopyWith<$Res>
    implements $PosProduitCatalogueCopyWith<$Res> {
  factory _$$PosProduitCatalogueImplCopyWith(_$PosProduitCatalogueImpl value,
          $Res Function(_$PosProduitCatalogueImpl) then) =
      __$$PosProduitCatalogueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String nom,
      @JsonKey(name: 'prix_detail') double prixDetail,
      @JsonKey(name: 'prix_gros') double? prixGros,
      String categorie,
      List<PosLot> lots});
}

/// @nodoc
class __$$PosProduitCatalogueImplCopyWithImpl<$Res>
    extends _$PosProduitCatalogueCopyWithImpl<$Res, _$PosProduitCatalogueImpl>
    implements _$$PosProduitCatalogueImplCopyWith<$Res> {
  __$$PosProduitCatalogueImplCopyWithImpl(_$PosProduitCatalogueImpl _value,
      $Res Function(_$PosProduitCatalogueImpl) _then)
      : super(_value, _then);

  /// Create a copy of PosProduitCatalogue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? prixDetail = null,
    Object? prixGros = freezed,
    Object? categorie = null,
    Object? lots = null,
  }) {
    return _then(_$PosProduitCatalogueImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      prixDetail: null == prixDetail
          ? _value.prixDetail
          : prixDetail // ignore: cast_nullable_to_non_nullable
              as double,
      prixGros: freezed == prixGros
          ? _value.prixGros
          : prixGros // ignore: cast_nullable_to_non_nullable
              as double?,
      categorie: null == categorie
          ? _value.categorie
          : categorie // ignore: cast_nullable_to_non_nullable
              as String,
      lots: null == lots
          ? _value._lots
          : lots // ignore: cast_nullable_to_non_nullable
              as List<PosLot>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PosProduitCatalogueImpl implements _PosProduitCatalogue {
  const _$PosProduitCatalogueImpl(
      {required this.id,
      required this.nom,
      @JsonKey(name: 'prix_detail') required this.prixDetail,
      @JsonKey(name: 'prix_gros') this.prixGros,
      this.categorie = '',
      final List<PosLot> lots = const []})
      : _lots = lots;

  factory _$PosProduitCatalogueImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosProduitCatalogueImplFromJson(json);

  @override
  final int id;
  @override
  final String nom;
  @override
  @JsonKey(name: 'prix_detail')
  final double prixDetail;
  @override
  @JsonKey(name: 'prix_gros')
  final double? prixGros;
  @override
  @JsonKey()
  final String categorie;
  final List<PosLot> _lots;
  @override
  @JsonKey()
  List<PosLot> get lots {
    if (_lots is EqualUnmodifiableListView) return _lots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lots);
  }

  @override
  String toString() {
    return 'PosProduitCatalogue(id: $id, nom: $nom, prixDetail: $prixDetail, prixGros: $prixGros, categorie: $categorie, lots: $lots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosProduitCatalogueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.prixDetail, prixDetail) ||
                other.prixDetail == prixDetail) &&
            (identical(other.prixGros, prixGros) ||
                other.prixGros == prixGros) &&
            (identical(other.categorie, categorie) ||
                other.categorie == categorie) &&
            const DeepCollectionEquality().equals(other._lots, _lots));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nom, prixDetail, prixGros,
      categorie, const DeepCollectionEquality().hash(_lots));

  /// Create a copy of PosProduitCatalogue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosProduitCatalogueImplCopyWith<_$PosProduitCatalogueImpl> get copyWith =>
      __$$PosProduitCatalogueImplCopyWithImpl<_$PosProduitCatalogueImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PosProduitCatalogueImplToJson(
      this,
    );
  }
}

abstract class _PosProduitCatalogue implements PosProduitCatalogue {
  const factory _PosProduitCatalogue(
      {required final int id,
      required final String nom,
      @JsonKey(name: 'prix_detail') required final double prixDetail,
      @JsonKey(name: 'prix_gros') final double? prixGros,
      final String categorie,
      final List<PosLot> lots}) = _$PosProduitCatalogueImpl;

  factory _PosProduitCatalogue.fromJson(Map<String, dynamic> json) =
      _$PosProduitCatalogueImpl.fromJson;

  @override
  int get id;
  @override
  String get nom;
  @override
  @JsonKey(name: 'prix_detail')
  double get prixDetail;
  @override
  @JsonKey(name: 'prix_gros')
  double? get prixGros;
  @override
  String get categorie;
  @override
  List<PosLot> get lots;

  /// Create a copy of PosProduitCatalogue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosProduitCatalogueImplCopyWith<_$PosProduitCatalogueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
