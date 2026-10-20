import 'package:dio/dio.dart';

/// Extrait un message affichable depuis un champ 'error' de réponse
/// backend : soit une string, soit un objet {"champ": ["message"]} des
/// erreurs de validation DRF (renvoie le premier message trouvé).
String extraireMessageErreur(dynamic erreur, String messageParDefaut) {
  if (erreur is String && erreur.isNotEmpty) return erreur;
  if (erreur is List && erreur.isNotEmpty) {
    return extraireMessageErreur(erreur.first, messageParDefaut);
  }
  if (erreur is Map) {
    // Erreurs imbriquées (ex: {"entreprise": {"nom": ["..."]}} à
    // l'inscription) : descendre jusqu'au premier message.
    for (final v in erreur.values) {
      final m = extraireMessageErreur(v, '');
      if (m.isNotEmpty) return m;
    }
  }
  return messageParDefaut;
}

/// Même chose, mais depuis une DioException (ex: 400 avec {success:false,
/// error:...}) au lieu d'assumer que toute exception vient d'un problème
/// réseau.
String messageErreurApi(Object e, String messageParDefaut) {
  if (e is DioException && e.response?.data is Map) {
    final data = e.response!.data as Map;
    // Enveloppe {success, error} des vues, sinon format DRF brut :
    // {"detail": "..."} (403/404 levés par entreprise_active) ou
    // {"champ": ["..."]} (ValidationError, ex: « Choisissez une entreprise »).
    return extraireMessageErreur(
      data['error'] ?? data['detail'] ?? data, messageParDefaut,
    );
  }
  return messageParDefaut;
}

/// Contrat des erreurs de permission POS (403 sur /api/pos/*) :
/// {"code": "...", "message": "..."} à la racine du corps JSON — pas de
/// wrapper 'detail' ni 'error'. À distinguer sur `code`, jamais sur le
/// texte de `message` (localisé, peut changer).
String? codePosErreur(Object e) {
  if (e is DioException && e.response?.statusCode == 403 && e.response?.data is Map) {
    final code = (e.response!.data as Map)['code'];
    if (code is String) return code;
  }
  return null;
}

String? messagePosErreur(Object e) {
  if (e is DioException && e.response?.data is Map) {
    final message = (e.response!.data as Map)['message'];
    if (message is String) return message;
  }
  return null;
}
