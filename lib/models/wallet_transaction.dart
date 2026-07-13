// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'wallet_transaction.freezed.dart';
part 'wallet_transaction.g.dart';

@freezed
class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required int    id,
    required String type,
    @JsonKey(name: 'type_display')  @Default('') String typeDisplay,
    @JsonKey(fromJson: jsonToDouble) required double montant,
    @JsonKey(name: 'solde_apres', fromJson: jsonToDouble) required double soldeApres,
    @JsonKey(name: 'commande_numero') String? commandeNumero,
    @Default('') String description,
    @Default('') String reference,
    @JsonKey(name: 'created_at')    required String createdAt,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);
}
