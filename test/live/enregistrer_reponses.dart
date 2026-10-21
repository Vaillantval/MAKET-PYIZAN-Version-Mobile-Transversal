// Enregistre les réponses réelles du serveur pour un compte, afin de rendre
// les écrans avec de vraies données (test/live/ecrans_reels_test.dart).
//
//   dart run test/live/enregistrer_reponses.dart
//
// Identifiants lus dans l'environnement (jamais écrits sur disque) :
//   ML_EMAIL, ML_MOT_DE_PASSE, ML_POS_DEVICE (identifiant d'un terminal
//   déjà connu du serveur, pour ne pas créer de demande d'activation).
// Sortie : ML_SORTIE (fichier JSON, hors du dépôt).
import 'dart:convert';
import 'dart:io';

const _base = 'https://maketlakay.ht';

Future<Map<String, dynamic>> _appel(HttpClient http, String methode, String chemin,
    {Map<String, String> entetes = const {}, Object? corps}) async {
  final req = await http.openUrl(methode, Uri.parse('$_base$chemin'));
  req.headers.contentType = ContentType.json;
  entetes.forEach(req.headers.set);
  if (corps != null) req.write(jsonEncode(corps));
  final res = await req.close();
  final texte = await res.transform(utf8.decoder).join();
  dynamic data;
  try {
    data = jsonDecode(texte);
  } catch (_) {
    data = texte.length > 300 ? texte.substring(0, 300) : texte;
  }
  return {'status': res.statusCode, 'data': data};
}

Future<void> main() async {
  final env = Platform.environment;
  final email = env['ML_EMAIL'], mdp = env['ML_MOT_DE_PASSE'];
  final sortie = env['ML_SORTIE'];
  if (email == null || mdp == null || sortie == null) {
    stderr.writeln('ML_EMAIL, ML_MOT_DE_PASSE et ML_SORTIE sont requis');
    exit(2);
  }
  final http = HttpClient();
  final login = await _appel(http, 'POST', '/api/auth/login/',
      corps: {'email': email, 'password': mdp});
  final d = (login['data'] as Map)['data'] as Map? ?? login['data'] as Map;
  final jeton = (d['access'] ?? (d['tokens'] as Map?)?['access']) as String?;
  if (jeton == null) {
    stderr.writeln('Connexion refusée : ${login['status']} ${login['data']}');
    exit(1);
  }
  final entetes = {
    'Authorization': 'Bearer $jeton',
    if (env['ML_POS_DEVICE'] != null) 'X-POS-Device': env['ML_POS_DEVICE']!,
  };

  final chemins = [
    '/api/auth/me/',
    '/api/pos/terminal/statut/',
    '/api/pos/catalogue/',
    '/api/pos/rapports/',
    '/api/products/',
    '/api/products/categories/',
    '/api/wallet/',
    '/api/wallet/transactions/',
    '/api/orders/panier/',
    '/api/auth/commandes/',
  ];
  final reponses = <String, dynamic>{};
  for (final c in chemins) {
    reponses[c] = await _appel(http, 'GET', c, entetes: entetes);
    stdout.writeln('${reponses[c]['status']}  $c');
  }
  final user = (reponses['/api/auth/me/']['data'] as Map)['data'];
  stdout.writeln('rôle : ${(user as Map?)?['role']} · entreprises : '
      '${(user?['entreprises'] as List?)?.length ?? 0}');
  File(sortie).writeAsStringSync(jsonEncode({'reponses': reponses}));
  http.close();
}
