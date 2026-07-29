import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initialisation Firebase non-bloquante : démarrée par main() SANS être
/// attendue avant runApp() (l'attendre retardait le tout premier affichage
/// de l'app de plusieurs centaines de ms à chaque démarrage à froid — very
/// sensible sur un appareil bas de gamme où l'OS tue le process en
/// arrière-plan dès qu'il manque de RAM, forçant un redémarrage complet à
/// chaque retour dans l'app). _setupNotifications() (app.dart) attend
/// [ready] avant d'utiliser FirebaseMessaging, pour ne pas planter si
/// l'init n'est pas encore terminée.
class FirebaseInit {
  static Future<bool>? _future;

  static Future<bool> start() {
    return _future ??= Firebase.initializeApp().then((_) => true).catchError((e) {
      debugPrint('Firebase indisponible, notifications push désactivées : $e');
      return false;
    });
  }

  static Future<bool> get ready => _future ?? start();
}
