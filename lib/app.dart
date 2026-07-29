import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/firebase_init.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_handler.dart';
import 'core/notifications/notification_provider.dart';
import 'features/pos/providers/pos_terminal_status_provider.dart';
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

  Future<void> _setupNotifications() async {
    // main.dart ne bloque plus runApp() sur Firebase.initializeApp() (voir
    // FirebaseInit) — l'attendre ici, avant tout usage de
    // FirebaseMessaging, évite un crash si l'init n'est pas encore
    // terminée à ce stade.
    final ready = await FirebaseInit.ready;
    if (!ready || !mounted) return;

    // Notification reçue en foreground → incrémenter compteur
    FirebaseMessaging.onMessage.listen((message) {
      ref.read(notificationProvider.notifier);
      // Terminal POS validé pendant que l'app est déjà ouverte : pas de
      // tap à intercepter ici (onMessageOpenedApp ne se déclenche que sur
      // tap depuis l'arrière-plan), donc rafraîchir directement le badge.
      if (message.data['screen'] == 'pos_terminal_valide') {
        ref.read(posTerminalStatusProvider.notifier).verifier();
      }
    });

    // Tap notification depuis background → naviguer
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (!mounted) return;
      final ctx = ref.read(routerProvider)
          .routerDelegate.navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
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
