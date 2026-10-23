// Catalogue d'une entreprise : le formulaire produit est joignable,
// la liste affiche la modération (en attente, refusé + motif) et le contrat
// d'API est respecté (PATCH pour modifier, jamais statut / is_active).
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketpeyizan/core/api/api_client.dart';
import 'package:maketpeyizan/features/producteur/providers/mes_produits_provider.dart';

import 'design/donnees.dart';
import 'design/harness.dart';

/// Faux client : enregistre méthode + corps, renvoie un produit en attente.
class _ApiEnregistreuse implements ApiClient {
  final appels = <String>[];
  final corps = <String, dynamic>{};

  Response _ok(String path, dynamic data) =>
      Response(requestOptions: RequestOptions(path: path), statusCode: 200, data: data);

  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async =>
      _ok(path, {'success': true, 'data': <dynamic>[]});

  @override
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    appels.add('POST $path');
    corps[path] = data;
    return _ok(path, {'success': true, 'data': {'slug': 'riz', 'statut': 'en_attente'}});
  }

  @override
  Future<Response> patch(String path, {dynamic data, Options? options}) async {
    appels.add('PATCH $path');
    corps[path] = data;
    return _ok(path, {'success': true, 'data': {'slug': 'riz', 'statut': 'en_attente'}});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(chargerPolices);

  testWidgets("« Ajouter un produit » ouvre le formulaire (catégorie demandée)",
      (tester) async {
    await monterApp(tester, chemin: '/producteur/produit/nouveau',
        utilisateur: utilisateurMembre, entrepriseActive: 7);
    expect(tester.takeException(), isNull);
    expect(find.text('Nouveau produit'), findsOneWidget);
    expect(find.text('Catégorie *'), findsOneWidget);
  });

  testWidgets('la liste affiche le statut et le motif de refus', (tester) async {
    await monterApp(tester, chemin: '/producteur/catalogue',
        utilisateur: utilisateurMembre, entrepriseActive: 7);
    expect(find.text('En attente de validation'), findsOneWidget);
    expect(find.text('En cours de validation : invisible aux acheteurs pour le moment.'),
        findsOneWidget);
    expect(find.textContaining('Photo floue'), findsOneWidget);
    expect(find.textContaining('il sera soumis à nouveau'), findsOneWidget);
  });

  test('créer : POST sans statut ; modifier : PATCH ; statut renvoyé lu', () async {
    final api = _ApiEnregistreuse();
    final n = MesProduitsNotifier(api);

    final cree = await n.creer({'nom': 'Riz', 'categorie': 1});
    expect(api.appels, contains('POST /api/products/mes-produits/'));
    expect(cree.statut, 'en_attente');
    final envoye = api.corps['/api/products/mes-produits/'] as Map;
    expect(envoye.containsKey('statut'), isFalse);
    expect(envoye.containsKey('is_active'), isFalse);

    await n.modifier('riz', {'prix_unitaire': '100'});
    expect(api.appels, contains('PATCH /api/products/mes-produits/riz/'));
  });
}
