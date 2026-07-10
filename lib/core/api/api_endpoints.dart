import '../constants/app_constants.dart';

class AppEndpoints {
  static const String baseUrl = AppConstants.baseUrl;

  // Auth
  static const String register       = '/api/auth/register/';
  static const String login          = '/api/auth/login/';
  static const String logout         = '/api/auth/logout/';
  static const String tokenRefresh   = '/api/auth/token/refresh/';
  static const String me             = '/api/auth/me/';
  static const String changePassword = '/api/auth/change-password/';
  static const String fcmToken       = '/api/auth/fcm-token/';

  // Adresses
  static const String adresses       = '/api/auth/adresses/';
  static String adresseDetail(int id) => '/api/auth/adresses/$id/';
  static String adresseDefault(int id) => '/api/auth/adresses/$id/default/';

  // Commandes acheteur
  static const String mesCommandes      = '/api/auth/commandes/';
  static String maCommande(String num)  => '/api/auth/commandes/$num/';

  // Dashboard producteur
  static const String producteurStats    = '/api/auth/producteur/stats/';
  static const String producteurProfil   = '/api/auth/producteur/profil/';
  static const String producteurCommandes = '/api/auth/producteur/commandes/';
  static String producteurCommande(String num) =>
      '/api/auth/producteur/commandes/$num/';
  static String producteurCommandeStatut(String num) =>
      '/api/auth/producteur/commandes/$num/statut/';

  // Catalogue
  static const String produits      = '/api/products/';
  static const String categories    = '/api/products/categories/';
  static String produitDetail(String slug) => '/api/products/public/$slug/';
  static const String mesProduits   = '/api/products/mes-produits/';
  static String monProduit(String slug) => '/api/products/mes-produits/$slug/';

  // Panier
  static const String panier        = '/api/orders/panier/';
  static const String panierAjouter = '/api/orders/panier/ajouter/';
  static String panierModifier(String slug) =>
      '/api/orders/panier/modifier/$slug/';
  static String panierRetirer(String slug) =>
      '/api/orders/panier/retirer/$slug/';
  static const String panierVider   = '/api/orders/panier/vider/';
  static const String commander     = '/api/orders/commander/';

  // Paiements
  static const String initierPaiement  = '/api/payments/initier/';
  static const String soumettrePreuve  = '/api/payments/preuve/';
  static const String verifierPaiement = '/api/payments/verifier/';
  static const String mesPaiements     = '/api/payments/mes-paiements/';
  static const String validerVoucher   = '/api/payments/voucher/valider/';
  static const String mesVouchers      = '/api/payments/voucher/mes-vouchers/';

  // Collectes
  static const String mesParticipations = '/api/collectes/mes-participations/';
  static String confirmerParticipation(int id) =>
      '/api/collectes/participations/$id/confirmer/';

  // Géographie
  static const String departements   = '/api/geo/departements/';
  static const String communes       = '/api/geo/communes/';
  static const String sections       = '/api/geo/sections/';
  static const String geoArbre       = '/api/geo/arbre/';
  static const String geoRecherche   = '/api/geo/recherche/';

  // Admin
  static const String adminStats     = '/api/admin/stats/';
  static const String adminOptions   = '/api/admin/options/';
  static const String adminUsers     = '/api/admin/users/';
  static const String adminProducteurs = '/api/admin/producteurs/';
  static const String adminCommandes = '/api/admin/commandes/';
  static const String adminPaiements = '/api/admin/paiements/';
  static const String adminCatalogue = '/api/admin/catalogue/';
  static const String adminStocks    = '/api/admin/stocks/lots/';
  static const String adminAlertes   = '/api/admin/stocks/alertes/';
  static const String adminCollectes = '/api/admin/collectes/';

  // Wallet (portefeuille prépayé HTG)
  static const String wallet                  = '/api/wallet/';
  static const String walletTransactions      = '/api/wallet/transactions/';
  static const String walletRecharges         = '/api/wallet/recharges/';
  static const String walletRechargeInitier   = '/api/wallet/recharge/initier/';
  static const String walletRechargeVerifier  = '/api/wallet/recharge/verifier/';
  static const String walletRechargeHorsLigne = '/api/wallet/recharge/hors-ligne/';
  static const String walletPayer             = '/api/wallet/payer/';
  static const String walletPayerPartiel      = '/api/wallet/payer-partiel/';
  static const String walletRetrait           = '/api/wallet/retrait/';
  static const String walletRetraits          = '/api/wallet/retraits/';
  static const String walletBonAcheter        = '/api/wallet/bon/acheter/';
  static const String walletBonVerifier       = '/api/wallet/bon/verifier/';
  static const String walletBonEncaisser      = '/api/wallet/bon/encaisser/';
  static const String walletBons              = '/api/wallet/bons/';
  static const String walletBonsRecus         = '/api/wallet/bons/recus/';
  static const String walletCodePaiement      = '/api/wallet/code-paiement/';

  // POS (point de vente comptoir)
  static const String posSessionOuvrir  = '/api/pos/session/ouvrir/';
  static const String posSessionFermer  = '/api/pos/session/fermer/';
  static const String posVente          = '/api/pos/vente/';
  static const String posSync           = '/api/pos/sync/';
  static const String posCatalogue      = '/api/pos/catalogue/';
  static const String posRapports       = '/api/pos/rapports/';
  static const String posVerifierCodeClient = '/api/pos/client/verifier-code/';

  // Système
  static const String healthCheck    = '/health/';
  static const String faq            = '/faq/';
  static const String contact        = '/contact/';
}
