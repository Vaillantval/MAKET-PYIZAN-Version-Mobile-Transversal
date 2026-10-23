// Tests de design : chaque écran principal est rendu dans l'app complète
// (router, shells, thème) avec des données réalistes, sur deux tailles de
// téléphone. Toute erreur de rendu (débordement RenderFlex, exception de
// build…) fait échouer le test. `--update-goldens` écrit les captures dans
// test/design/captures/ pour la revue visuelle.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'donnees.dart';
import 'harness.dart';

class _Ecran {
  final String nom;
  final String chemin;
  final Map<String, dynamic> Function() utilisateur;
  final int? entreprise;
  final bool visiteur;
  const _Ecran(this.nom, this.chemin, this.utilisateur,
      {this.entreprise, this.visiteur = false});
}

final _ecrans = [
  _Ecran('bienvenue',        '/bienvenue',              () => utilisateurAcheteur, visiteur: true),
  _Ecran('connexion',        '/login',                  () => utilisateurAcheteur),
  _Ecran('inscription',      '/register',               () => utilisateurAcheteur),
  _Ecran('mdp_oublie',       '/mot-de-passe-oublie',    () => utilisateurAcheteur),
  _Ecran('visiteur_accueil', '/acheteur/accueil',       () => utilisateurAcheteur, visiteur: true),
  _Ecran('visiteur_produit', '/acheteur/produit/produit-1', () => utilisateurAcheteur, visiteur: true),
  _Ecran('accueil',          '/acheteur/accueil',       () => utilisateurMembre),
  _Ecran('catalogue',        '/acheteur/catalogue',     () => utilisateurMembre),
  _Ecran('produit',          '/acheteur/produit/produit-1', () => utilisateurMembre),
  _Ecran('panier',           '/acheteur/panier',        () => utilisateurMembre),
  _Ecran('checkout',         '/acheteur/checkout',      () => utilisateurMembre),
  _Ecran('commandes',        '/acheteur/commandes',     () => utilisateurMembre),
  _Ecran('commande_detail',  '/acheteur/commande/CMD-2026-00128', () => utilisateurMembre),
  _Ecran('profil',           '/acheteur/profil',        () => utilisateurMembre),
  _Ecran('wallet',           '/acheteur/wallet',        () => utilisateurMembre),
  _Ecran('creer_entreprise', '/acheteur/entreprise/creer', () => utilisateurAcheteur),
  _Ecran('ent_dashboard',    '/producteur/dashboard',   () => utilisateurMembre, entreprise: 7),
  _Ecran('ent_commandes',    '/producteur/commandes',   () => utilisateurMembre, entreprise: 7),
  _Ecran('ent_produits',     '/producteur/catalogue',   () => utilisateurMembre, entreprise: 7),
  _Ecran('ent_collectes',    '/producteur/collectes',   () => utilisateurMembre, entreprise: 7),
  _Ecran('ent_profil',       '/producteur/profil',      () => utilisateurMembre, entreprise: 7),
  _Ecran('ent_fiche',        '/producteur/entreprise',  () => utilisateurMembre, entreprise: 7),
  _Ecran('ent_membres',      '/producteur/membres',     () => utilisateurMembre, entreprise: 7),
  _Ecran('ent_wallet',       '/producteur/wallet',      () => utilisateurMembre, entreprise: 7),
  _Ecran('ent_en_attente',   '/producteur/dashboard',   () => utilisateurEnAttente, entreprise: 9),
  _Ecran('collecteur',       '/collecteur/collectes',   () => utilisateurCollecteur),
  _Ecran('pos_vente',        '/pos/vente',              () => utilisateurCaissier),
  _Ecran('pos_session',      '/pos/session',            () => utilisateurCaissier),
  _Ecran('pos_historique',   '/pos/historique',         () => utilisateurCaissier),
  _Ecran('pos_profil',       '/pos/profil',             () => utilisateurCaissier),
  _Ecran('admin_dashboard',  '/admin/dashboard',        () => utilisateurAdmin),
  _Ecran('admin_commandes',  '/admin/commandes',        () => utilisateurAdmin),
  _Ecran('admin_paiements',  '/admin/paiements',        () => utilisateurAdmin),
  _Ecran('admin_entreprises','/admin/producteurs',      () => utilisateurAdmin),
  _Ecran('admin_plus',       '/admin/plus',             () => utilisateurAdmin),
  _Ecran('admin_catalogue',  '/admin/catalogue',        () => utilisateurAdmin),
  _Ecran('admin_stocks',     '/admin/stocks',           () => utilisateurAdmin),
  _Ecran('admin_collectes',  '/admin/collectes',        () => utilisateurAdmin),
  _Ecran('admin_users',      '/admin/utilisateurs',     () => utilisateurAdmin),
];

void main() {
  setUpAll(chargerPolices);

  for (final e in _ecrans) {
    testWidgets('${e.nom} (390×844)', (tester) async {
      await monterApp(tester, chemin: e.chemin, utilisateur: e.utilisateur(),
          entrepriseActive: e.entreprise, visiteur: e.visiteur);
      await capture(tester, e.nom);
    });

    testWidgets('${e.nom} (petit écran 320×640)', (tester) async {
      await monterApp(tester, chemin: e.chemin, utilisateur: e.utilisateur(),
          entrepriseActive: e.entreprise, visiteur: e.visiteur, taille: petitTelephone);
    });

    // Capture pleine hauteur pour la revue visuelle (--update-goldens)
    if (autoUpdateGoldenFiles) {
      testWidgets('${e.nom} (long)', (tester) async {
        await monterApp(tester, chemin: e.chemin, utilisateur: e.utilisateur(),
            entrepriseActive: e.entreprise, visiteur: e.visiteur, taille: const Size(390, 1900));
        await capture(tester, '${e.nom}_long');
      });
    }
  }
}
