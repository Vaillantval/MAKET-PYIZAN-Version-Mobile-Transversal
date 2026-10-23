// Panier : panier local du visiteur (comme le panier de session du site),
// transfert sur le compte à la connexion, et unités de vente.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketpeyizan/core/api/api_client.dart';
import 'package:maketpeyizan/core/offline/offline_manager.dart';
import 'package:maketpeyizan/core/storage/local_storage.dart';
import 'package:maketpeyizan/features/acheteur/providers/panier_provider.dart';
import 'package:maketpeyizan/features/acheteur/widgets/choix_unite.dart';
import 'package:maketpeyizan/models/produit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'design/donnees.dart';

/// Faux client : enregistre les POST, renvoie un panier vide.
class _ApiEnregistreuse implements ApiClient {
  final posts = <Map<String, dynamic>>[];

  Response _ok(String path) => Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {'success': true, 'data': {'items': <dynamic>[], 'total': '0', 'nb_articles': 0}},
      );

  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async => _ok(path);
  @override
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    posts.add({'path': path, ...Map<String, dynamic>.from(data as Map)});
    return _ok(path);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _OfflineInutilise implements OfflineManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _attendre() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  final tomates = Produit.fromJson(produits.first);        // kg, + sac 10 kg, caisse 50 kg
  final cafe    = Produit.fromJson(produits[2]);           // une seule unité

  late LocalStorage local;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    local = LocalStorage(await SharedPreferences.getInstance());
  });

  test('unités : base puis prix supplémentaires, quantité max selon le stock', () {
    final u = OptionUnite.pour(tomates);
    expect(u.map((o) => o.libelle), ['kg', 'Sac de 10 kg', 'Caisse de 50 kg']);
    expect(u[0].id, 101);
    expect(u[1].prix, 1100);
    expect(u.map((o) => o.maxPour(tomates.stockReel)), [40, 4, 0]);
    expect(OptionUnite.pour(cafe), hasLength(1));
  });

  test('visiteur : le panier se remplit sur l\'appareil, par unité', () async {
    final n = PanierNotifier(_ApiEnregistreuse(), _OfflineInutilise(), local, connecte: false);
    final sac = OptionUnite.pour(tomates)[1];

    expect(await n.ajouter(tomates, 2, unite: sac), isNull);
    expect(await n.ajouter(tomates, 3), isNull);              // kg : ligne distincte
    expect(await n.ajouter(tomates, 1, unite: sac), isNull);  // même ligne : 3 sacs

    final p = n.state.value!;
    expect(p.items, hasLength(2));
    expect(p.items.first.quantite, 3);
    expect(p.items.first.uniteVenteLabel, 'Sac de 10 kg');
    expect(p.total, 3 * 1100 + 3 * 125);
    expect(p.nbArticles, 6);

    // Stock : 3 sacs (30 kg) + 3 kg déjà pris sur 40 kg → un 4e sac refusé
    expect(await n.ajouter(tomates, 1, unite: sac), contains('Stock insuffisant'));

    // Conservé sur l'appareil
    final relu = PanierNotifier(_ApiEnregistreuse(), _OfflineInutilise(), local, connecte: false);
    expect(relu.state.value!.items, hasLength(2));

    await relu.retirer(relu.state.value!.items.last);
    expect(relu.state.value!.items, hasLength(1));
  });

  test('connexion : le panier local est envoyé sur le compte puis vidé', () async {
    final invite = PanierNotifier(_ApiEnregistreuse(), _OfflineInutilise(), local, connecte: false);
    await invite.ajouter(tomates, 2, unite: OptionUnite.pour(tomates)[1]);
    await invite.ajouter(cafe, 1);

    final api = _ApiEnregistreuse();
    PanierNotifier(api, _OfflineInutilise(), local, connecte: true);
    await _attendre();

    expect(api.posts, [
      {'path': '/api/orders/panier/ajouter/', 'slug': 'produit-1', 'quantite': 2, 'unite_id': 12},
      {'path': '/api/orders/panier/ajouter/', 'slug': 'produit-3', 'quantite': 1, 'unite_id': 103},
    ]);
    expect(local.getJsonList('panier_invite'), isNull);
  });
}
