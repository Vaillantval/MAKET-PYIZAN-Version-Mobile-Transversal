// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'pos_item.dart';

part 'pos_sale.freezed.dart';
part 'pos_sale.g.dart';

@freezed
class PosSale with _$PosSale {
  const factory PosSale({
    @JsonKey(name: 'idempotency_key') required String idempotencyKey,
    @JsonKey(name: 'numero_vente')    String? numeroVente,
    @Default([]) List<PosItem> items,
    @JsonKey(name: 'montant_total')   required double montantTotal,
    @JsonKey(name: 'methode_paiement') @Default('cash') String methodePaiement,
    @JsonKey(name: 'montant_wallet')  @Default(0) double montantWallet,
    @Default('en_attente') String statut,
    @JsonKey(name: 'vendue_le')       required String vendueLe,
    // Statut LOCAL de synchronisation : enAttente | synchronisee | rejetee
    @Default('enAttente') String syncStatus,
  }) = _PosSale;

  factory PosSale.fromJson(Map<String, dynamic> json) =>
      _$PosSaleFromJson(json);
}
