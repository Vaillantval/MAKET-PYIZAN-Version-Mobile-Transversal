// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'panier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LignePanier _$LignePanierFromJson(Map<String, dynamic> json) {
  return _LignePanier.fromJson(json);
}

/// @nodoc
mixin _$LignePanier {
  int get id => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  int get quantite => throw _privateConstructorUsedError;
  String get prixUnitaire => throw _privateConstructorUsedError;
  double get sousTotal => throw _privateConstructorUsedError;
  String get uniteVente => throw _privateConstructorUsedError;
  int get producteurId => throw _privateConstructorUsedError;
  String get producteurNom => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  int get stockReel => throw _privateConstructorUsedError;

  /// Serializes this LignePanier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LignePanier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LignePanierCopyWith<LignePanier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LignePanierCopyWith<$Res> {
  factory $LignePanierCopyWith(
          LignePanier value, $Res Function(LignePanier) then) =
      _$LignePanierCopyWithImpl<$Res, LignePanier>;
  @useResult
  $Res call(
      {int id,
      String slug,
      String nom,
      int quantite,
      String prixUnitaire,
      double sousTotal,
      String uniteVente,
      int producteurId,
      String producteurNom,
      String? image,
      int stockReel});
}

/// @nodoc
class _$LignePanierCopyWithImpl<$Res, $Val extends LignePanier>
    implements $LignePanierCopyWith<$Res> {
  _$LignePanierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LignePanier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? nom = null,
    Object? quantite = null,
    Object? prixUnitaire = null,
    Object? sousTotal = null,
    Object? uniteVente = null,
    Object? producteurId = null,
    Object? producteurNom = null,
    Object? image = freezed,
    Object? stockReel = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
      prixUnitaire: null == prixUnitaire
          ? _value.prixUnitaire
          : prixUnitaire // ignore: cast_nullable_to_non_nullable
              as String,
      sousTotal: null == sousTotal
          ? _value.sousTotal
          : sousTotal // ignore: cast_nullable_to_non_nullable
              as double,
      uniteVente: null == uniteVente
          ? _value.uniteVente
          : uniteVente // ignore: cast_nullable_to_non_nullable
              as String,
      producteurId: null == producteurId
          ? _value.producteurId
          : producteurId // ignore: cast_nullable_to_non_nullable
              as int,
      producteurNom: null == producteurNom
          ? _value.producteurNom
          : producteurNom // ignore: cast_nullable_to_non_nullable
              as String,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      stockReel: null == stockReel
          ? _value.stockReel
          : stockReel // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LignePanierImplCopyWith<$Res>
    implements $LignePanierCopyWith<$Res> {
  factory _$$LignePanierImplCopyWith(
          _$LignePanierImpl value, $Res Function(_$LignePanierImpl) then) =
      __$$LignePanierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String slug,
      String nom,
      int quantite,
      String prixUnitaire,
      double sousTotal,
      String uniteVente,
      int producteurId,
      String producteurNom,
      String? image,
      int stockReel});
}

/// @nodoc
class __$$LignePanierImplCopyWithImpl<$Res>
    extends _$LignePanierCopyWithImpl<$Res, _$LignePanierImpl>
    implements _$$LignePanierImplCopyWith<$Res> {
  __$$LignePanierImplCopyWithImpl(
      _$LignePanierImpl _value, $Res Function(_$LignePanierImpl) _then)
      : super(_value, _then);

  /// Create a copy of LignePanier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? nom = null,
    Object? quantite = null,
    Object? prixUnitaire = null,
    Object? sousTotal = null,
    Object? uniteVente = null,
    Object? producteurId = null,
    Object? producteurNom = null,
    Object? image = freezed,
    Object? stockReel = null,
  }) {
    return _then(_$LignePanierImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
      prixUnitaire: null == prixUnitaire
          ? _value.prixUnitaire
          : prixUnitaire // ignore: cast_nullable_to_non_nullable
              as String,
      sousTotal: null == sousTotal
          ? _value.sousTotal
          : sousTotal // ignore: cast_nullable_to_non_nullable
              as double,
      uniteVente: null == uniteVente
          ? _value.uniteVente
          : uniteVente // ignore: cast_nullable_to_non_nullable
              as String,
      producteurId: null == producteurId
          ? _value.producteurId
          : producteurId // ignore: cast_nullable_to_non_nullable
              as int,
      producteurNom: null == producteurNom
          ? _value.producteurNom
          : producteurNom // ignore: cast_nullable_to_non_nullable
              as String,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      stockReel: null == stockReel
          ? _value.stockReel
          : stockReel // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LignePanierImpl implements _LignePanier {
  const _$LignePanierImpl(
      {required this.id,
      required this.slug,
      required this.nom,
      required this.quantite,
      required this.prixUnitaire,
      required this.sousTotal,
      required this.uniteVente,
      required this.producteurId,
      required this.producteurNom,
      this.image,
      this.stockReel = 0});

  factory _$LignePanierImpl.fromJson(Map<String, dynamic> json) =>
      _$$LignePanierImplFromJson(json);

  @override
  final int id;
  @override
  final String slug;
  @override
  final String nom;
  @override
  final int quantite;
  @override
  final String prixUnitaire;
  @override
  final double sousTotal;
  @override
  final String uniteVente;
  @override
  final int producteurId;
  @override
  final String producteurNom;
  @override
  final String? image;
  @override
  @JsonKey()
  final int stockReel;

  @override
  String toString() {
    return 'LignePanier(id: $id, slug: $slug, nom: $nom, quantite: $quantite, prixUnitaire: $prixUnitaire, sousTotal: $sousTotal, uniteVente: $uniteVente, producteurId: $producteurId, producteurNom: $producteurNom, image: $image, stockReel: $stockReel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LignePanierImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.quantite, quantite) ||
                other.quantite == quantite) &&
            (identical(other.prixUnitaire, prixUnitaire) ||
                other.prixUnitaire == prixUnitaire) &&
            (identical(other.sousTotal, sousTotal) ||
                other.sousTotal == sousTotal) &&
            (identical(other.uniteVente, uniteVente) ||
                other.uniteVente == uniteVente) &&
            (identical(other.producteurId, producteurId) ||
                other.producteurId == producteurId) &&
            (identical(other.producteurNom, producteurNom) ||
                other.producteurNom == producteurNom) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.stockReel, stockReel) ||
                other.stockReel == stockReel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      slug,
      nom,
      quantite,
      prixUnitaire,
      sousTotal,
      uniteVente,
      producteurId,
      producteurNom,
      image,
      stockReel);

  /// Create a copy of LignePanier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LignePanierImplCopyWith<_$LignePanierImpl> get copyWith =>
      __$$LignePanierImplCopyWithImpl<_$LignePanierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LignePanierImplToJson(
      this,
    );
  }
}

abstract class _LignePanier implements LignePanier {
  const factory _LignePanier(
      {required final int id,
      required final String slug,
      required final String nom,
      required final int quantite,
      required final String prixUnitaire,
      required final double sousTotal,
      required final String uniteVente,
      required final int producteurId,
      required final String producteurNom,
      final String? image,
      final int stockReel}) = _$LignePanierImpl;

  factory _LignePanier.fromJson(Map<String, dynamic> json) =
      _$LignePanierImpl.fromJson;

  @override
  int get id;
  @override
  String get slug;
  @override
  String get nom;
  @override
  int get quantite;
  @override
  String get prixUnitaire;
  @override
  double get sousTotal;
  @override
  String get uniteVente;
  @override
  int get producteurId;
  @override
  String get producteurNom;
  @override
  String? get image;
  @override
  int get stockReel;

  /// Create a copy of LignePanier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LignePanierImplCopyWith<_$LignePanierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Panier _$PanierFromJson(Map<String, dynamic> json) {
  return _Panier.fromJson(json);
}

/// @nodoc
mixin _$Panier {
  List<LignePanier> get items => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  int get nbArticles => throw _privateConstructorUsedError;
  int get nbItems => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get producteurs =>
      throw _privateConstructorUsedError;

  /// Serializes this Panier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Panier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PanierCopyWith<Panier> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PanierCopyWith<$Res> {
  factory $PanierCopyWith(Panier value, $Res Function(Panier) then) =
      _$PanierCopyWithImpl<$Res, Panier>;
  @useResult
  $Res call(
      {List<LignePanier> items,
      double total,
      int nbArticles,
      int nbItems,
      List<Map<String, dynamic>> producteurs});
}

/// @nodoc
class _$PanierCopyWithImpl<$Res, $Val extends Panier>
    implements $PanierCopyWith<$Res> {
  _$PanierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Panier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
    Object? nbArticles = null,
    Object? nbItems = null,
    Object? producteurs = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LignePanier>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      nbArticles: null == nbArticles
          ? _value.nbArticles
          : nbArticles // ignore: cast_nullable_to_non_nullable
              as int,
      nbItems: null == nbItems
          ? _value.nbItems
          : nbItems // ignore: cast_nullable_to_non_nullable
              as int,
      producteurs: null == producteurs
          ? _value.producteurs
          : producteurs // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PanierImplCopyWith<$Res> implements $PanierCopyWith<$Res> {
  factory _$$PanierImplCopyWith(
          _$PanierImpl value, $Res Function(_$PanierImpl) then) =
      __$$PanierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<LignePanier> items,
      double total,
      int nbArticles,
      int nbItems,
      List<Map<String, dynamic>> producteurs});
}

/// @nodoc
class __$$PanierImplCopyWithImpl<$Res>
    extends _$PanierCopyWithImpl<$Res, _$PanierImpl>
    implements _$$PanierImplCopyWith<$Res> {
  __$$PanierImplCopyWithImpl(
      _$PanierImpl _value, $Res Function(_$PanierImpl) _then)
      : super(_value, _then);

  /// Create a copy of Panier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
    Object? nbArticles = null,
    Object? nbItems = null,
    Object? producteurs = null,
  }) {
    return _then(_$PanierImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LignePanier>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      nbArticles: null == nbArticles
          ? _value.nbArticles
          : nbArticles // ignore: cast_nullable_to_non_nullable
              as int,
      nbItems: null == nbItems
          ? _value.nbItems
          : nbItems // ignore: cast_nullable_to_non_nullable
              as int,
      producteurs: null == producteurs
          ? _value._producteurs
          : producteurs // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PanierImpl implements _Panier {
  const _$PanierImpl(
      {final List<LignePanier> items = const [],
      this.total = 0.0,
      this.nbArticles = 0,
      this.nbItems = 0,
      final List<Map<String, dynamic>> producteurs = const []})
      : _items = items,
        _producteurs = producteurs;

  factory _$PanierImpl.fromJson(Map<String, dynamic> json) =>
      _$$PanierImplFromJson(json);

  final List<LignePanier> _items;
  @override
  @JsonKey()
  List<LignePanier> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final double total;
  @override
  @JsonKey()
  final int nbArticles;
  @override
  @JsonKey()
  final int nbItems;
  final List<Map<String, dynamic>> _producteurs;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get producteurs {
    if (_producteurs is EqualUnmodifiableListView) return _producteurs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_producteurs);
  }

  @override
  String toString() {
    return 'Panier(items: $items, total: $total, nbArticles: $nbArticles, nbItems: $nbItems, producteurs: $producteurs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PanierImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.nbArticles, nbArticles) ||
                other.nbArticles == nbArticles) &&
            (identical(other.nbItems, nbItems) || other.nbItems == nbItems) &&
            const DeepCollectionEquality()
                .equals(other._producteurs, _producteurs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      total,
      nbArticles,
      nbItems,
      const DeepCollectionEquality().hash(_producteurs));

  /// Create a copy of Panier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PanierImplCopyWith<_$PanierImpl> get copyWith =>
      __$$PanierImplCopyWithImpl<_$PanierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PanierImplToJson(
      this,
    );
  }
}

abstract class _Panier implements Panier {
  const factory _Panier(
      {final List<LignePanier> items,
      final double total,
      final int nbArticles,
      final int nbItems,
      final List<Map<String, dynamic>> producteurs}) = _$PanierImpl;

  factory _Panier.fromJson(Map<String, dynamic> json) = _$PanierImpl.fromJson;

  @override
  List<LignePanier> get items;
  @override
  double get total;
  @override
  int get nbArticles;
  @override
  int get nbItems;
  @override
  List<Map<String, dynamic>> get producteurs;

  /// Create a copy of Panier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PanierImplCopyWith<_$PanierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
