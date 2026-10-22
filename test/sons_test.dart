import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketlakay/core/notifications/notifications_locales.dart';
import 'package:maketlakay/core/sons/sons_app.dart';
import 'package:maketlakay/shared/ui/animations.dart';

void main() {
  group('canal des notifications push', () {
    String canal(Map<String, dynamic> data) =>
        NotificationsLocales.canalPour(data).id;

    test('chaque famille a son canal (et donc son son)', () {
      expect(canal({'screen': 'producteur_commande'}), 'ml_commandes');
      expect(canal({'screen': 'admin_commande'}), 'ml_commandes');
      expect(canal({'screen': 'wallet'}), 'ml_argent');
      expect(canal({'screen': 'acheteur_commande'}), 'ml_suivi');
      expect(canal({'screen': 'pos_terminal_valide'}), 'ml_caisse');
      expect(canal({'screen': 'pos_session'}), 'ml_alertes');
      expect(canal({'screen': 'admin_pos'}), 'ml_alertes');
      expect(canal({'screen': 'producteur_stock'}), 'ml_alertes');
    });

    test('terminal : réactivé = caisse, refusé ou révoqué = alerte', () {
      expect(canal({'screen': 'pos_terminal', 'statut': 'actif'}), 'ml_caisse');
      expect(canal({'screen': 'pos_terminal', 'statut': 'revoque'}), 'ml_alertes');
      expect(canal({'screen': 'pos_terminal', 'statut': 'rejete'}), 'ml_alertes');
    });

    test('push inconnu : canal par défaut du manifeste', () {
      expect(canal({'screen': 'producteur_collecte'}), 'maketlakay_alertes');
      expect(canal({}), 'maketlakay_alertes');
    });

    test('chaque canal avec son a un fichier dans res/raw', () {
      for (final c in NotificationsLocales.canaux) {
        if (c.sound == null) continue;
        expect(c.sound!.sound, startsWith('son_'));
      }
    });
  });

  test('jouer un son sans lecteur chargé ne plante pas', () {
    for (final son in SonApp.values) {
      SonsApp.jouer(son);
    }
  });

  testWidgets('une ligne retirée glisse puis disparaît', (tester) async {
    final lignes = ['Tomates', 'Akamil'];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (_, setState) => Column(children: [
            for (final l in lignes)
              SortieAnimee(
                key: ValueKey(l),
                builder: (_, sortir) => TextButton(
                  onPressed: () => sortir(() => setState(() => lignes.remove(l))),
                  child: Text(l),
                ),
              ),
          ]),
        ),
      ),
    ));

    await tester.tap(find.text('Tomates'));
    await tester.pump(const Duration(milliseconds: 100));
    // Pendant l'animation, la ligne est encore là
    expect(find.text('Tomates'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Tomates'), findsNothing);
    expect(find.text('Akamil'), findsOneWidget);
  });

  testWidgets('la coche se dessine sans erreur', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Center(child: CocheAnimee())));
    await tester.pumpAndSettle();
    expect(find.byType(CocheAnimee), findsOneWidget);
  });
}
