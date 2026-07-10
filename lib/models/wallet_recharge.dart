// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_recharge.freezed.dart';
part 'wallet_recharge.g.dart';

@freezed
class WalletRecharge with _$WalletRecharge {
  const factory WalletRecharge({
    required int    id,
    required double montant,
    required String methode,
    @JsonKey(name: 'methode_display')  @Default('') String methodeDisplay,
    required String statut,
    @JsonKey(name: 'statut_display')   @Default('') String statutDisplay,
    @Default('') String reference,
    @JsonKey(name: 'created_at')       required String createdAt,
  }) = _WalletRecharge;

  factory WalletRecharge.fromJson(Map<String, dynamic> json) =>
      _$WalletRechargeFromJson(json);
}
