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

PosPrixUnite _$PosPrixUniteFromJson(Map<String, dynamic> json) {
  return _PosPrixUnite.fromJson(json);
}

/// @nodoc
mixin _$PosPrixUnite {
  @JsonKey(name: 'unite_id')
  int get uniteId => throw _privateConstructorUsedError;
  @JsonKey(name: 'unite_code')
  String get uniteCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'unite_nom')
  String get uniteNom => throw _privateConstructorUsedError;
  @JsonKey(fromJson: jsonToDouble)
  double get prix => throw _privateConstructorUsedError;
  @JsonKey(name: 'facteur_conversion', fromJson: jsonToDouble)
  double get facteurConversion => throw _privateConstructorUsedError;
  @JsonKey(name: 'est_unite_base')
  bool get estUniteBase => throw _privateConstructorUsedError;

  /// Serializes this PosPrixUnite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosPrixUnite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosPrixUniteCopyWith<PosPrixUnite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosPrixUniteCopyWith<$Res> {
  factory $PosPrixUniteCopyWith(
          PosPrixUnite value, $Res Function(PosPrixUnite) then) =
      _$PosPrixUniteCopyWithImpl<$Res, PosPrixUnite>;
  @useResult
  $Res call(
      {@JsonKey(name: 'unite_id') int uniteId,
      @JsonKey(name: 'unite_code') String uniteCode,
      @JsonKey(name: 'unite_nom') String uniteNom,
      @JsonKey(fromJson: jsonToDouble) double prix,
      @JsonKey(name: 'facteur_conversion', fromJson: jsonToDouble)
      double facteurConversion,
      @JsonKey(name: 'est_unite_base') bool estUniteBase});
}

/// @nodoc
class _$PosPrixUniteCopyWithImpl<$Res, $Val extends PosPrixUnite>
    implements $PosPrixUniteCopyWith<$Res> {
  _$PosPrixUniteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosPrixUnite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uniteId = null,
    Object? uniteCode = null,
    Object? uniteNom = null,
    Object? prix = null,
    Object? facteurConversion = null,
    Object? estUniteBase = null,
  }) {
    return _then(_value.copyWith(
      uniteId: null == uniteId
          ? _value.uniteId
          : uniteId // ignore: cast_nullable_to_non_nullable
              as int,
      uniteCode: null == uniteCode
          ? _value.uniteCode
          : uniteCode // ignore: cast_nullable_to_non_nullable
              as String,
      uniteNom: null == uniteNom
          ? _value.uniteNom
          : uniteNom // ignore: cast_nullable_to_non_nullable
              as String,
      prix: null == prix
          ? _value.prix
          : prix // ignore: cast_nullable_to_non_nullable
              as double,
      facteurConversion: null == facteurConversion
          ? _value.facteurConversion
          : facteurConversion // ignore: cast_nullable_to_non_nullable
              as double,
      estUniteBase: null == estUniteBase
          ? _value.estUniteBase
          : estUniteBase // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PosPrixUniteImplCopyWith<$Res>
    implements $PosPrixUniteCopyWith<$Res> {
  factory _$$PosPrixUniteImplCopyWith(
          _$PosPrixUniteImpl value, $Res Function(_$PosPrixUniteImpl) then) =
      __$$PosPrixUniteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'unite_id') int uniteId,
      @JsonKey(name: 'unite_code') String uniteCode,
      @JsonKey(name: 'unite_nom') String uniteNom,
      @JsonKey(fromJson: jsonToDouble) double prix,
      @JsonKey(name: 'facteur_conversion', fromJson: jsonToDouble)
      double facteurConversion,
      @JsonKey(name: 'est_unite_base') bool estUniteBase});
}

/// @nodoc
class __$$PosPrixUniteImplCopyWithImpl<$Res>
    extends _$PosPrixUniteCopyWithImpl<$Res, _$PosPrixUniteImpl>
    implements _$$PosPrixUniteImplCopyWith<$Res> {
  __$$PosPrixUniteImplCopyWithImpl(
      _$PosPrixUniteImpl _value, $Res Function(_$PosPrixUniteImpl) _then)
      : super(_value, _then);

  /// Create a copy of PosPrixUnite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uniteId = null,
    Object? uniteCode = null,
    Object? uniteNom = null,
    Object? prix = null,
    Object? facteurConversion = null,
    Object? estUniteBase = null,
  }) {
    return _then(_$PosPrixUniteImpl(
      uniteId: null == uniteId
          ? _value.uniteId
          : uniteId // ignore: cast_nullable_to_non_nullable
              as int,
      uniteCode: null == uniteCode
          ? _value.uniteCode
          : uniteCode // ignore: cast_nullable_to_non_nullable
              as String,
      uniteNom: null == uniteNom
          ? _value.uniteNom
          : uniteNom // ignore: cast_nullable_to_non_nullable
              as String,
      prix: null == prix
          ? _value.prix
          : prix // ignore: cast_nullable_to_non_nullable
              as double,
      facteurConversion: null == facteurConversion
          ? _value.facteurConversion
          : facteurConversion // ignore: cast_nullable_to_non_nullable
              as double,
      estUniteBase: null == estUniteBase
          ? _value.estUniteBase
          : estUniteBase // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PosPrixUniteImpl implements _PosPrixUnite {
  const _$PosPrixUniteImpl(
      {@JsonKey(name: 'unite_id') required this.uniteId,
      @JsonKey(name: 'unite_code') required this.uniteCode,
      @JsonKey(name: 'unite_nom') required this.uniteNom,
      @JsonKey(fromJson: jsonToDouble) required this.prix,
      @JsonKey(name: 'facteur_conversion', fromJson: jsonToDouble)
      this.facteurConversion = 1,
      @JsonKey(name: 'est_unite_base') this.estUniteBase = false});

  factory _$PosPrixUniteImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosPrixUniteImplFromJson(json);

  @override
  @JsonKey(name: 'unite_id')
  final int uniteId;
  @override
  @JsonKey(name: 'unite_code')
  final String uniteCode;
  @override
  @JsonKey(name: 'unite_nom')
  final String uniteNom;
  @override
  @JsonKey(fromJson: jsonToDouble)
  final double prix;
  @override
  @JsonKey(name: 'facteur_conversion', fromJson: jsonToDouble)
  final double facteurConversion;
  @override
  @JsonKey(name: 'est_unite_base')
  final bool estUniteBase;

  @override
  String toString() {
    return 'PosPrixUnite(uniteId: $uniteId, uniteCode: $uniteCode, uniteNom: $uniteNom, prix: $prix, facteurConversion: $facteurConversion, estUniteBase: $estUniteBase)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosPrixUniteImpl &&
            (identical(other.uniteId, uniteId) || other.uniteId == uniteId) &&
            (identical(other.uniteCode, uniteCode) ||
                other.uniteCode == uniteCode) &&
            (identical(other.uniteNom, uniteNom) ||
                other.uniteNom == uniteNom) &&
            (identical(other.prix, prix) || other.prix == prix) &&
            (identical(other.facteurConversion, facteurConversion) ||
                other.facteurConversion == facteurConversion) &&
            (identical(other.estUniteBase, estUniteBase) ||
                other.estUniteBase == estUniteBase));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uniteId, uniteCode, uniteNom,
      prix, facteurConversion, estUniteBase);

  /// Create a copy of PosPrixUnite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosPrixUniteImplCopyWith<_$PosPrixUniteImpl> get copyWith =>
      __$$PosPrixUniteImplCopyWithImpl<_$PosPrixUniteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PosPrixUniteImplToJson(
      this,
    );
  }
}

abstract class _PosPrixUnite implements PosPrixUnite {
  const factory _PosPrixUnite(
          {@JsonKey(name: 'unite_id') required final int uniteId,
          @JsonKey(name: 'unite_code') required final String uniteCode,
          @JsonKey(name: 'unite_nom') required final String uniteNom,
          @JsonKey(fromJson: jsonToDouble) required final double prix,
          @JsonKey(name: 'facteur_conversion', fromJson: jsonToDouble)
          final double facteurConversion,
          @JsonKey(name: 'est_unite_base') final bool estUniteBase}) =
      _$PosPrixUniteImpl;

  factory _PosPrixUnite.fromJson(Map<String, dynamic> json) =
      _$PosPrixUniteImpl.fromJson;

  @override
  @JsonKey(name: 'unite_id')
  int get uniteId;
  @override
  @JsonKey(name: 'unite_code')
  String get uniteCode;
  @override
  @JsonKey(name: 'unite_nom')
  String get uniteNom;
  @override
  @JsonKey(fromJson: jsonToDouble)
  double get prix;
  @override
  @JsonKey(name: 'facteur_conversion', fromJson: jsonToDouble)
  double get facteurConversion;
  @override
  @JsonKey(name: 'est_unite_base')
  bool get estUniteBase;

  /// Create a copy of PosPrixUnite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosPrixUniteImplCopyWith<_$PosPrixUniteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PosLot _$PosLotFromJson(Map<String, dynamic> json) {
  return _PosLot.fromJson(json);
}

/// @nodoc
mixin _$PosLot {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'code_barres')
  String? get codeBarres => throw _privateConstructorUsedError;
  @JsonKey(name: 'quantite_actuelle', fromJson: jsonToDouble)
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
      @JsonKey(name: 'quantite_actuelle', fromJson: jsonToDouble)
      double quantiteActuelle});
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
      @JsonKey(name: 'quantite_actuelle', fromJson: jsonToDouble)
      double quantiteActuelle});
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
      @JsonKey(name: 'quantite_actuelle', fromJson: jsonToDouble)
      this.quantiteActuelle = 0});

  factory _$PosLotImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosLotImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'code_barres')
  final String? codeBarres;
  @override
  @JsonKey(name: 'quantite_actuelle', fromJson: jsonToDouble)
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
      @JsonKey(name: 'quantite_actuelle', fromJson: jsonToDouble)
      final double quantiteActuelle}) = _$PosLotImpl;

  factory _PosLot.fromJson(Map<String, dynamic> json) = _$PosLotImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'code_barres')
  String? get codeBarres;
  @override
  @JsonKey(name: 'quantite_actuelle', fromJson: jsonToDouble)
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
  @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
  double get prixDetail => throw _privateConstructorUsedError;
  @JsonKey(name: 'categorie', fromJson: _categorieNomFromJson)
  String get categorie => throw _privateConstructorUsedError;
  @JsonKey(name: 'unite_vente', fromJson: _uniteVenteCodeFromJson)
  String get uniteVente => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_disponible', fromJson: jsonToDouble)
  double get stockDisponible => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String? get photoUrl => throw _privateConstructorUsedError;
  List<PosLot> get lots => throw _privateConstructorUsedError;
  List<PosPrixUnite> get prix => throw _privateConstructorUsedError;

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
      @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble) double prixDetail,
      @JsonKey(name: 'categorie', fromJson: _categorieNomFromJson)
      String categorie,
      @JsonKey(name: 'unite_vente', fromJson: _uniteVenteCodeFromJson)
      String uniteVente,
      @JsonKey(name: 'stock_disponible', fromJson: jsonToDouble)
      double stockDisponible,
      @JsonKey(name: 'photo_url') String? photoUrl,
      List<PosLot> lots,
      List<PosPrixUnite> prix});
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
    Object? categorie = null,
    Object? uniteVente = null,
    Object? stockDisponible = null,
    Object? photoUrl = freezed,
    Object? lots = null,
    Object? prix = null,
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
      categorie: null == categorie
          ? _value.categorie
          : categorie // ignore: cast_nullable_to_non_nullable
              as String,
      uniteVente: null == uniteVente
          ? _value.uniteVente
          : uniteVente // ignore: cast_nullable_to_non_nullable
              as String,
      stockDisponible: null == stockDisponible
          ? _value.stockDisponible
          : stockDisponible // ignore: cast_nullable_to_non_nullable
              as double,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lots: null == lots
          ? _value.lots
          : lots // ignore: cast_nullable_to_non_nullable
              as List<PosLot>,
      prix: null == prix
          ? _value.prix
          : prix // ignore: cast_nullable_to_non_nullable
              as List<PosPrixUnite>,
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
      @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble) double prixDetail,
      @JsonKey(name: 'categorie', fromJson: _categorieNomFromJson)
      String categorie,
      @JsonKey(name: 'unite_vente', fromJson: _uniteVenteCodeFromJson)
      String uniteVente,
      @JsonKey(name: 'stock_disponible', fromJson: jsonToDouble)
      double stockDisponible,
      @JsonKey(name: 'photo_url') String? photoUrl,
      List<PosLot> lots,
      List<PosPrixUnite> prix});
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
    Object? categorie = null,
    Object? uniteVente = null,
    Object? stockDisponible = null,
    Object? photoUrl = freezed,
    Object? lots = null,
    Object? prix = null,
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
      categorie: null == categorie
          ? _value.categorie
          : categorie // ignore: cast_nullable_to_non_nullable
              as String,
      uniteVente: null == uniteVente
          ? _value.uniteVente
          : uniteVente // ignore: cast_nullable_to_non_nullable
              as String,
      stockDisponible: null == stockDisponible
          ? _value.stockDisponible
          : stockDisponible // ignore: cast_nullable_to_non_nullable
              as double,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lots: null == lots
          ? _value._lots
          : lots // ignore: cast_nullable_to_non_nullable
              as List<PosLot>,
      prix: null == prix
          ? _value._prix
          : prix // ignore: cast_nullable_to_non_nullable
              as List<PosPrixUnite>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PosProduitCatalogueImpl implements _PosProduitCatalogue {
  const _$PosProduitCatalogueImpl(
      {required this.id,
      required this.nom,
      @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
      required this.prixDetail,
      @JsonKey(name: 'categorie', fromJson: _categorieNomFromJson)
      this.categorie = '',
      @JsonKey(name: 'unite_vente', fromJson: _uniteVenteCodeFromJson)
      this.uniteVente = '',
      @JsonKey(name: 'stock_disponible', fromJson: jsonToDouble)
      this.stockDisponible = 0,
      @JsonKey(name: 'photo_url') this.photoUrl,
      final List<PosLot> lots = const [],
      final List<PosPrixUnite> prix = const []})
      : _lots = lots,
        _prix = prix;

  factory _$PosProduitCatalogueImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosProduitCatalogueImplFromJson(json);

  @override
  final int id;
  @override
  final String nom;
  @override
  @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
  final double prixDetail;
  @override
  @JsonKey(name: 'categorie', fromJson: _categorieNomFromJson)
  final String categorie;
  @override
  @JsonKey(name: 'unite_vente', fromJson: _uniteVenteCodeFromJson)
  final String uniteVente;
  @override
  @JsonKey(name: 'stock_disponible', fromJson: jsonToDouble)
  final double stockDisponible;
  @override
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  final List<PosLot> _lots;
  @override
  @JsonKey()
  List<PosLot> get lots {
    if (_lots is EqualUnmodifiableListView) return _lots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lots);
  }

  final List<PosPrixUnite> _prix;
  @override
  @JsonKey()
  List<PosPrixUnite> get prix {
    if (_prix is EqualUnmodifiableListView) return _prix;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prix);
  }

  @override
  String toString() {
    return 'PosProduitCatalogue(id: $id, nom: $nom, prixDetail: $prixDetail, categorie: $categorie, uniteVente: $uniteVente, stockDisponible: $stockDisponible, photoUrl: $photoUrl, lots: $lots, prix: $prix)';
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
            (identical(other.categorie, categorie) ||
                other.categorie == categorie) &&
            (identical(other.uniteVente, uniteVente) ||
                other.uniteVente == uniteVente) &&
            (identical(other.stockDisponible, stockDisponible) ||
                other.stockDisponible == stockDisponible) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            const DeepCollectionEquality().equals(other._lots, _lots) &&
            const DeepCollectionEquality().equals(other._prix, _prix));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nom,
      prixDetail,
      categorie,
      uniteVente,
      stockDisponible,
      photoUrl,
      const DeepCollectionEquality().hash(_lots),
      const DeepCollectionEquality().hash(_prix));

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
      @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
      required final double prixDetail,
      @JsonKey(name: 'categorie', fromJson: _categorieNomFromJson)
      final String categorie,
      @JsonKey(name: 'unite_vente', fromJson: _uniteVenteCodeFromJson)
      final String uniteVente,
      @JsonKey(name: 'stock_disponible', fromJson: jsonToDouble)
      final double stockDisponible,
      @JsonKey(name: 'photo_url') final String? photoUrl,
      final List<PosLot> lots,
      final List<PosPrixUnite> prix}) = _$PosProduitCatalogueImpl;

  factory _PosProduitCatalogue.fromJson(Map<String, dynamic> json) =
      _$PosProduitCatalogueImpl.fromJson;

  @override
  int get id;
  @override
  String get nom;
  @override
  @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble)
  double get prixDetail;
  @override
  @JsonKey(name: 'categorie', fromJson: _categorieNomFromJson)
  String get categorie;
  @override
  @JsonKey(name: 'unite_vente', fromJson: _uniteVenteCodeFromJson)
  String get uniteVente;
  @override
  @JsonKey(name: 'stock_disponible', fromJson: jsonToDouble)
  double get stockDisponible;
  @override
  @JsonKey(name: 'photo_url')
  String? get photoUrl;
  @override
  List<PosLot> get lots;
  @override
  List<PosPrixUnite> get prix;

  /// Create a copy of PosProduitCatalogue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosProduitCatalogueImplCopyWith<_$PosProduitCatalogueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
