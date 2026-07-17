// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'commande.freezed.dart';
part 'commande.g.dart';

@freezed
class Commande with _$Commande {
  const factory Commande({
    @JsonKey(name: 'numero_commande')  required String numeroCommande,
    // Le backend expose 'producteur_nom' (pas d'objet 'producteur') sur
    // les listes acheteur/producteur (CommandeProducteurSerializer).
    @JsonKey(name: 'producteur_nom')   @Default('') String producteur,
    required String total,
    required String statut,
    @JsonKey(name: 'statut_label')     required String statutLabel,
    @JsonKey(name: 'statut_paiement')  required String statutPaiement,
    @JsonKey(name: 'methode_paiement') @Default('') String methodePaiement,
    @JsonKey(name: 'mode_livraison')   String? modeLivraison,
    @JsonKey(name: 'adresse_livraison') String? adresseLivraison,
    @JsonKey(name: 'notes_acheteur')   String? notesAcheteur,
    @JsonKey(name: 'created_at')       String? createdAt,
    @Default([]) List<Map<String, dynamic>> details,
  }) = _Commande;

  factory Commande.fromJson(Map<String, dynamic> json) =>
      _$CommandeFromJson(json);
}
