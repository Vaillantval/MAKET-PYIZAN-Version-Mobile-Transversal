// Annonces de l'accueil : les slides du site, dans l'app.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketpeyizan/features/acheteur/providers/annonces_provider.dart';
import 'package:maketpeyizan/router/app_router.dart';

import 'design/donnees.dart';
import 'design/harness.dart';

String _lieu(ProviderContainer c) =>
    c.read(routerProvider).routerDelegate.currentConfiguration.uri.toString();

// Les 4 slides actives en production (octobre 2026)
final _slides = [
  {'id': 2, 'titre': 'Produits frais, directement du marche',
   'sous_titre': "Achetez vos legumes et fruits frais recoltes localement, livres jusqu'a vous.",
   'texte_bouton': 'Voir le catalogue', 'lien': '#catalogue',
   'image': 'https://maketpeyizan.ht/media/slider/slide_1.jpg', 'ordre': 0},
  {'id': 1, 'titre': 'Makèt Peyizan', 'sous_titre': 'Tout kalite pwodui',
   'texte_bouton': 'Découvrir', 'lien': '#catalogue',
   'image': 'https://maketpeyizan.ht/media/slider/poivron_4.jpg', 'ordre': 1},
  {'id': 3, 'titre': "Vendez vos recoltes, touchez plus d'acheteurs",
   'sous_titre': 'Rejoignez Makèt Peyizan et vendez directement aux consommateurs.',
   'texte_bouton': 'Devenir producteur', 'lien': '/inscription/',
   'image': 'https://maketpeyizan.ht/media/slider/slide_2.jpg', 'ordre': 2},
];

void main() {
  setUpAll(() async {
    await chargerPolices();
    // Cache des images du carrousel : dossier temporaire (pas de réseau
    // en test, les images tombent sur leur fond de secours)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => Directory.systemTemp.path);
  });

  group('liens des annonces', () {
    test("les liens du site mènent à l'écran de l'app", () {
      expect(routeAnnonce('#catalogue')!.route, '/acheteur/catalogue');
      expect(routeAnnonce('/inscription/')!.route, '/register');
      expect(routeAnnonce('/connexion/')!.route, '/login');
      expect(routeAnnonce('/panier/')!.route, '/acheteur/panier');
      expect(routeAnnonce('/produits/cafe-moulu/')!.route, '/acheteur/produit/cafe-moulu');
      expect(routeAnnonce('https://maketpeyizan.ht/produits/cafe-moulu/')!.route,
          '/acheteur/produit/cafe-moulu');
      final cat = routeAnnonce('/catalogue/?categorie=fruits')!;
      expect(cat.route, '/acheteur/catalogue');
      expect(cat.categorie, 'fruits');
    });

    test('les autres pages du site et les sites externes : navigateur', () {
      expect(routeAnnonce('/apropos/')!.web.toString(), 'https://maketpeyizan.ht/apropos/');
      expect(routeAnnonce('https://moncash.ht/promo')!.web.toString(), 'https://moncash.ht/promo');
    });

    test('lien vide ou invalide : pas de destination', () {
      expect(routeAnnonce(''), isNull);
      expect(routeAnnonce('javascript:alert(1)'), isNull);
    });
  });

  testWidgets("l'accueil public affiche les annonces et ouvre leur lien", (tester) async {
    final c = await monterApp(tester,
        chemin: '/acheteur/accueil',
        visiteur: true,
        repondre: (p) => p == '/api/home/slider/'
            ? {'success': true, 'data': _slides}
            : reponseFactice(p, utilisateurAcheteur));

    expect(find.text('Produits frais, directement du marche'), findsOneWidget);
    expect(find.text('Voir le catalogue'), findsOneWidget);
    // Le bandeau fixe laisse la place au carrousel
    expect(find.text('Direct producteur'), findsNothing);

    await tester.tap(find.text('Voir le catalogue'));
    await laisserCharger(tester);
    expect(_lieu(c), '/acheteur/catalogue');

    // Laisser expirer les minuteries du cache d'images
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets("sans annonce, l'accueil garde son bandeau", (tester) async {
    await monterApp(tester, chemin: '/acheteur/accueil', visiteur: true);
    expect(find.text('Direct producteur'), findsOneWidget);
  });
}
