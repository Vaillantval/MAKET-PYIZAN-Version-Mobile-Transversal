class StringUtils {
  static const Map<String, String> _accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
    'è': 'e', 'ê': 'e', 'ë': 'e', 'é': 'e',
    'ì': 'i', 'î': 'i', 'ï': 'i', 'í': 'i',
    'ò': 'o', 'ô': 'o', 'ö': 'o', 'ó': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
    'ç': 'c', 'ñ': 'n',
  };

  // Variante conservant la casse, pour un repli d'impression sans accents
  // (le premier caractère de chaque paire est en majuscule).
  static const Map<String, String> _accentsMajuscules = {
    'À': 'A', 'Â': 'A', 'Ä': 'A', 'Á': 'A',
    'È': 'E', 'Ê': 'E', 'Ë': 'E', 'É': 'E',
    'Ì': 'I', 'Î': 'I', 'Ï': 'I', 'Í': 'I',
    'Ò': 'O', 'Ô': 'O', 'Ö': 'O', 'Ó': 'O',
    'Ù': 'U', 'Û': 'U', 'Ü': 'U', 'Ú': 'U',
    'Ç': 'C', 'Ñ': 'N',
  };

  /// Normalise une chaîne pour une recherche insensible aux accents/casse.
  static String normalize(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      buffer.write(_accents[char] ?? char);
    }
    return buffer.toString();
  }

  static bool contains(String haystack, String needle) =>
      normalize(haystack).contains(normalize(needle));

  /// Retire les accents en conservant la casse — utilisé en repli quand
  /// l'imprimante ne restitue pas correctement un caractère accentué.
  static String sansAccents(String input) {
    final buffer = StringBuffer();
    for (final char in input.split('')) {
      buffer.write(_accents[char] ?? _accentsMajuscules[char] ?? char);
    }
    return buffer.toString();
  }
}

/// Règles du serveur pour un nouveau mot de passe : au moins 8 caractères
/// et pas uniquement des chiffres. Renvoie le message d'erreur, ou null.
String? validerMotDePasse(String? v) {
  final mdp = v ?? '';
  if (mdp.length < 8) return 'Min. 8 caractères';
  if (RegExp(r'^\d+$').hasMatch(mdp)) {
    return 'Ne doit pas contenir que des chiffres';
  }
  return null;
}
