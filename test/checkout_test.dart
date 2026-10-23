// Écran de paiement : ordre des méthodes, bouton toujours visible mais
// désactivé tant qu'une condition manque, et contrat POST
// /api/orders/commander/ (portefeuille = utiliser_wallet + MonCash).
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketpeyizan/core/api/api_client.dart';
import 'package:maketpeyizan/features/acheteur/providers/commande_provider.dart';

import 'design/donnees.dart';
import 'design/harness.dart';

const _adresse = {
  'id': 5, 'rue': '12, rue Grégoire', 'commune': 'Pétion-Ville',
  'departement': 'Ouest', 'is_default': true,
};

Map<String, dynamic> Function(String) _avecAdresses(List<Map<String, dynamic>> adresses) =>
    (path) => path == '/api/auth/adresses/'
        ? {'success': true, 'data': adresses}
        : reponseFactice(path, utilisateurMembre);

ElevatedButton _boutonPayer(WidgetTester tester) => tester.widget<ElevatedButton>(
    find.ancestor(of: find.textContaining('Payer avec'), matching: find.byType(ElevatedButton)));

/// Faux client qui enregistre le corps des POST.
class _ApiEnregistreuse implements ApiClient {
  final posts = <String, dynamic>{};

  Response _ok(String path, dynamic data) => Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: data,
      );

  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async =>
      _ok(path, {'success': true, 'data': <dynamic>[]});

  @override
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    posts[path] = data;
    return _ok(path, {'success': true, 'data': {'commandes': <dynamic>[]}});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(chargerPolices);

  testWidgets('les méthodes sont dans l\'ordre, MonCash par défaut', (tester) async {
    await monterApp(tester, chemin: '/acheteur/checkout',
        utilisateur: utilisateurMembre, repondre: _avecAdresses([_adresse]));

    final ordre = ['MonCash', 'NatCash', 'Virement / dépôt', 'Portefeuille', 'Espèces'];
    final y = [for (final t in ordre) tester.getTopLeft(find.text(t)).dy];
    expect(y, [...y]..sort());
    expect(find.text('Payer avec MonCash'), findsOneWidget);
  });

  testWidgets('sans adresse, le bouton reste visible mais désactivé', (tester) async {
    await monterApp(tester, chemin: '/acheteur/checkout',
        utilisateur: utilisateurMembre, repondre: _avecAdresses([]));

    expect(find.text('Ajoutez une adresse de livraison'), findsOneWidget);
    expect(_boutonPayer(tester).onPressed, isNull);
  });

  testWidgets("avec une adresse, le bouton s'active ; un virement exige la preuve",
      (tester) async {
    await monterApp(tester, chemin: '/acheteur/checkout',
        utilisateur: utilisateurMembre, repondre: _avecAdresses([_adresse]));
    expect(_boutonPayer(tester).onPressed, isNotNull);

    await tester.tap(find.text('Virement / dépôt'));
    await laisserCharger(tester);
    expect(find.text('Joignez la preuve de votre virement ou dépôt'), findsOneWidget);
    final bouton = tester.widget<ElevatedButton>(find.ancestor(
        of: find.text('Envoyer la commande et la preuve'),
        matching: find.byType(ElevatedButton)));
    expect(bouton.onPressed, isNull);
  });

  test('portefeuille : utiliser_wallet avec MonCash, adresse envoyée', () async {
    final api = _ApiEnregistreuse();
    final notifier = CommandeNotifier(api);
    await notifier.passer(
      methodePaiement: 'moncash',
      modeLivraison:   'domicile',
      adresseId:       5,
      utiliserWallet:  true,
    );
    final corps = api.posts['/api/orders/commander/'] as Map<String, dynamic>;
    expect(corps['methode_paiement'], 'moncash');
    expect(corps['utiliser_wallet'], true);
    expect(corps['adresse_livraison_id'], 5);
  });
}
