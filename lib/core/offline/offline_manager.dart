import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../constants/app_constants.dart';
import 'sync_queue.dart';
import 'connectivity_service.dart';
import 'cache_manager.dart';

final offlineManagerProvider = Provider<OfflineManager>((ref) {
  return OfflineManager(
    ref.read(apiClientProvider),
    ref.read(syncQueueProvider),
    ref.read(cacheManagerProvider),
    ConnectivityService(),
  );
});

class OfflineManager {
  final ApiClient          _api;
  final SyncQueue          _queue;
  final CacheManager       _cache;
  final ConnectivityService _connectivity;
  Timer? _syncTimer;
  bool   _isSyncing = false;

  OfflineManager(
    this._api,
    this._queue,
    this._cache,
    this._connectivity,
  );

  void initialize() {
    // Écouter les changements de connectivité
    _connectivity.onStatusChange.listen((online) {
      if (online) _triggerSync();
    });

    // Sync périodique si en ligne
    _syncTimer = Timer.periodic(AppConstants.syncInterval, (_) {
      if (_connectivity.isOnline) _triggerSync();
    });
  }

  void dispose() => _syncTimer?.cancel();

  // ── Exécuter une action (online ou offline) ────────────────────

  /// Execute immédiatement si online, sinon met en queue
  Future<OfflineResult> execute(SyncAction action) async {
    if (_connectivity.isOnline) {
      try {
        final response = await _executeAction(action);
        return OfflineResult.success(response.data);
      } catch (e) {
        // En cas d'erreur réseau, mettre en queue
        if (_isNetworkError(e)) {
          await _queue.add(action);
          return OfflineResult.queued(action.id);
        }
        return OfflineResult.error(e.toString());
      }
    } else {
      await _queue.add(action);
      return OfflineResult.queued(action.id);
    }
  }

  // ── Synchronisation ────────────────────────────────────────────

  Future<SyncResult> syncAll() async {
    if (!_connectivity.isOnline || _isSyncing) {
      return SyncResult(synced: 0, failed: 0, pending: _queue.pendingCount);
    }

    _isSyncing = true;
    int synced = 0;
    int failed = 0;

    // Les ventes POS ont un contrat de réponse par-item (créée/duplicata/
    // rejetée/conflit de stock) traité exclusivement par
    // PosHistoriqueNotifier.synchroniserVentesPos() — ce gestionnaire
    // générique ne doit jamais les toucher pour éviter une double
    // synchronisation (course entre les deux mécanismes).
    final actions = _queue.getAll()
        .where((a) => a.type != SyncActionType.posSale)
        .toList();

    for (final action in actions) {
      if (action.retries >= AppConstants.maxSyncRetries) {
        await _queue.remove(action.id);
        failed++;
        continue;
      }

      try {
        await _executeAction(action);
        await _queue.remove(action.id);
        synced++;
      } catch (e) {
        if (_isNetworkError(e)) {
          // Remettre en queue avec retry++
          await _queue.incrementRetry(action.id);
          break; // Arrêter si problème réseau
        } else {
          // Erreur métier (ex: stock épuisé) → supprimer de la queue
          await _queue.remove(action.id);
          failed++;
        }
      }
    }

    _isSyncing = false;

    return SyncResult(
      synced:  synced,
      failed:  failed,
      pending: _queue.pendingCount,
    );
  }

  void _triggerSync() {
    if (!_isSyncing) syncAll();
  }

  Future<Response> _executeAction(SyncAction action) async {
    switch (action.method.toUpperCase()) {
      case 'POST':
        return _api.post(action.endpoint, data: action.payload);
      case 'PATCH':
        return _api.patch(action.endpoint, data: action.payload);
      case 'DELETE':
        return _api.delete(action.endpoint);
      default:
        throw Exception('Méthode inconnue : ${action.method}');
    }
  }

  bool _isNetworkError(dynamic e) =>
      e is DioException &&
      (e.type == DioExceptionType.connectionTimeout ||
       e.type == DioExceptionType.receiveTimeout    ||
       e.type == DioExceptionType.connectionError);

  int get pendingCount => _queue.pendingCount;

  CacheManager get cache => _cache;
}

// ── Résultats ──────────────────────────────────────────────────

class OfflineResult {
  final bool    isSuccess;
  final bool    isQueued;
  final dynamic data;
  final String? error;
  final String? queueId;

  const OfflineResult._({
    required this.isSuccess,
    required this.isQueued,
    this.data,
    this.error,
    this.queueId,
  });

  factory OfflineResult.success(dynamic data) => OfflineResult._(
    isSuccess: true, isQueued: false, data: data,
  );

  factory OfflineResult.queued(String queueId) => OfflineResult._(
    isSuccess: true, isQueued: true, queueId: queueId,
  );

  factory OfflineResult.error(String error) => OfflineResult._(
    isSuccess: false, isQueued: false, error: error,
  );
}

class SyncResult {
  final int synced;
  final int failed;
  final int pending;
  SyncResult({required this.synced, required this.failed, required this.pending});
}
