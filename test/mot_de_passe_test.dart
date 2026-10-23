// Règles du serveur pour un nouveau mot de passe.
import 'package:flutter_test/flutter_test.dart';
import 'package:maketpeyizan/core/utils/string_utils.dart';

void main() {
  test('8 caractères minimum, pas uniquement des chiffres', () {
    expect(validerMotDePasse('abc12'), 'Min. 8 caractères');
    expect(validerMotDePasse('12345678'), 'Ne doit pas contenir que des chiffres');
    expect(validerMotDePasse('jaden2026'), isNull);
    expect(validerMotDePasse(null), 'Min. 8 caractères');
  });
}
