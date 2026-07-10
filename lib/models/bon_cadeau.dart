// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bon_cadeau.freezed.dart';
part 'bon_cadeau.g.dart';

@freezed
class BonCadeau with _$BonCadeau {
  const factory BonCadeau({
    required int    id,
    required String code,
    required double montant,
    required String statut,
    @JsonKey(name: 'statut_display')        @Default('') String statutDisplay,
    @JsonKey(name: 'email_destinataire')    String? emailDestinataire,
    @JsonKey(name: 'offert_par')            String? offertPar,
    @JsonKey(name: 'created_at')            required String createdAt,
  }) = _BonCadeau;

  factory BonCadeau.fromJson(Map<String, dynamic> json) =>
      _$BonCadeauFromJson(json);
}
