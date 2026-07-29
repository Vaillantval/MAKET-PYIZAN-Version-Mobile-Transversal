// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'pos_item.freezed.dart';
part 'pos_item.g.dart';

@freezed
class PosItem with _$PosItem {
  const factory PosItem({
    @JsonKey(name: 'produit_id')    required int    produitId,
    @JsonKey(name: 'nom_produit')   @Default('') String nomProduit,
    @JsonKey(name: 'lot_id')        int? lotId,
    // Optionnel : défaut = unité de base du produit côté serveur si
    // absent (comportement inchangé). Dès renseigné, quantite et
    // prixUnitaire s'entendent dans CETTE unité (ex: 2 sacs, pas 100 kg).
    @JsonKey(name: 'unite_id')      int? uniteId,
    // Affichage/calcul LOCAL uniquement (panier, reçu, décrément du
    // stock en cache) — jamais envoyés au serveur, qui les redétermine
    // lui-même depuis unite_id.
    @JsonKey(name: 'unite_code')    String? uniteCode,
    @JsonKey(name: 'unite_nom')     String? uniteNom,
    // Combien d'unités de base (le stock est toujours suivi dans
    // l'unité de base) représente 1 unité vendue. 1 par défaut (unité
    // de base elle-même).
    @JsonKey(name: 'facteur_conversion', fromJson: jsonToDouble) @Default(1) double facteurConversion,
    @JsonKey(fromJson: jsonToDouble) required double quantite,
    @JsonKey(name: 'prix_unitaire', fromJson: jsonToDouble) required double prixUnitaire,
    @JsonKey(name: 'sous_total', fromJson: jsonToDouble)    @Default(0) double sousTotal,
  }) = _PosItem;

  factory PosItem.fromJson(Map<String, dynamic> json) =>
      _$PosItemFromJson(json);
}

/// Payload minimal attendu par le backend pour une ligne de vente
/// (exclut les champs d'affichage local : nom_produit, sous_total,
/// unite_code, unite_nom).
extension PosItemPayload on PosItem {
  Map<String, dynamic> toPayload() => {
    'produit_id': produitId,
    if (lotId != null) 'lot_id': lotId,
    if (uniteId != null) 'unite_id': uniteId,
    'quantite': quantite,
    'prix_unitaire': prixUnitaire,
  };
}
