// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commande.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Commande _$CommandeFromJson(Map<String, dynamic> json) {
  return _Commande.fromJson(json);
}

/// @nodoc
mixin _$Commande {
  @JsonKey(name: 'numero_commande')
  String get numeroCommande =>
      throw _privateConstructorUsedError; // Le backend expose 'producteur_nom' (pas d'objet 'producteur') sur
// les listes acheteur/producteur (CommandeProducteurSerializer).
  @JsonKey(name: 'producteur_nom')
  String get producteur => throw _privateConstructorUsedError;
  String get total => throw _privateConstructorUsedError;
  String get statut => throw _privateConstructorUsedError;
  @JsonKey(name: 'statut_label')
  String get statutLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'statut_paiement')
  String get statutPaiement => throw _privateConstructorUsedError;
  @JsonKey(name: 'methode_paiement')
  String get methodePaiement => throw _privateConstructorUsedError;
  @JsonKey(name: 'mode_livraison')
  String? get modeLivraison => throw _privateConstructorUsedError;
  @JsonKey(name: 'adresse_livraison')
  String? get adresseLivraison => throw _privateConstructorUsedError;
  @JsonKey(name: 'notes_acheteur')
  String? get notesAcheteur => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get details => throw _privateConstructorUsedError;

  /// Serializes this Commande to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Commande
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommandeCopyWith<Commande> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommandeCopyWith<$Res> {
  factory $CommandeCopyWith(Commande value, $Res Function(Commande) then) =
      _$CommandeCopyWithImpl<$Res, Commande>;
  @useResult
  $Res call(
      {@JsonKey(name: 'numero_commande') String numeroCommande,
      @JsonKey(name: 'producteur_nom') String producteur,
      String total,
      String statut,
      @JsonKey(name: 'statut_label') String statutLabel,
      @JsonKey(name: 'statut_paiement') String statutPaiement,
      @JsonKey(name: 'methode_paiement') String methodePaiement,
      @JsonKey(name: 'mode_livraison') String? modeLivraison,
      @JsonKey(name: 'adresse_livraison') String? adresseLivraison,
      @JsonKey(name: 'notes_acheteur') String? notesAcheteur,
      @JsonKey(name: 'created_at') String? createdAt,
      List<Map<String, dynamic>> details});
}

/// @nodoc
class _$CommandeCopyWithImpl<$Res, $Val extends Commande>
    implements $CommandeCopyWith<$Res> {
  _$CommandeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Commande
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? numeroCommande = null,
    Object? producteur = null,
    Object? total = null,
    Object? statut = null,
    Object? statutLabel = null,
    Object? statutPaiement = null,
    Object? methodePaiement = null,
    Object? modeLivraison = freezed,
    Object? adresseLivraison = freezed,
    Object? notesAcheteur = freezed,
    Object? createdAt = freezed,
    Object? details = null,
  }) {
    return _then(_value.copyWith(
      numeroCommande: null == numeroCommande
          ? _value.numeroCommande
          : numeroCommande // ignore: cast_nullable_to_non_nullable
              as String,
      producteur: null == producteur
          ? _value.producteur
          : producteur // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      statutLabel: null == statutLabel
          ? _value.statutLabel
          : statutLabel // ignore: cast_nullable_to_non_nullable
              as String,
      statutPaiement: null == statutPaiement
          ? _value.statutPaiement
          : statutPaiement // ignore: cast_nullable_to_non_nullable
              as String,
      methodePaiement: null == methodePaiement
          ? _value.methodePaiement
          : methodePaiement // ignore: cast_nullable_to_non_nullable
              as String,
      modeLivraison: freezed == modeLivraison
          ? _value.modeLivraison
          : modeLivraison // ignore: cast_nullable_to_non_nullable
              as String?,
      adresseLivraison: freezed == adresseLivraison
          ? _value.adresseLivraison
          : adresseLivraison // ignore: cast_nullable_to_non_nullable
              as String?,
      notesAcheteur: freezed == notesAcheteur
          ? _value.notesAcheteur
          : notesAcheteur // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommandeImplCopyWith<$Res>
    implements $CommandeCopyWith<$Res> {
  factory _$$CommandeImplCopyWith(
          _$CommandeImpl value, $Res Function(_$CommandeImpl) then) =
      __$$CommandeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'numero_commande') String numeroCommande,
      @JsonKey(name: 'producteur_nom') String producteur,
      String total,
      String statut,
      @JsonKey(name: 'statut_label') String statutLabel,
      @JsonKey(name: 'statut_paiement') String statutPaiement,
      @JsonKey(name: 'methode_paiement') String methodePaiement,
      @JsonKey(name: 'mode_livraison') String? modeLivraison,
      @JsonKey(name: 'adresse_livraison') String? adresseLivraison,
      @JsonKey(name: 'notes_acheteur') String? notesAcheteur,
      @JsonKey(name: 'created_at') String? createdAt,
      List<Map<String, dynamic>> details});
}

/// @nodoc
class __$$CommandeImplCopyWithImpl<$Res>
    extends _$CommandeCopyWithImpl<$Res, _$CommandeImpl>
    implements _$$CommandeImplCopyWith<$Res> {
  __$$CommandeImplCopyWithImpl(
      _$CommandeImpl _value, $Res Function(_$CommandeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Commande
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? numeroCommande = null,
    Object? producteur = null,
    Object? total = null,
    Object? statut = null,
    Object? statutLabel = null,
    Object? statutPaiement = null,
    Object? methodePaiement = null,
    Object? modeLivraison = freezed,
    Object? adresseLivraison = freezed,
    Object? notesAcheteur = freezed,
    Object? createdAt = freezed,
    Object? details = null,
  }) {
    return _then(_$CommandeImpl(
      numeroCommande: null == numeroCommande
          ? _value.numeroCommande
          : numeroCommande // ignore: cast_nullable_to_non_nullable
              as String,
      producteur: null == producteur
          ? _value.producteur
          : producteur // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      statutLabel: null == statutLabel
          ? _value.statutLabel
          : statutLabel // ignore: cast_nullable_to_non_nullable
              as String,
      statutPaiement: null == statutPaiement
          ? _value.statutPaiement
          : statutPaiement // ignore: cast_nullable_to_non_nullable
              as String,
      methodePaiement: null == methodePaiement
          ? _value.methodePaiement
          : methodePaiement // ignore: cast_nullable_to_non_nullable
              as String,
      modeLivraison: freezed == modeLivraison
          ? _value.modeLivraison
          : modeLivraison // ignore: cast_nullable_to_non_nullable
              as String?,
      adresseLivraison: freezed == adresseLivraison
          ? _value.adresseLivraison
          : adresseLivraison // ignore: cast_nullable_to_non_nullable
              as String?,
      notesAcheteur: freezed == notesAcheteur
          ? _value.notesAcheteur
          : notesAcheteur // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      details: null == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommandeImpl implements _Commande {
  const _$CommandeImpl(
      {@JsonKey(name: 'numero_commande') required this.numeroCommande,
      @JsonKey(name: 'producteur_nom') this.producteur = '',
      required this.total,
      required this.statut,
      @JsonKey(name: 'statut_label') required this.statutLabel,
      @JsonKey(name: 'statut_paiement') required this.statutPaiement,
      @JsonKey(name: 'methode_paiement') this.methodePaiement = '',
      @JsonKey(name: 'mode_livraison') this.modeLivraison,
      @JsonKey(name: 'adresse_livraison') this.adresseLivraison,
      @JsonKey(name: 'notes_acheteur') this.notesAcheteur,
      @JsonKey(name: 'created_at') this.createdAt,
      final List<Map<String, dynamic>> details = const []})
      : _details = details;

  factory _$CommandeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommandeImplFromJson(json);

  @override
  @JsonKey(name: 'numero_commande')
  final String numeroCommande;
// Le backend expose 'producteur_nom' (pas d'objet 'producteur') sur
// les listes acheteur/producteur (CommandeProducteurSerializer).
  @override
  @JsonKey(name: 'producteur_nom')
  final String producteur;
  @override
  final String total;
  @override
  final String statut;
  @override
  @JsonKey(name: 'statut_label')
  final String statutLabel;
  @override
  @JsonKey(name: 'statut_paiement')
  final String statutPaiement;
  @override
  @JsonKey(name: 'methode_paiement')
  final String methodePaiement;
  @override
  @JsonKey(name: 'mode_livraison')
  final String? modeLivraison;
  @override
  @JsonKey(name: 'adresse_livraison')
  final String? adresseLivraison;
  @override
  @JsonKey(name: 'notes_acheteur')
  final String? notesAcheteur;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final List<Map<String, dynamic>> _details;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get details {
    if (_details is EqualUnmodifiableListView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_details);
  }

  @override
  String toString() {
    return 'Commande(numeroCommande: $numeroCommande, producteur: $producteur, total: $total, statut: $statut, statutLabel: $statutLabel, statutPaiement: $statutPaiement, methodePaiement: $methodePaiement, modeLivraison: $modeLivraison, adresseLivraison: $adresseLivraison, notesAcheteur: $notesAcheteur, createdAt: $createdAt, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommandeImpl &&
            (identical(other.numeroCommande, numeroCommande) ||
                other.numeroCommande == numeroCommande) &&
            (identical(other.producteur, producteur) ||
                other.producteur == producteur) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.statutLabel, statutLabel) ||
                other.statutLabel == statutLabel) &&
            (identical(other.statutPaiement, statutPaiement) ||
                other.statutPaiement == statutPaiement) &&
            (identical(other.methodePaiement, methodePaiement) ||
                other.methodePaiement == methodePaiement) &&
            (identical(other.modeLivraison, modeLivraison) ||
                other.modeLivraison == modeLivraison) &&
            (identical(other.adresseLivraison, adresseLivraison) ||
                other.adresseLivraison == adresseLivraison) &&
            (identical(other.notesAcheteur, notesAcheteur) ||
                other.notesAcheteur == notesAcheteur) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      numeroCommande,
      producteur,
      total,
      statut,
      statutLabel,
      statutPaiement,
      methodePaiement,
      modeLivraison,
      adresseLivraison,
      notesAcheteur,
      createdAt,
      const DeepCollectionEquality().hash(_details));

  /// Create a copy of Commande
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommandeImplCopyWith<_$CommandeImpl> get copyWith =>
      __$$CommandeImplCopyWithImpl<_$CommandeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommandeImplToJson(
      this,
    );
  }
}

abstract class _Commande implements Commande {
  const factory _Commande(
      {@JsonKey(name: 'numero_commande') required final String numeroCommande,
      @JsonKey(name: 'producteur_nom') final String producteur,
      required final String total,
      required final String statut,
      @JsonKey(name: 'statut_label') required final String statutLabel,
      @JsonKey(name: 'statut_paiement') required final String statutPaiement,
      @JsonKey(name: 'methode_paiement') final String methodePaiement,
      @JsonKey(name: 'mode_livraison') final String? modeLivraison,
      @JsonKey(name: 'adresse_livraison') final String? adresseLivraison,
      @JsonKey(name: 'notes_acheteur') final String? notesAcheteur,
      @JsonKey(name: 'created_at') final String? createdAt,
      final List<Map<String, dynamic>> details}) = _$CommandeImpl;

  factory _Commande.fromJson(Map<String, dynamic> json) =
      _$CommandeImpl.fromJson;

  @override
  @JsonKey(name: 'numero_commande')
  String
      get numeroCommande; // Le backend expose 'producteur_nom' (pas d'objet 'producteur') sur
// les listes acheteur/producteur (CommandeProducteurSerializer).
  @override
  @JsonKey(name: 'producteur_nom')
  String get producteur;
  @override
  String get total;
  @override
  String get statut;
  @override
  @JsonKey(name: 'statut_label')
  String get statutLabel;
  @override
  @JsonKey(name: 'statut_paiement')
  String get statutPaiement;
  @override
  @JsonKey(name: 'methode_paiement')
  String get methodePaiement;
  @override
  @JsonKey(name: 'mode_livraison')
  String? get modeLivraison;
  @override
  @JsonKey(name: 'adresse_livraison')
  String? get adresseLivraison;
  @override
  @JsonKey(name: 'notes_acheteur')
  String? get notesAcheteur;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  List<Map<String, dynamic>> get details;

  /// Create a copy of Commande
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommandeImplCopyWith<_$CommandeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
