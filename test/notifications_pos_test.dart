// Caisse : refus du serveur (403 {code}) et routage des push POS.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketlakay/core/notifications/notification_handler.dart';
import 'package:maketlakay/features/pos/providers/pos_terminal_status_provider.dart';
import 'package:maketlakay/router/app_router.dart';

import 'design/donnees.dart';
import 'design/harness.dart';

String _lieu(ProviderContainer c) =>
    c.read(routerProvider).routerDelegate.currentConfiguration.uri.toString();

BuildContext _contexte(ProviderContainer c) =>
    c.read(routerProvider).routerDelegate.navigatorKey.currentContext!;

void main() {
  setUpAll(chargerPolices);

  for (final (code, titre) in [
    ('TERMINAL_EN_ATTENTE', 'Terminal en attente'),
    ('TERMINAL_REVOQUE', 'Terminal désactivé'),
    ('ROLE_INVALIDE', 'Compte non autorisé'),
  ]) {
    testWidgets('403 $code : la caisse est bloquée', (tester) async {
      final c = await monterApp(tester, chemin: '/pos/vente', utilisateur: utilisateurCaissier);
      expect(find.text('Rechercher un produit…'), findsOneWidget);

      expect(c.read(posTerminalStatusProvider.notifier).depuisCode(code), isTrue);
      await laisserCharger(tester);
      expect(find.text(titre), findsOneWidget);
      expect(find.text('Rechercher un produit…'), findsNothing);
      expect(find.text('Se déconnecter'), findsOneWidget);
    });
  }

  testWidgets('push pos_terminal « rejete » : écran Terminal refusé', (tester) async {
    final c = await monterApp(tester, chemin: '/pos/vente', utilisateur: utilisateurCaissier);
    NotificationHandler.handle({'screen': 'pos_terminal', 'statut': 'rejete'}, _contexte(c));
    await laisserCharger(tester);
    expect(find.text('Terminal refusé'), findsOneWidget);
  });

  testWidgets('push pos_terminal_valide : la caisse se débloque', (tester) async {
    final c = await monterApp(tester, chemin: '/pos/vente', utilisateur: utilisateurCaissier);
    c.read(posTerminalStatusProvider.notifier).definir(PosTerminalStatut.enAttente);
    await laisserCharger(tester);
    expect(find.text('Terminal en attente'), findsOneWidget);

    // Le serveur répond « actif » (données factices)
    NotificationHandler.handle({'screen': 'pos_terminal_valide'}, _contexte(c));
    await laisserCharger(tester);
    expect(find.text('Rechercher un produit…'), findsOneWidget);
  });

  testWidgets('push pos_session : historique de caisse', (tester) async {
    final c = await monterApp(tester, chemin: '/pos/vente', utilisateur: utilisateurCaissier);
    NotificationHandler.handle({'screen': 'pos_session', 'session_id': '12', 'ecart': '-50.00'}, _contexte(c));
    await laisserCharger(tester);
    expect(_lieu(c), '/pos/historique');
  });

  testWidgets('push wallet : portefeuille', (tester) async {
    final c = await monterApp(tester, chemin: '/acheteur/accueil', utilisateur: utilisateurAcheteur);
    NotificationHandler.handle(
        {'screen': 'wallet', 'type': 'pos_paiement', 'vente_id': '4', 'numero_vente': 'POS-4'},
        _contexte(c));
    await laisserCharger(tester);
    expect(_lieu(c), '/acheteur/wallet');
  });

  testWidgets('push producteur_commande : bascule sur l\'entreprise désignée', (tester) async {
    final c = await monterApp(tester, chemin: '/acheteur/accueil', utilisateur: utilisateurMembre);
    NotificationHandler.handle(
        {'screen': 'producteur_commande', 'entreprise_id': '7', 'entreprise_nom': 'Jaden Kenscoff'},
        _contexte(c));
    await laisserCharger(tester);
    expect(_lieu(c), '/producteur/commandes');
  });
}
