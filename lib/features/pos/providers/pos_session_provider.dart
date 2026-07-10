import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/offline/offline_manager.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/pos_local_storage.dart';
import '../../../models/pos_session.dart';

final posSessionProvider =
    StateNotifierProvider<PosSessionNotifier, AsyncValue<PosSession?>>((ref) {
  return PosSessionNotifier(
    ref.read(apiClientProvider),
    ref.read(localStorageProvider),
    ref.read(posLocalStorageProvider),
    ref.read(offlineManagerProvider),
  );
});

class PosSessionNotifier extends StateNotifier<AsyncValue<PosSession?>> {
  final ApiClient        _api;
  final LocalStorage     _localStorage;
  final PosLocalStorage  _posStorage;
  final OfflineManager   _offline;

  PosSessionNotifier(this._api, this._localStorage, this._posStorage, this._offline)
      : super(const AsyncValue.loading()) {
    _restaurer();
  }

  void _restaurer() {
    final cached = _posStorage.getSession();
    state = AsyncValue.data(cached != null ? PosSession.fromJson(cached) : null);
  }

  bool get isOuverte => state.whenOrNull(data: (s) => s?.statut == 'ouverte') ?? false;

  /// Ouvre une session de caisse. RÈGLE : nécessite d'être en ligne.
  /// Retourne un message d'erreur, ou null si succès.
  Future<String?> ouvrir(double fondsOuverture) async {
    if (!ConnectivityService().isOnline) {
      return "L'ouverture de session nécessite une connexion internet.";
    }

    final deviceUid = _localStorage.getString(AppConstants.keyPosDeviceUid);
    if (deviceUid == null || deviceUid.isEmpty) {
      return 'Terminal non appairé.';
    }

    try {
      final res = await _api.post(AppEndpoints.posSessionOuvrir, data: {
        'device_uid':      deviceUid,
        'fonds_ouverture': fondsOuverture,
      });
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final session = PosSession.fromJson(data['data'] as Map<String, dynamic>);
        await _posStorage.saveSession(session.toJson());
        state = AsyncValue.data(session);
        return null;
      }
      return data['error']?.toString() ?? "Erreur lors de l'ouverture de la session";
    } catch (_) {
      return 'Erreur réseau — impossible de contacter le serveur.';
    }
  }

  /// Ferme la session. Bloque tant que des ventes locales restent en
  /// attente de synchronisation. Retourne {'error': ...} ou le récap
  /// backend en cas de succès.
  Future<Map<String, dynamic>> fermer(double fondsFermeture) async {
    if (!ConnectivityService().isOnline) {
      return {'error': 'La fermeture de session nécessite une connexion internet.'};
    }

    // Forcer une synchronisation complète avant de fermer
    await _offline.syncAll();
    final pendantes = _posStorage.countBySyncStatus('enAttente');
    if (pendantes > 0) {
      return {
        'error': '$pendantes vente(s) en attente de synchronisation — '
            'connectez-vous et réessayez.',
      };
    }

    try {
      final res = await _api.post(AppEndpoints.posSessionFermer, data: {
        'fonds_fermeture': fondsFermeture,
      });
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await _posStorage.clearSession();
        state = const AsyncValue.data(null);
        return data['data'] as Map<String, dynamic>? ?? {};
      }
      return {'error': data['error']?.toString() ?? 'Erreur lors de la fermeture de la session'};
    } catch (_) {
      return {'error': 'Erreur réseau — impossible de contacter le serveur.'};
    }
  }
}
