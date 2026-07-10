// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_retrait.freezed.dart';
part 'wallet_retrait.g.dart';

@freezed
class WalletRetrait with _$WalletRetrait {
  const factory WalletRetrait({
    required int    id,
    required double montant,
    required String canal,
    @JsonKey(name: 'canal_display')      @Default('') String canalDisplay,
    @JsonKey(name: 'numero_telephone')   required String numeroTelephone,
    required String statut,
    @JsonKey(name: 'statut_display')     @Default('') String statutDisplay,
    @JsonKey(name: 'created_at')         required String createdAt,
  }) = _WalletRetrait;

  factory WalletRetrait.fromJson(Map<String, dynamic> json) =>
      _$WalletRetraitFromJson(json);
}
