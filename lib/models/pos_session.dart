// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'pos_session.freezed.dart';
part 'pos_session.g.dart';

@freezed
class PosSession with _$PosSession {
  const factory PosSession({
    required int    id,
    required String statut,
    @JsonKey(name: 'fonds_ouverture', fromJson: jsonToDouble) required double fondsOuverture,
    @JsonKey(name: 'fonds_fermeture', fromJson: jsonToDoubleNullable) double? fondsFermeture,
    @JsonKey(name: 'ecart_caisse', fromJson: jsonToDoubleNullable)    double? ecartCaisse,
    @JsonKey(name: 'ouverte_le')      required String ouverteLe,
    @JsonKey(name: 'fermee_le')       String? fermeeLe,
  }) = _PosSession;

  factory PosSession.fromJson(Map<String, dynamic> json) =>
      _$PosSessionFromJson(json);
}
