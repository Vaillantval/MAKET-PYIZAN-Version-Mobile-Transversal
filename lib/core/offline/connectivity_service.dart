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
    loading: () => false,
    error:   (_, __) => false,
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
  bool _currentStatus    = false;

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
