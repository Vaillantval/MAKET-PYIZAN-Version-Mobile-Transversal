/// Erreurs métier POS nécessitant une réaction spécifique côté UI
/// (code de paiement invalide/expiré, solde insuffisant, connexion
/// perdue en plein paiement wallet).
class PosVenteException implements Exception {
  final String code; // CODE_INVALIDE | SOLDE_INSUFFISANT | OFFLINE | AUTRE
  final String message;

  const PosVenteException(this.code, this.message);

  @override
  String toString() => message;
}
