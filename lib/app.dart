import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/firebase_init.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_handler.dart';
import 'core/notifications/notifications_locales.dart';
import 'providers/auth_provider.dart';
import 'features/pos/providers/pos_terminal_status_provider.dart';
import 'router/app_router.dart';

class MaketLakayApp extends ConsumerStatefulWidget {
  const MaketLakayApp({super.key});

  @override
  ConsumerState<MaketLakayApp> createState() =>
      _MaketLakayAppState();
}

class _MaketLakayAppState
    extends ConsumerState<MaketLakayApp> {

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

    // Toucher d'une notification affichée par l'app (premier plan)
    NotificationsLocales.onTap = _ouvrir;
    await NotificationsLocales.initialiser();

    // Premier plan : FCM n'affiche rien, l'app montre la notification
    FirebaseMessaging.onMessage.listen((message) {
      NotificationsLocales.afficher(message);
      // Statut du terminal à jour sans attendre un toucher
      final screen = message.data['screen'];
      if (screen == 'pos_terminal_valide') {
        ref.read(posTerminalStatusProvider.notifier).verifier();
      } else if (screen == 'pos_terminal') {
        ref.read(posTerminalStatusProvider.notifier)
            .depuisPush(message.data['statut'] as String?);
      }
    });

    // Arrière-plan : toucher de la notification système
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _ouvrir(m.data));

    // App fermée, lancée par le toucher d'une notification
    final initiale = await FirebaseMessaging.instance.getInitialMessage();
    if (initiale != null) _ouvrir(initiale.data);
  }

  /// Ouvre l'écran d'un push, une fois la session résolue (sinon la
  /// redirection du démarrage écraserait la navigation).
  Future<void> _ouvrir(Map<String, dynamic> data) async {
    for (var i = 0; i < 50 && ref.read(authProvider).status == AuthStatus.unknown; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final ctx = ref.read(routerProvider).routerDelegate.navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) NotificationHandler.handle(data, ctx);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title:           'MaketLakay',
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
