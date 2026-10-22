import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notifications affichées par l'app elle-même.
///
/// En arrière-plan / app fermée, Android affiche les push FCM tout seul
/// (canal choisi par le serveur, sinon [canal], canal par défaut du
/// manifeste).
/// Au premier plan, FCM ne les affiche pas : on les montre ici, avec les
/// données du push en charge utile pour ouvrir le bon écran au toucher.
class NotificationsLocales {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static Future<void>? _init;

  /// Canal par défaut (son du téléphone) : pushes sans famille connue.
  /// L'identifiant doit rester celui du manifeste
  /// (default_notification_channel_id).
  static const canal = AndroidNotificationChannel(
    'maketlakay_alertes',
    'Autres notifications',
    description: 'Collectes, messages et informations générales',
    importance: Importance.high,
  );

  /// Un canal par famille de push, chacun avec son son (res/raw).
  /// Sur Android le son appartient au canal et ne peut plus changer une
  /// fois le canal créé : pour changer un son, créer un nouvel identifiant.
  /// Le serveur envoie le même identifiant (android.notification.channel_id)
  /// pour que le son joue aussi quand l'app est fermée.
  static const canalCommandes = AndroidNotificationChannel(
    'ml_commandes', 'Nouvelles commandes',
    description: "Commandes reçues par l'entreprise ou l'administration",
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('son_commande'),
  );
  static const canalArgent = AndroidNotificationChannel(
    'ml_argent', 'Portefeuille et paiements',
    description: 'Argent reçu, paiements confirmés, remboursements',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('son_argent'),
  );
  static const canalSuivi = AndroidNotificationChannel(
    'ml_suivi', 'Suivi de commande',
    description: 'Commande confirmée, en route, livrée',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('son_suivi'),
  );
  static const canalCaisse = AndroidNotificationChannel(
    'ml_caisse', 'Terminal de caisse',
    description: 'Terminal validé ou réactivé',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('son_terminal'),
  );
  static const canalAlertes = AndroidNotificationChannel(
    'ml_alertes', 'Alertes',
    description: 'Terminal refusé, session clôturée, stock bas, paiement à vérifier',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('son_alerte'),
  );

  static const canaux = [
    canalCommandes, canalArgent, canalSuivi, canalCaisse, canalAlertes, canal,
  ];

  /// Canal d'un push d'après sa clé `screen` (même règle que le serveur).
  static AndroidNotificationChannel canalPour(Map<String, dynamic> data) {
    switch (data['screen']) {
      case 'producteur_commande':
      case 'admin_commande':
        return canalCommandes;
      case 'wallet':
        return canalArgent;
      case 'acheteur_commande':
        return canalSuivi;
      case 'pos_terminal_valide':
        return canalCaisse;
      case 'pos_terminal':
        return data['statut'] == 'actif' ? canalCaisse : canalAlertes;
      case 'pos_session':
      case 'admin_pos':
      case 'admin_alerte_stock':
      case 'producteur_stock':
        return canalAlertes;
    }
    return canal;
  }

  /// Appelé au toucher d'une notification affichée par l'app.
  static void Function(Map<String, dynamic> data)? onTap;

  static Future<void> initialiser() => _init ??= _initialiser();

  static Future<void> _initialiser() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@drawable/ic_notification'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (r) {
          final p = r.payload;
          if (p == null || p.isEmpty) return;
          onTap?.call(Map<String, dynamic>.from(jsonDecode(p) as Map));
        },
      );
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      for (final c in canaux) {
        await android?.createNotificationChannel(c);
      }
    } catch (e) {
      debugPrint('Notifications locales indisponibles : $e');
    }
  }

  /// Affiche un push reçu alors que l'app est au premier plan.
  static Future<void> afficher(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;
    await initialiser();
    // Canal choisi par le serveur s'il est connu, sinon d'après les données
    final demande = n.android?.channelId;
    final c = canaux.where((c) => c.id == demande).firstOrNull ??
        canalPour(message.data);
    try {
      await _plugin.show(
        id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: n.title,
        body: n.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            c.id,
            c.name,
            channelDescription: c.description,
            sound: c.sound,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
            styleInformation: BigTextStyleInformation(n.body ?? ''),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('Affichage de la notification impossible : $e');
    }
  }
}
