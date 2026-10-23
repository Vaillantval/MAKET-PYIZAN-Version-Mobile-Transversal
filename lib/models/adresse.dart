// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'adresse.freezed.dart';
part 'adresse.g.dart';

@freezed
class Adresse with _$Adresse {
  const factory Adresse({
    required int    id,
    required String rue,
    required String commune,
    required String departement,
    @JsonKey(name: 'section_communale') @Default('') String sectionCommunale,
    @Default('') String telephone,
    // Backend : champ libre 'details' (pas 'instructions')
    @JsonKey(name: 'details') @Default('') String instructions,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _Adresse;

  factory Adresse.fromJson(Map<String, dynamic> json) =>
      _$AdresseFromJson(json);
}

extension AdresseAffichage on Adresse {
  /// Libellé du département à partir du code serveur (« sud_est » →
  /// « Sud-Est », « grand_anse » → « Grand-Anse »).
  String get departementLabel => departement
      .split('_')
      .where((m) => m.isNotEmpty)
      .map((m) => m[0].toUpperCase() + m.substring(1))
      .join('-');
}
