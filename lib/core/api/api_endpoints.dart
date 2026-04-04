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

  // Système
  static const String healthCheck    = '/health/';
  static const String faq            = '/faq/';
  static const String contact        = '/contact/';
}
