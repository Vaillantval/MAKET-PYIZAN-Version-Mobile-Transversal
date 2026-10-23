// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'produit.freezed.dart';
part 'produit.g.dart';

@freezed
class Produit with _$Produit {
  const factory Produit({
    required int    id,
    required String nom,
    required String slug,
    @Default('') String variete,
    @Default('') String description,
    @JsonKey(name: 'prix_unitaire')     required String prixUnitaire,
    // Prix avant remise (promotion) ; absent ou ≤ prix_unitaire : pas de promo
    @JsonKey(name: 'prix_original')     String? prixOriginal,
    @JsonKey(name: 'unite_vente')       required String uniteVente,
    @JsonKey(name: 'unite_vente_label') required String uniteVenteLabel,
    @JsonKey(name: 'unite_vente_id')    int? uniteVenteId,
    // Autres unités de vente (caisse, sac…) : unite_id, unite_nom, prix,
    // facteur_conversion (unités de base par unité)
    @JsonKey(name: 'prix_supplementaires') @Default([]) List<Map<String, dynamic>> prixSupplementaires,
    @JsonKey(name: 'quantite_min_commande') @Default(1) int quantiteMinCommande,
    @JsonKey(name: 'stock_reel')        @Default(0) int stockReel,
    @JsonKey(name: 'is_featured')       @Default(false) bool isFeatured,
    @JsonKey(name: 'image_principale')  String? imagePrincipale,
    Map<String, dynamic>? categorie,
    Map<String, dynamic>? producteur,
    @Default('') String origine,
    @Default('') String saison,
    @JsonKey(name: 'created_at')        String? createdAt,
  }) = _Produit;

  factory Produit.fromJson(Map<String, dynamic> json) =>
      _$ProduitFromJson(json);
}

extension ProduitPromo on Produit {
  /// Remise en pourcentage (arrondie), ou null sans promotion.
  int? get remisePourcent {
    final avant = double.tryParse(prixOriginal ?? '');
    final apres = double.tryParse(prixUnitaire);
    if (avant == null || apres == null || avant <= 0 || apres >= avant) return null;
    final pct = ((avant - apres) / avant * 100).round();
    return pct > 0 ? pct : null;
  }
}
