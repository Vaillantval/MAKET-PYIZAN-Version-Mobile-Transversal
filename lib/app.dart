import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_handler.dart';
import 'core/notifications/notification_provider.dart';
import 'router/app_router.dart';

class MaketPeyizanApp extends ConsumerStatefulWidget {
  const MaketPeyizanApp({super.key});

  @override
  ConsumerState<MaketPeyizanApp> createState() =>
      _MaketPeyizanAppState();
}

class _MaketPeyizanAppState
    extends ConsumerState<MaketPeyizanApp> {

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  void _setupNotifications() {
    // Notification reçue en foreground → incrémenter compteur
    FirebaseMessaging.onMessage.listen((message) {
      ref.read(notificationProvider.notifier);
    });

    // Tap notification depuis background → naviguer
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final ctx = ref.read(routerProvider)
          .routerDelegate.navigatorKey.currentContext;
      if (ctx != null) {
        NotificationHandler.handle(message, ctx);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title:           'Makèt Peyizan',
      theme:           AppTheme.lightTheme,
      routerConfig:    router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('ht'),
      ],
      locale: const Locale('fr', 'FR'),
    );
  }
}
