import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityService().onStatusChange;
});

final isOnlineProvider = Provider<bool>((ref) {
  final conn = ref.watch(connectivityProvider);
  return conn.when(
    data:    (online) => online,
    // Optimiste par défaut : la vérification initiale (hasInternetAccess)
    // peut être lente ou peu fiable sur certains réseaux, sans rapport
    // avec la vraie capacité de l'app à joindre le backend. Les appels
    // réseau réels restent la source de vérité (catch en cas d'échec) ;
    // partir de "hors ligne" par défaut affichait un faux badge et
    // bloquait des écrans (ex: catalogue POS) qui attendent isOnline
    // avant même d'essayer.
    loading: () => true,
    error:   (_, __) => true,
  );
});

class ConnectivityService {
  static final ConnectivityService _instance =
      ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivity    = Connectivity();
  final _checker         = InternetConnection();
  final _controller      = StreamController<bool>.broadcast();
  // Optimiste par défaut (voir isOnlineProvider) : évite qu'un écran
  // gated sur isOnline reste bloqué en attendant une vérification
  // initiale potentiellement lente/peu fiable sur certains réseaux.
  bool _currentStatus    = true;

  Stream<bool> get onStatusChange => _controller.stream;
  bool get isOnline => _currentStatus;

  Future<void> initialize() async {
    // Vérifier l'état initial
    _currentStatus = await _checker.hasInternetAccess;
    _controller.add(_currentStatus);

    // Écouter les changements de connectivité
    _connectivity.onConnectivityChanged.listen((_) async {
      final online = await _checker.hasInternetAccess;
      if (online != _currentStatus) {
        _currentStatus = online;
        _controller.add(online);
      }
    });

    // Vérifier périodiquement
    Timer.periodic(const Duration(seconds: 30), (_) async {
      final online = await _checker.hasInternetAccess;
      if (online != _currentStatus) {
        _currentStatus = online;
        _controller.add(online);
      }
    });
  }
}
