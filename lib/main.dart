import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/offline/connectivity_service.dart';
import 'core/storage/local_storage.dart';
import 'core/storage/pos_local_storage.dart';
import 'core/constants/app_constants.dart';
import 'core/notifications/fcm_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await Hive.initFlutter();
  final posSessionBox = await Hive.openBox(AppConstants.hivePosSessionBox);
  final posSalesBox   = await Hive.openBox(AppConstants.hivePosSalesBox);

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Firebase
  await Firebase.initializeApp();

  // Enregistrer le handler background FCM
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // Connectivité
  await ConnectivityService().initialize();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(LocalStorage(prefs)),
        posLocalStorageProvider.overrideWithValue(
          PosLocalStorage(posSessionBox, posSalesBox),
        ),
      ],
      child: const MaketPeyizanApp(),
    ),
  );
}
