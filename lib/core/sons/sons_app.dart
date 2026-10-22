import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sons des actions de l'app (fichiers Mixkit dans assets/sons/).
///
/// Courts et discrets, joués sans couper la musique de l'utilisateur et
/// muets en mode silencieux ou vibreur : la vibration associée reste.
/// Les sons des notifications push, eux, sont portés par les canaux
/// Android (voir NotificationsLocales).
enum SonApp {
  panier('panier', 0.7, Vibration.legere),
  caisse('caisse', 0.6, Vibration.legere),
  retrait('retrait', 0.6, Vibration.aucune),
  commande('commande', 0.8, Vibration.moyenne),
  vente('vente', 0.8, Vibration.moyenne),
  argent('argent', 0.8, Vibration.moyenne),
  sessionOuverte('session_ouverte', 0.7, Vibration.moyenne),
  sessionCloturee('session_cloturee', 0.7, Vibration.moyenne),
  synchro('synchro', 0.6, Vibration.aucune),
  demande('demande', 0.7, Vibration.legere),
  erreur('erreur', 0.7, Vibration.erreur);

  final String fichier;
  final double volume;
  final Vibration vibration;
  const SonApp(this.fichier, this.volume, this.vibration);
}

/// Retour haptique joué avec le son (même en mode silencieux).
enum Vibration { aucune, legere, moyenne, erreur }

class SonsApp {
  static const _cle = 'sons_actifs';

  /// Interrupteur « Sons de l'application » du Profil.
  static final actifs = ValueNotifier<bool>(true);

  static final Map<SonApp, AudioPlayer> _lecteurs = {};
  static Future<void>? _init;

  /// Précharge les sons (appelé au démarrage, sans bloquer l'affichage).
  static Future<void> initialiser() => _init ??= _initialiser();

  static Future<void> _initialiser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      actifs.value = prefs.getBool(_cle) ?? true;

      // Sons d'interface : flux « système » (coupé en silencieux), sans
      // prendre le focus audio (la musique en cours continue)
      await AudioPlayer.global.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      ));

      for (final son in SonApp.values) {
        final lecteur = AudioPlayer(playerId: 'son_${son.fichier}');
        await lecteur.setPlayerMode(PlayerMode.lowLatency);
        await lecteur.setReleaseMode(ReleaseMode.stop);
        await lecteur.setVolume(son.volume);
        await lecteur.setSource(AssetSource('sons/${son.fichier}.mp3'));
        _lecteurs[son] = lecteur;
      }
    } catch (e) {
      // Pas de son (plateforme sans lecteur, tests…) : l'app continue
      debugPrint('Sons indisponibles : $e');
    }
  }

  static Future<void> activer(bool valeur) async {
    actifs.value = valeur;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cle, valeur);
    } catch (_) {}
  }

  /// Joue [son] avec sa vibration. Ne lève jamais d'erreur.
  static void jouer(SonApp son) {
    _vibrer(son.vibration);
    if (!actifs.value) return;
    final lecteur = _lecteurs[son];
    if (lecteur == null) return;
    () async {
      try {
        await lecteur.stop();
        await lecteur.resume();
      } catch (e) {
        debugPrint('Lecture du son ${son.fichier} impossible : $e');
      }
    }();
  }

  static void _vibrer(Vibration v) {
    switch (v) {
      case Vibration.aucune:
        return;
      case Vibration.legere:
        HapticFeedback.lightImpact();
      case Vibration.moyenne:
        HapticFeedback.mediumImpact();
      case Vibration.erreur:
        HapticFeedback.heavyImpact();
    }
  }
}
