import 'package:dio/dio.dart';

/// Extrait le message d'erreur métier renvoyé par le backend (data['error'],
/// string ou objet {"champ": ["message"]} des erreurs de validation DRF)
/// depuis une DioException, au lieu d'assumer que toute exception vient
/// d'un problème réseau.
String messageErreurApi(Object e, String messageParDefaut) {
  if (e is DioException && e.response?.data is Map) {
    final erreur = (e.response!.data as Map)['error'];
    if (erreur is String && erreur.isNotEmpty) return erreur;
    if (erreur is Map) {
      final premier = erreur.values.firstWhere(
        (v) => v is List && v.isNotEmpty,
        orElse: () => null,
      );
      if (premier is List) return premier.first.toString();
    }
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
