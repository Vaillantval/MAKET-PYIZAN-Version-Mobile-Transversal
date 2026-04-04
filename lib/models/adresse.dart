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
    @Default('') String sectionCommunale,
    @Default('') String telephone,
    @Default('') String instructions,
    @Default(false) bool isDefault,
  }) = _Adresse;

  factory Adresse.fromJson(Map<String, dynamic> json) =>
      _$AdresseFromJson(json);
}
