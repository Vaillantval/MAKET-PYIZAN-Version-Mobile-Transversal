// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_code_paiement.freezed.dart';
part 'wallet_code_paiement.g.dart';

@freezed
class WalletCodePaiement with _$WalletCodePaiement {
  const factory WalletCodePaiement({
    required String code,
    @JsonKey(name: 'expire_dans') required int expireDans, // secondes
    required double solde,
  }) = _WalletCodePaiement;

  factory WalletCodePaiement.fromJson(Map<String, dynamic> json) =>
      _$WalletCodePaiementFromJson(json);
}
