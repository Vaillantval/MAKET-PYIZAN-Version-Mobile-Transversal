// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';
import 'pos_item.dart';

part 'pos_sale.freezed.dart';
part 'pos_sale.g.dart';

// Sans toJson explicite par élément, le toJson() généré imbrique les
// objets PosItem bruts (pas leur Map JSON) dans 'items' — jsonEncode()
// le tolère en silence pour les requêtes HTTP (Dio) mais Hive le rejette
// avec "Cannot write, unknown type: _$PosItemImpl" (pas de TypeAdapter
// enregistré — le stockage local de saveSale() attend des Map pures).
// @JsonSerializable(explicitToJson: true) au niveau classe ne suffit
// pas ici : freezed génère le (dé)sérialiseur réellement utilisé
// (_$$PosSaleImplToJson) séparément et ne le propage pas — d'où un
// convertisseur explicite par champ, seul moyen fiable.
List<Map<String, dynamic>> _itemsToJson(List<PosItem> items) =>
    items.map((e) => e.toJson()).toList();

@freezed
class PosSale with _$PosSale {
  const factory PosSale({
    @JsonKey(name: 'idempotency_key') required String idempotencyKey,
    @JsonKey(name: 'numero_vente')    String? numeroVente,
    @JsonKey(toJson: _itemsToJson) @Default([]) List<PosItem> items,
    @JsonKey(name: 'montant_total', fromJson: jsonToDouble)   required double montantTotal,
    @JsonKey(name: 'methode_paiement') @Default('cash') String methodePaiement,
    @JsonKey(name: 'montant_wallet', fromJson: jsonToDouble)  @Default(0) double montantWallet,
    @Default('en_attente') String statut,
    @JsonKey(name: 'vendue_le')       required String vendueLe,
    // Statut LOCAL de synchronisation : enAttente | synchronisee | rejetee
    @Default('enAttente') String syncStatus,
    // Champs LOCAUX renseignés par la réponse de POST /api/pos/sync/
    @JsonKey(name: 'stock_conflict') @Default(false) bool stockConflict,
    @JsonKey(name: 'erreur_sync')    String? erreurSync,
  }) = _PosSale;

  factory PosSale.fromJson(Map<String, dynamic> json) =>
      _$PosSaleFromJson(json);
}
