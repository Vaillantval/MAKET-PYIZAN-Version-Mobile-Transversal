import 'package:flutter_test/flutter_test.dart';
import 'package:maketlakay/shared/widgets/categorie_chip.dart';

void main() {
  test('emoji de catégorie : champ emoji, puis icone si emoji, sinon 🌿', () {
    expect(CategorieChip.emoji({'emoji': '🥭', 'icone': 'fas fa-leaf'}), '🥭');
    expect(CategorieChip.emoji({'icone': '☕'}), '☕');
    expect(CategorieChip.emoji({'icone': 'fas fa-leaf'}), '🌿');
    expect(CategorieChip.emoji({'emoji': '', 'icone': ''}), '🌿');
    expect(CategorieChip.emoji({}), '🌿');
  });
}
