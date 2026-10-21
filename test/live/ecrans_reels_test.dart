// Écrans rendus avec les réponses réelles du serveur pour un compte
// (enregistrées par enregistrer_reponses.dart, fichier ML_REPONSES hors du
// dépôt). Ignoré sans ce fichier : ne fait pas partie de la suite normale.
//
//   ML_REPONSES=…/reponses_reelles.json flutter test test/live --update-goldens
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketlakay/features/pos/providers/pos_catalogue_provider.dart';
import 'package:maketlakay/features/pos/providers/pos_panier_provider.dart';
import 'package:maketlakay/router/app_router.dart';

import '../design/harness.dart';

void main() {
  final fichier = Platform.environment['ML_REPONSES'];
  if (fichier == null || !File(fichier).existsSync()) {
    test('écrans réels (ML_REPONSES absent)', () {}, skip: true);
    return;
  }
  final reponses = (jsonDecode(File(fichier).readAsStringSync()) as Map)['reponses'] as Map;
  final user = ((reponses['/api/auth/me/'] as Map)['data'] as Map)['data'] as Map<String, dynamic>;
  Map<String, dynamic> repondre(String path) {
    final r = reponses[path] as Map?;
    if (r != null && r['data'] is Map) return Map<String, dynamic>.from(r['data'] as Map);
    return {'success': true, 'data': <dynamic>[]};
  }

  setUpAll(chargerPolices);

  // Téléphone courant et terminal de caisse Sunmi (720×1440 px, 2x)
  for (final (appareil, taille) in [('tel', telephone), ('sunmi', const Size(360, 720))]) {
    for (final chemin in ['/pos/vente', '/pos/session', '/pos/historique', '/pos/profil']) {
      final nom = 'reel_${appareil}_${chemin.split('/').last}';
      testWidgets(nom, (tester) async {
        await monterApp(tester, chemin: chemin, utilisateur: user,
            taille: taille, repondre: repondre);
        await capture(tester, nom);
      });
    }

    testWidgets('reel_${appareil}_ajout_unite', (tester) async {
      final container = await monterApp(tester, chemin: '/pos/vente', utilisateur: user,
          taille: taille, repondre: repondre);
      // Premier produit vendu en plusieurs unités (pièce / caisse)
      final produits = container.read(posCatalogueProvider).value!;
      final multi = produits.firstWhere((p) => p.prix.length > 1, orElse: () => produits.first);
      await tester.tap(find.text(multi.nom).first);
      await laisserCharger(tester);
      expect(find.text('Ajouter au panier'), findsOneWidget);
      await capture(tester, 'reel_${appareil}_ajout_unite');
    });

    testWidgets('reel_${appareil}_panier_paiement', (tester) async {
      final container = await monterApp(tester, chemin: '/pos/vente', utilisateur: user,
          taille: taille, repondre: repondre);
      final produits = container.read(posCatalogueProvider).value!;
      final panier = container.read(posPanierProvider.notifier);
      for (final p in produits.take(3)) {
        panier.ajouter(produitId: p.id, nomProduit: p.nom, quantite: 2, prixUnitaire: p.prixDetail);
      }
      await laisserCharger(tester);
      await capture(tester, 'reel_${appareil}_vente_panier');
      await tester.tap(find.text('Voir le panier'));
      await laisserCharger(tester);
      await capture(tester, 'reel_${appareil}_panier');
      container.read(routerProvider).go('/pos/paiement');
      await laisserCharger(tester);
      await capture(tester, 'reel_${appareil}_paiement');
    });
  }
}
