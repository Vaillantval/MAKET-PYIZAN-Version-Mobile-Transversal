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
