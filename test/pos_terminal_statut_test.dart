// Statut du terminal de caisse : un refus appris d'une 403 ne doit pas être
// effacé par la réponse « inconnu » d'une vérification partie avant que le
// premier appel /api/pos/* ne crée la demande d'activation.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketpeyizan/core/api/api_client.dart';
import 'package:maketpeyizan/core/storage/secure_storage.dart';
import 'package:maketpeyizan/features/pos/providers/pos_terminal_status_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ApiStatut implements ApiClient {
  String statut;
  _ApiStatut(this.statut);

  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async =>
      Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {'success': true, 'data': {'statut': statut}},
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test("« inconnu » n'efface pas un terminal en attente", () async {
    final api = _ApiStatut('inconnu');
    final n = PosTerminalStatusNotifier(api);

    n.depuisCode('TERMINAL_EN_ATTENTE');      // 403 du catalogue
    await n.verifier();                        // réponse partie avant la demande
    expect(n.state.statut, PosTerminalStatut.enAttente);

    api.statut = 'actif';                      // terminal validé par l'admin
    await n.verifier();
    expect(n.state.statut, PosTerminalStatut.actif);
  });

  test('« rejetee » (API) et « rejete » (push) : terminal refusé', () async {
    final n = PosTerminalStatusNotifier(_ApiStatut('rejetee'));
    await n.verifier();
    expect(n.state.statut, PosTerminalStatut.rejetee);

    final m = PosTerminalStatusNotifier(_ApiStatut('actif'));
    m.depuisPush('rejete');
    expect(m.state.statut, PosTerminalStatut.rejetee);
  });

  test("identifiant du terminal : créé une fois, stable", () async {
    SharedPreferences.setMockInitialValues({});
    final s = SecureStorage(await SharedPreferences.getInstance());
    final a = s.deviceUidPos();
    expect(a, hasLength(36));
    expect(s.deviceUidPos(), a);
  });
}
