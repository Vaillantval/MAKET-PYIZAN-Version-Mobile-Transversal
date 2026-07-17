// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'produit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Produit _$ProduitFromJson(Map<String, dynamic> json) {
  return _Produit.fromJson(json);
}

/// @nodoc
mixin _$Produit {
  int get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get variete => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_unitaire')
  String get prixUnitaire => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_gros')
  String? get prixGros => throw _privateConstructorUsedError;
  @JsonKey(name: 'unite_vente')
  String get uniteVente => throw _privateConstructorUsedError;
  @JsonKey(name: 'unite_vente_label')
  String get uniteVenteLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'quantite_min_commande')
  int get quantiteMinCommande => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_reel')
  int get stockReel => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured')
  bool get isFeatured => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_principale')
  String? get imagePrincipale => throw _privateConstructorUsedError;
  Map<String, dynamic>? get categorie => throw _privateConstructorUsedError;
  Map<String, dynamic>? get producteur => throw _privateConstructorUsedError;
  String get origine => throw _privateConstructorUsedError;
  String get saison => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Produit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Produit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProduitCopyWith<Produit> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProduitCopyWith<$Res> {
  factory $ProduitCopyWith(Produit value, $Res Function(Produit) then) =
      _$ProduitCopyWithImpl<$Res, Produit>;
  @useResult
  $Res call(
      {int id,
      String nom,
      String slug,
      String variete,
      String description,
      @JsonKey(name: 'prix_unitaire') String prixUnitaire,
      @JsonKey(name: 'prix_gros') String? prixGros,
      @JsonKey(name: 'unite_vente') String uniteVente,
      @JsonKey(name: 'unite_vente_label') String uniteVenteLabel,
      @JsonKey(name: 'quantite_min_commande') int quantiteMinCommande,
      @JsonKey(name: 'stock_reel') int stockReel,
      @JsonKey(name: 'is_featured') bool isFeatured,
      @JsonKey(name: 'image_principale') String? imagePrincipale,
      Map<String, dynamic>? categorie,
      Map<String, dynamic>? producteur,
      String origine,
      String saison,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class _$ProduitCopyWithImpl<$Res, $Val extends Produit>
    implements $ProduitCopyWith<$Res> {
  _$ProduitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Produit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? slug = null,
    Object? variete = null,
    Object? description = null,
    Object? prixUnitaire = null,
    Object? prixGros = freezed,
    Object? uniteVente = null,
    Object? uniteVenteLabel = null,
    Object? quantiteMinCommande = null,
    Object? stockReel = null,
    Object? isFeatured = null,
    Object? imagePrincipale = freezed,
    Object? categorie = freezed,
    Object? producteur = freezed,
    Object? origine = null,
    Object? saison = null,
    Object? createdAt = freezed,
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
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      variete: null == variete
          ? _value.variete
          : variete // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      prixUnitaire: null == prixUnitaire
          ? _value.prixUnitaire
          : prixUnitaire // ignore: cast_nullable_to_non_nullable
              as String,
      prixGros: freezed == prixGros
          ? _value.prixGros
          : prixGros // ignore: cast_nullable_to_non_nullable
              as String?,
      uniteVente: null == uniteVente
          ? _value.uniteVente
          : uniteVente // ignore: cast_nullable_to_non_nullable
              as String,
      uniteVenteLabel: null == uniteVenteLabel
          ? _value.uniteVenteLabel
          : uniteVenteLabel // ignore: cast_nullable_to_non_nullable
              as String,
      quantiteMinCommande: null == quantiteMinCommande
          ? _value.quantiteMinCommande
          : quantiteMinCommande // ignore: cast_nullable_to_non_nullable
              as int,
      stockReel: null == stockReel
          ? _value.stockReel
          : stockReel // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      imagePrincipale: freezed == imagePrincipale
          ? _value.imagePrincipale
          : imagePrincipale // ignore: cast_nullable_to_non_nullable
              as String?,
      categorie: freezed == categorie
          ? _value.categorie
          : categorie // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      producteur: freezed == producteur
          ? _value.producteur
          : producteur // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      origine: null == origine
          ? _value.origine
          : origine // ignore: cast_nullable_to_non_nullable
              as String,
      saison: null == saison
          ? _value.saison
          : saison // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProduitImplCopyWith<$Res> implements $ProduitCopyWith<$Res> {
  factory _$$ProduitImplCopyWith(
          _$ProduitImpl value, $Res Function(_$ProduitImpl) then) =
      __$$ProduitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String nom,
      String slug,
      String variete,
      String description,
      @JsonKey(name: 'prix_unitaire') String prixUnitaire,
      @JsonKey(name: 'prix_gros') String? prixGros,
      @JsonKey(name: 'unite_vente') String uniteVente,
      @JsonKey(name: 'unite_vente_label') String uniteVenteLabel,
      @JsonKey(name: 'quantite_min_commande') int quantiteMinCommande,
      @JsonKey(name: 'stock_reel') int stockReel,
      @JsonKey(name: 'is_featured') bool isFeatured,
      @JsonKey(name: 'image_principale') String? imagePrincipale,
      Map<String, dynamic>? categorie,
      Map<String, dynamic>? producteur,
      String origine,
      String saison,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class __$$ProduitImplCopyWithImpl<$Res>
    extends _$ProduitCopyWithImpl<$Res, _$ProduitImpl>
    implements _$$ProduitImplCopyWith<$Res> {
  __$$ProduitImplCopyWithImpl(
      _$ProduitImpl _value, $Res Function(_$ProduitImpl) _then)
      : super(_value, _then);

  /// Create a copy of Produit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? slug = null,
    Object? variete = null,
    Object? description = null,
    Object? prixUnitaire = null,
    Object? prixGros = freezed,
    Object? uniteVente = null,
    Object? uniteVenteLabel = null,
    Object? quantiteMinCommande = null,
    Object? stockReel = null,
    Object? isFeatured = null,
    Object? imagePrincipale = freezed,
    Object? categorie = freezed,
    Object? producteur = freezed,
    Object? origine = null,
    Object? saison = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$ProduitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      variete: null == variete
          ? _value.variete
          : variete // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      prixUnitaire: null == prixUnitaire
          ? _value.prixUnitaire
          : prixUnitaire // ignore: cast_nullable_to_non_nullable
              as String,
      prixGros: freezed == prixGros
          ? _value.prixGros
          : prixGros // ignore: cast_nullable_to_non_nullable
              as String?,
      uniteVente: null == uniteVente
          ? _value.uniteVente
          : uniteVente // ignore: cast_nullable_to_non_nullable
              as String,
      uniteVenteLabel: null == uniteVenteLabel
          ? _value.uniteVenteLabel
          : uniteVenteLabel // ignore: cast_nullable_to_non_nullable
              as String,
      quantiteMinCommande: null == quantiteMinCommande
          ? _value.quantiteMinCommande
          : quantiteMinCommande // ignore: cast_nullable_to_non_nullable
              as int,
      stockReel: null == stockReel
          ? _value.stockReel
          : stockReel // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      imagePrincipale: freezed == imagePrincipale
          ? _value.imagePrincipale
          : imagePrincipale // ignore: cast_nullable_to_non_nullable
              as String?,
      categorie: freezed == categorie
          ? _value._categorie
          : categorie // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      producteur: freezed == producteur
          ? _value._producteur
          : producteur // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      origine: null == origine
          ? _value.origine
          : origine // ignore: cast_nullable_to_non_nullable
              as String,
      saison: null == saison
          ? _value.saison
          : saison // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProduitImpl implements _Produit {
  const _$ProduitImpl(
      {required this.id,
      required this.nom,
      required this.slug,
      this.variete = '',
      this.description = '',
      @JsonKey(name: 'prix_unitaire') required this.prixUnitaire,
      @JsonKey(name: 'prix_gros') this.prixGros,
      @JsonKey(name: 'unite_vente') required this.uniteVente,
      @JsonKey(name: 'unite_vente_label') required this.uniteVenteLabel,
      @JsonKey(name: 'quantite_min_commande') this.quantiteMinCommande = 1,
      @JsonKey(name: 'stock_reel') this.stockReel = 0,
      @JsonKey(name: 'is_featured') this.isFeatured = false,
      @JsonKey(name: 'image_principale') this.imagePrincipale,
      final Map<String, dynamic>? categorie,
      final Map<String, dynamic>? producteur,
      this.origine = '',
      this.saison = '',
      @JsonKey(name: 'created_at') this.createdAt})
      : _categorie = categorie,
        _producteur = producteur;

  factory _$ProduitImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProduitImplFromJson(json);

  @override
  final int id;
  @override
  final String nom;
  @override
  final String slug;
  @override
  @JsonKey()
  final String variete;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey(name: 'prix_unitaire')
  final String prixUnitaire;
  @override
  @JsonKey(name: 'prix_gros')
  final String? prixGros;
  @override
  @JsonKey(name: 'unite_vente')
  final String uniteVente;
  @override
  @JsonKey(name: 'unite_vente_label')
  final String uniteVenteLabel;
  @override
  @JsonKey(name: 'quantite_min_commande')
  final int quantiteMinCommande;
  @override
  @JsonKey(name: 'stock_reel')
  final int stockReel;
  @override
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @override
  @JsonKey(name: 'image_principale')
  final String? imagePrincipale;
  final Map<String, dynamic>? _categorie;
  @override
  Map<String, dynamic>? get categorie {
    final value = _categorie;
    if (value == null) return null;
    if (_categorie is EqualUnmodifiableMapView) return _categorie;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _producteur;
  @override
  Map<String, dynamic>? get producteur {
    final value = _producteur;
    if (value == null) return null;
    if (_producteur is EqualUnmodifiableMapView) return _producteur;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final String origine;
  @override
  @JsonKey()
  final String saison;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'Produit(id: $id, nom: $nom, slug: $slug, variete: $variete, description: $description, prixUnitaire: $prixUnitaire, prixGros: $prixGros, uniteVente: $uniteVente, uniteVenteLabel: $uniteVenteLabel, quantiteMinCommande: $quantiteMinCommande, stockReel: $stockReel, isFeatured: $isFeatured, imagePrincipale: $imagePrincipale, categorie: $categorie, producteur: $producteur, origine: $origine, saison: $saison, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProduitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.variete, variete) || other.variete == variete) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.prixUnitaire, prixUnitaire) ||
                other.prixUnitaire == prixUnitaire) &&
            (identical(other.prixGros, prixGros) ||
                other.prixGros == prixGros) &&
            (identical(other.uniteVente, uniteVente) ||
                other.uniteVente == uniteVente) &&
            (identical(other.uniteVenteLabel, uniteVenteLabel) ||
                other.uniteVenteLabel == uniteVenteLabel) &&
            (identical(other.quantiteMinCommande, quantiteMinCommande) ||
                other.quantiteMinCommande == quantiteMinCommande) &&
            (identical(other.stockReel, stockReel) ||
                other.stockReel == stockReel) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.imagePrincipale, imagePrincipale) ||
                other.imagePrincipale == imagePrincipale) &&
            const DeepCollectionEquality()
                .equals(other._categorie, _categorie) &&
            const DeepCollectionEquality()
                .equals(other._producteur, _producteur) &&
            (identical(other.origine, origine) || other.origine == origine) &&
            (identical(other.saison, saison) || other.saison == saison) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nom,
      slug,
      variete,
      description,
      prixUnitaire,
      prixGros,
      uniteVente,
      uniteVenteLabel,
      quantiteMinCommande,
      stockReel,
      isFeatured,
      imagePrincipale,
      const DeepCollectionEquality().hash(_categorie),
      const DeepCollectionEquality().hash(_producteur),
      origine,
      saison,
      createdAt);

  /// Create a copy of Produit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProduitImplCopyWith<_$ProduitImpl> get copyWith =>
      __$$ProduitImplCopyWithImpl<_$ProduitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProduitImplToJson(
      this,
    );
  }
}

abstract class _Produit implements Produit {
  const factory _Produit(
      {required final int id,
      required final String nom,
      required final String slug,
      final String variete,
      final String description,
      @JsonKey(name: 'prix_unitaire') required final String prixUnitaire,
      @JsonKey(name: 'prix_gros') final String? prixGros,
      @JsonKey(name: 'unite_vente') required final String uniteVente,
      @JsonKey(name: 'unite_vente_label') required final String uniteVenteLabel,
      @JsonKey(name: 'quantite_min_commande') final int quantiteMinCommande,
      @JsonKey(name: 'stock_reel') final int stockReel,
      @JsonKey(name: 'is_featured') final bool isFeatured,
      @JsonKey(name: 'image_principale') final String? imagePrincipale,
      final Map<String, dynamic>? categorie,
      final Map<String, dynamic>? producteur,
      final String origine,
      final String saison,
      @JsonKey(name: 'created_at') final String? createdAt}) = _$ProduitImpl;

  factory _Produit.fromJson(Map<String, dynamic> json) = _$ProduitImpl.fromJson;

  @override
  int get id;
  @override
  String get nom;
  @override
  String get slug;
  @override
  String get variete;
  @override
  String get description;
  @override
  @JsonKey(name: 'prix_unitaire')
  String get prixUnitaire;
  @override
  @JsonKey(name: 'prix_gros')
  String? get prixGros;
  @override
  @JsonKey(name: 'unite_vente')
  String get uniteVente;
  @override
  @JsonKey(name: 'unite_vente_label')
  String get uniteVenteLabel;
  @override
  @JsonKey(name: 'quantite_min_commande')
  int get quantiteMinCommande;
  @override
  @JsonKey(name: 'stock_reel')
  int get stockReel;
  @override
  @JsonKey(name: 'is_featured')
  bool get isFeatured;
  @override
  @JsonKey(name: 'image_principale')
  String? get imagePrincipale;
  @override
  Map<String, dynamic>? get categorie;
  @override
  Map<String, dynamic>? get producteur;
  @override
  String get origine;
  @override
  String get saison;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of Produit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProduitImplCopyWith<_$ProduitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
