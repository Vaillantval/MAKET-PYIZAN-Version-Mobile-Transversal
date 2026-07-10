// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pos_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PosSession _$PosSessionFromJson(Map<String, dynamic> json) {
  return _PosSession.fromJson(json);
}

/// @nodoc
mixin _$PosSession {
  int get id => throw _privateConstructorUsedError;
  String get statut => throw _privateConstructorUsedError;
  @JsonKey(name: 'fonds_ouverture')
  double get fondsOuverture => throw _privateConstructorUsedError;
  @JsonKey(name: 'fonds_fermeture')
  double? get fondsFermeture => throw _privateConstructorUsedError;
  @JsonKey(name: 'ecart_caisse')
  double? get ecartCaisse => throw _privateConstructorUsedError;
  @JsonKey(name: 'ouverte_le')
  String get ouverteLe => throw _privateConstructorUsedError;
  @JsonKey(name: 'fermee_le')
  String? get fermeeLe => throw _privateConstructorUsedError;

  /// Serializes this PosSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosSessionCopyWith<PosSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosSessionCopyWith<$Res> {
  factory $PosSessionCopyWith(
          PosSession value, $Res Function(PosSession) then) =
      _$PosSessionCopyWithImpl<$Res, PosSession>;
  @useResult
  $Res call(
      {int id,
      String statut,
      @JsonKey(name: 'fonds_ouverture') double fondsOuverture,
      @JsonKey(name: 'fonds_fermeture') double? fondsFermeture,
      @JsonKey(name: 'ecart_caisse') double? ecartCaisse,
      @JsonKey(name: 'ouverte_le') String ouverteLe,
      @JsonKey(name: 'fermee_le') String? fermeeLe});
}

/// @nodoc
class _$PosSessionCopyWithImpl<$Res, $Val extends PosSession>
    implements $PosSessionCopyWith<$Res> {
  _$PosSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? statut = null,
    Object? fondsOuverture = null,
    Object? fondsFermeture = freezed,
    Object? ecartCaisse = freezed,
    Object? ouverteLe = null,
    Object? fermeeLe = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      fondsOuverture: null == fondsOuverture
          ? _value.fondsOuverture
          : fondsOuverture // ignore: cast_nullable_to_non_nullable
              as double,
      fondsFermeture: freezed == fondsFermeture
          ? _value.fondsFermeture
          : fondsFermeture // ignore: cast_nullable_to_non_nullable
              as double?,
      ecartCaisse: freezed == ecartCaisse
          ? _value.ecartCaisse
          : ecartCaisse // ignore: cast_nullable_to_non_nullable
              as double?,
      ouverteLe: null == ouverteLe
          ? _value.ouverteLe
          : ouverteLe // ignore: cast_nullable_to_non_nullable
              as String,
      fermeeLe: freezed == fermeeLe
          ? _value.fermeeLe
          : fermeeLe // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PosSessionImplCopyWith<$Res>
    implements $PosSessionCopyWith<$Res> {
  factory _$$PosSessionImplCopyWith(
          _$PosSessionImpl value, $Res Function(_$PosSessionImpl) then) =
      __$$PosSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String statut,
      @JsonKey(name: 'fonds_ouverture') double fondsOuverture,
      @JsonKey(name: 'fonds_fermeture') double? fondsFermeture,
      @JsonKey(name: 'ecart_caisse') double? ecartCaisse,
      @JsonKey(name: 'ouverte_le') String ouverteLe,
      @JsonKey(name: 'fermee_le') String? fermeeLe});
}

/// @nodoc
class __$$PosSessionImplCopyWithImpl<$Res>
    extends _$PosSessionCopyWithImpl<$Res, _$PosSessionImpl>
    implements _$$PosSessionImplCopyWith<$Res> {
  __$$PosSessionImplCopyWithImpl(
      _$PosSessionImpl _value, $Res Function(_$PosSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PosSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? statut = null,
    Object? fondsOuverture = null,
    Object? fondsFermeture = freezed,
    Object? ecartCaisse = freezed,
    Object? ouverteLe = null,
    Object? fermeeLe = freezed,
  }) {
    return _then(_$PosSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      fondsOuverture: null == fondsOuverture
          ? _value.fondsOuverture
          : fondsOuverture // ignore: cast_nullable_to_non_nullable
              as double,
      fondsFermeture: freezed == fondsFermeture
          ? _value.fondsFermeture
          : fondsFermeture // ignore: cast_nullable_to_non_nullable
              as double?,
      ecartCaisse: freezed == ecartCaisse
          ? _value.ecartCaisse
          : ecartCaisse // ignore: cast_nullable_to_non_nullable
              as double?,
      ouverteLe: null == ouverteLe
          ? _value.ouverteLe
          : ouverteLe // ignore: cast_nullable_to_non_nullable
              as String,
      fermeeLe: freezed == fermeeLe
          ? _value.fermeeLe
          : fermeeLe // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PosSessionImpl implements _PosSession {
  const _$PosSessionImpl(
      {required this.id,
      required this.statut,
      @JsonKey(name: 'fonds_ouverture') required this.fondsOuverture,
      @JsonKey(name: 'fonds_fermeture') this.fondsFermeture,
      @JsonKey(name: 'ecart_caisse') this.ecartCaisse,
      @JsonKey(name: 'ouverte_le') required this.ouverteLe,
      @JsonKey(name: 'fermee_le') this.fermeeLe});

  factory _$PosSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosSessionImplFromJson(json);

  @override
  final int id;
  @override
  final String statut;
  @override
  @JsonKey(name: 'fonds_ouverture')
  final double fondsOuverture;
  @override
  @JsonKey(name: 'fonds_fermeture')
  final double? fondsFermeture;
  @override
  @JsonKey(name: 'ecart_caisse')
  final double? ecartCaisse;
  @override
  @JsonKey(name: 'ouverte_le')
  final String ouverteLe;
  @override
  @JsonKey(name: 'fermee_le')
  final String? fermeeLe;

  @override
  String toString() {
    return 'PosSession(id: $id, statut: $statut, fondsOuverture: $fondsOuverture, fondsFermeture: $fondsFermeture, ecartCaisse: $ecartCaisse, ouverteLe: $ouverteLe, fermeeLe: $fermeeLe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.fondsOuverture, fondsOuverture) ||
                other.fondsOuverture == fondsOuverture) &&
            (identical(other.fondsFermeture, fondsFermeture) ||
                other.fondsFermeture == fondsFermeture) &&
            (identical(other.ecartCaisse, ecartCaisse) ||
                other.ecartCaisse == ecartCaisse) &&
            (identical(other.ouverteLe, ouverteLe) ||
                other.ouverteLe == ouverteLe) &&
            (identical(other.fermeeLe, fermeeLe) ||
                other.fermeeLe == fermeeLe));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, statut, fondsOuverture,
      fondsFermeture, ecartCaisse, ouverteLe, fermeeLe);

  /// Create a copy of PosSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosSessionImplCopyWith<_$PosSessionImpl> get copyWith =>
      __$$PosSessionImplCopyWithImpl<_$PosSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PosSessionImplToJson(
      this,
    );
  }
}

abstract class _PosSession implements PosSession {
  const factory _PosSession(
      {required final int id,
      required final String statut,
      @JsonKey(name: 'fonds_ouverture') required final double fondsOuverture,
      @JsonKey(name: 'fonds_fermeture') final double? fondsFermeture,
      @JsonKey(name: 'ecart_caisse') final double? ecartCaisse,
      @JsonKey(name: 'ouverte_le') required final String ouverteLe,
      @JsonKey(name: 'fermee_le') final String? fermeeLe}) = _$PosSessionImpl;

  factory _PosSession.fromJson(Map<String, dynamic> json) =
      _$PosSessionImpl.fromJson;

  @override
  int get id;
  @override
  String get statut;
  @override
  @JsonKey(name: 'fonds_ouverture')
  double get fondsOuverture;
  @override
  @JsonKey(name: 'fonds_fermeture')
  double? get fondsFermeture;
  @override
  @JsonKey(name: 'ecart_caisse')
  double? get ecartCaisse;
  @override
  @JsonKey(name: 'ouverte_le')
  String get ouverteLe;
  @override
  @JsonKey(name: 'fermee_le')
  String? get fermeeLe;

  /// Create a copy of PosSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosSessionImplCopyWith<_$PosSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
