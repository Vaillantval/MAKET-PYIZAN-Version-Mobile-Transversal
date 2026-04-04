import '../constants/app_constants.dart';

class ImageUtils {
  /// Construit l'URL absolue d'une image servie par le backend.
  static String imageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http')) return relativePath;
    return '${AppConstants.baseUrl}$relativePath';
  }

  /// Placeholder local selon le type de contenu
  static String placeholder(String type) {
    switch (type) {
      case 'produit':     return 'assets/images/placeholder_produit.png';
      case 'producteur':  return 'assets/images/placeholder_user.png';
      default:            return 'assets/images/placeholder.png';
    }
  }
}
