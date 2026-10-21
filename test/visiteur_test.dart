// Parcours visiteur : la boutique se consulte sans compte, le reste
// demande de se connecter puis y ramène.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketlakay/router/app_router.dart';

import 'design/donnees.dart';
import 'design/harness.dart';

String _lieu(ProviderContainer container) =>
    container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString();

void main() {
  setUpAll(chargerPolices);

  testWidgets("au premier lancement, l'accueil s'affiche sans connexion", (tester) async {
    final c = await monterApp(tester, chemin: '/splash', visiteur: true);
    expect(_lieu(c), '/acheteur/accueil');
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('la boutique et les fiches produits sont publiques', (tester) async {
    var c = await monterApp(tester, chemin: '/acheteur/catalogue', visiteur: true);
    expect(_lieu(c), '/acheteur/catalogue');
    c = await monterApp(tester, chemin: '/acheteur/produit/produit-1', visiteur: true);
    expect(_lieu(c), '/acheteur/produit/produit-1');
  });

  testWidgets('le panier demande de se connecter et retient où revenir', (tester) async {
    final c = await monterApp(tester, chemin: '/acheteur/panier', visiteur: true);
    expect(_lieu(c), '/login?from=%2Facheteur%2Fpanier');
  });

  testWidgets('ajouter au panier en visiteur propose la connexion', (tester) async {
    await monterApp(tester, chemin: '/acheteur/produit/produit-1', visiteur: true);
    await tester.tap(find.text('Ajouter au panier'));
    await laisserCharger(tester);
    expect(find.text('Connectez-vous'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Créer un compte'), findsOneWidget);
  });

  testWidgets("une fois connecté, on revient sur l'écran demandé", (tester) async {
    final c = await monterApp(tester,
        chemin: '/login?from=%2Facheteur%2Fproduit%2Fproduit-1',
        utilisateur: utilisateurAcheteur);
    expect(_lieu(c), '/acheteur/produit/produit-1');
  });
}
