// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
class WalletCashback with _$WalletCashback {
  const factory WalletCashback({
    @Default(false) bool actif,
    @JsonKey(fromJson: jsonToDouble) @Default(0) double taux,
    // plafond == 0 signifie "pas de plafond"
    @JsonKey(fromJson: jsonToDouble) @Default(0) double plafond,
  }) = _WalletCashback;

  factory WalletCashback.fromJson(Map<String, dynamic> json) =>
      _$WalletCashbackFromJson(json);
}

@freezed
class WalletParrainage with _$WalletParrainage {
  const factory WalletParrainage({
    required String code,
    @JsonKey(name: 'taux_bonus', fromJson: jsonToDouble) @Default(0) double tauxBonus,
  }) = _WalletParrainage;

  factory WalletParrainage.fromJson(Map<String, dynamic> json) =>
      _$WalletParrainageFromJson(json);
}

@freezed
class WalletDepotHorsLigne with _$WalletDepotHorsLigne {
  const factory WalletDepotHorsLigne({
    @JsonKey(name: 'numero_moncash') String? numeroMoncash,
    @JsonKey(name: 'numero_natcash') String? numeroNatcash,
  }) = _WalletDepotHorsLigne;

  factory WalletDepotHorsLigne.fromJson(Map<String, dynamic> json) =>
      _$WalletDepotHorsLigneFromJson(json);
}

@freezed
class Wallet with _$Wallet {
  const factory Wallet({
    @JsonKey(fromJson: jsonToDouble) required double solde,
    @Default('HTG') String devise,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    WalletCashback? cashback,
    // null si la fonctionnalité de parrainage est désactivée
    WalletParrainage? parrainage,
    @JsonKey(name: 'depot_hors_ligne') WalletDepotHorsLigne? depotHorsLigne,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) =>
      _$WalletFromJson(json);
}
