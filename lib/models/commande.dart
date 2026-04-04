import 'package:freezed_annotation/freezed_annotation.dart';

part 'commande.freezed.dart';
part 'commande.g.dart';

@freezed
class Commande with _$Commande {
  const factory Commande({
    required String numeroCommande,
    required String producteur,
    required String total,
    required String statut,
    required String statutLabel,
    required String statutPaiement,
    @Default('') String methodePaiement,
    String? modeLivraison,
    String? adresseLivraison,
    String? notesAcheteur,
    String? createdAt,
    @Default([]) List<Map<String, dynamic>> details,
  }) = _Commande;

  factory Commande.fromJson(Map<String, dynamic> json) =>
      _$CommandeFromJson(json);
}
