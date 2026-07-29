// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unite_mesure.freezed.dart';
part 'unite_mesure.g.dart';

/// GET /api/products/unites-mesure/ (public) — unités de mesure
/// disponibles pour le prix de base et les prix supplémentaires d'un
/// produit (kg, tonne, sac 50 kg, botte, pièce...).
@freezed
class UniteMesure with _$UniteMesure {
  const factory UniteMesure({
    required int    id,
    required String code,
    required String nom,
    @Default(0) int ordre,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _UniteMesure;

  factory UniteMesure.fromJson(Map<String, dynamic> json) =>
      _$UniteMesureFromJson(json);
}
