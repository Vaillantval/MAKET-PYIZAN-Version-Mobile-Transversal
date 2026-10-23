// Écrans de caisse avec un panier rempli (barre du panier, paiement),
// rendus sur deux tailles de téléphone.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketpeyizan/features/pos/providers/pos_panier_provider.dart';
import 'package:maketpeyizan/router/app_router.dart';

import 'donnees.dart';
import 'harness.dart';

void _remplirPanier(ProviderContainer c) {
  final panier = c.read(posPanierProvider.notifier);
  panier.ajouter(produitId: 1, nomProduit: 'Tomates fraîches', quantite: 3, prixUnitaire: 125);
  panier.ajouter(produitId: 3, nomProduit: 'Café moulu des Thiotte (500 g)',
      quantite: 1, prixUnitaire: 450);
}

void main() {
  setUpAll(chargerPolices);

  for (final (nom, chemin) in [('pos_vente_panier', '/pos/vente'), ('pos_paiement', '/pos/paiement')]) {
    for (final (suffixe, taille) in [('', telephone), (' petit', petitTelephone)]) {
      testWidgets('$nom$suffixe', (tester) async {
        final c = await monterApp(tester, chemin: '/pos/vente',
            utilisateur: utilisateurCaissier, taille: taille);
        _remplirPanier(c);
        c.read(routerProvider).go(chemin);
        await laisserCharger(tester);
        if (suffixe.isEmpty) await capture(tester, nom);
      });
    }
  }

  testWidgets('feuille du panier', (tester) async {
    final c = await monterApp(tester, chemin: '/pos/vente', utilisateur: utilisateurCaissier);
    _remplirPanier(c);
    await laisserCharger(tester);
    await tester.tap(find.text('Voir le panier'));
    await laisserCharger(tester);
    expect(find.text('Encaisser'), findsOneWidget);
    await capture(tester, 'pos_panier_feuille');
  });
}
