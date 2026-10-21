import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notifications affichées par l'app elle-même.
///
/// En arrière-plan / app fermée, Android affiche les push FCM tout seul
/// (canal [canal], déclaré dans le manifeste comme canal par défaut).
/// Au premier plan, FCM ne les affiche pas : on les montre ici, avec les
/// données du push en charge utile pour ouvrir le bon écran au toucher.
class NotificationsLocales {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static Future<void>? _init;

  /// Canal « importance haute » : bannière + son. L'identifiant doit rester
  /// celui du manifeste (default_notification_channel_id).
  static const canal = AndroidNotificationChannel(
    'maketlakay_alertes',
    'Alertes MaketLakay',
    description: 'Commandes, paiements, portefeuille et caisse',
    importance: Importance.high,
  );

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
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(canal);
    } catch (e) {
      debugPrint('Notifications locales indisponibles : $e');
    }
  }

  /// Affiche un push reçu alors que l'app est au premier plan.
  static Future<void> afficher(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;
    await initialiser();
    try {
      await _plugin.show(
        id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: n.title,
        body: n.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            canal.id,
            canal.name,
            channelDescription: canal.description,
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
