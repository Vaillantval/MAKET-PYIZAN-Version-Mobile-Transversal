// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'entreprise.freezed.dart';
part 'entreprise.g.dart';

/// Appartenance du compte connecté à une entreprise, telle que renvoyée
/// dans `entreprises` par GET /api/auth/me/.
///
/// Vendre ne dépend plus du rôle du compte (l'ancien rôle « producteur »
/// n'existe plus) mais de cette appartenance : un même compte peut être
/// membre de plusieurs entreprises, avec un rôle propre à chacune.
@freezed
class EntrepriseMembre with _$EntrepriseMembre {
  const EntrepriseMembre._();

  const factory EntrepriseMembre({
    required int    id,
    @JsonKey(name: 'membre_id') int? membreId,
    @Default('')    String nom,
    /// producteur | fournisseur | entreprise
    @Default('producteur') String type,
    @JsonKey(name: 'type_label') @Default('') String typeLabel,
    /// en_attente | actif | suspendu | inactif
    @Default('en_attente') String statut,
    @Default('')    String code,
    /// proprietaire | gestionnaire
    @Default('gestionnaire') String role,
    @JsonKey(name: 'role_label') @Default('') String roleLabel,
  }) = _EntrepriseMembre;

  factory EntrepriseMembre.fromJson(Map<String, dynamic> json) =>
      _$EntrepriseMembreFromJson(json);

  bool get estProprietaire => role == 'proprietaire';
  bool get estActive       => statut == 'actif';
  bool get estEnAttente    => statut == 'en_attente';
}
