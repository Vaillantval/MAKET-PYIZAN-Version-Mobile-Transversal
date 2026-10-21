import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/offline/offline_manager.dart';
import '../../../core/storage/pos_local_storage.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/pos_session.dart';
import 'pos_device_provider.dart';
import 'pos_terminal_status_provider.dart';
import 'pos_vente_provider.dart';

final posSessionProvider =
    StateNotifierProvider<PosSessionNotifier, AsyncValue<PosSession?>>((ref) {
  return PosSessionNotifier(
    ref.read(apiClientProvider),
    ref.read(posLocalStorageProvider),
    ref.read(offlineManagerProvider),
    ref,
  );
});

class PosSessionNotifier extends StateNotifier<AsyncValue<PosSession?>> {
  final ApiClient        _api;
  final PosLocalStorage  _posStorage;
  final OfflineManager   _offline;
  final Ref              _ref;

  PosSessionNotifier(this._api, this._posStorage, this._offline, this._ref)
      : super(const AsyncValue.loading()) {
    _restaurer();
  }

  void _restaurer() {
    final cached = _posStorage.getSession();
    state = AsyncValue.data(cached != null ? PosSession.fromJson(cached) : null);
  }

  bool get isOuverte => state.whenOrNull(data: (s) => s?.statut == 'ouverte') ?? false;

  /// La session a été clôturée hors de l'app (administration, push
  /// pos_session ou refus « aucune session ouverte ») : l'oublier
  /// localement pour proposer d'en ouvrir une nouvelle.
  Future<void> sessionFermeeParServeur() async {
    await _posStorage.clearSession();
    state = const AsyncValue.data(null);
  }

  /// Ouvre une session de caisse. RÈGLE : nécessite d'être en ligne.
  /// Retourne un message d'erreur, ou null si succès.
  Future<String?> ouvrir(double fondsOuverture) async {
    if (!ConnectivityService().isOnline) {
      return "L'ouverture de session nécessite une connexion internet.";
    }

    final deviceUid = _ref.read(posDeviceUidProvider);
    if (deviceUid == null || deviceUid.isEmpty) {
      return "Identifiant du terminal non disponible — réessayez dans "
          "quelques instants.";
    }

    try {
      final res = await _api.post(AppEndpoints.posSessionOuvrir, data: {
        'device_uid':      deviceUid,
        'fonds_ouverture': double.parse(fondsOuverture.toStringAsFixed(2)),
      });
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _ref.read(posTerminalStatusProvider.notifier).definir(PosTerminalStatut.actif);
        final session = PosSession.fromJson(data['data'] as Map<String, dynamic>);
        await _posStorage.saveSession(session.toJson());
        state = AsyncValue.data(session);
        return null;
      }
      return data['error']?.toString() ?? "Erreur lors de l'ouverture de la session";
    } catch (e) {
      _majStatutTerminal(e);
      return messageErreurApi(e, 'Erreur réseau — impossible de contacter le serveur.');
    }
  }

  /// Met à jour [posTerminalStatusProvider] si l'exception correspond à un
  /// code de permission POS (403 {code, message}) — alimente le badge de
  /// statut (PosTerminalBanner, onglet Profil), sans bloquer l'opérateur.
  void _majStatutTerminal(Object e) {
    final code = codePosErreur(e);
    _ref.read(posTerminalStatusProvider.notifier).depuisCode(code);
  }

  /// Ferme la session. Bloque tant que des ventes locales restent en
  /// attente de synchronisation. Retourne {'error': ...} ou le récap
  /// backend en cas de succès.
  Future<Map<String, dynamic>> fermer(double fondsFermeture) async {
    if (!ConnectivityService().isOnline) {
      return {'error': 'La fermeture de session nécessite une connexion internet.'};
    }

    // Forcer une synchronisation complète avant de fermer : d'abord les
    // ventes POS (résultat détaillé par vente), puis le reste de la file.
    await _ref.read(posHistoriqueProvider.notifier).synchroniserVentesPos();
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
        'fonds_fermeture': double.parse(fondsFermeture.toStringAsFixed(2)),
      });
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _ref.read(posTerminalStatusProvider.notifier).definir(PosTerminalStatut.actif);
        await _posStorage.clearSession();
        state = const AsyncValue.data(null);
        // Contrat backend : data = {session: {...}, recap: {nb_ventes,
        // total_ventes, total_cash, par_methode}}. L'écran attend un map
        // plat avec en plus ecart_caisse, qui vit dans session.
        final d = data['data'] as Map<String, dynamic>? ?? {};
        final recap = d['recap'];
        if (recap is Map<String, dynamic>) {
          final session = d['session'];
          return {
            ...recap,
            if (session is Map<String, dynamic>)
              'ecart_caisse': session['ecart_caisse'],
          };
        }
        return d; // repli : ancien contrat plat
      }
      return {'error': data['error']?.toString() ?? 'Erreur lors de la fermeture de la session'};
    } catch (e) {
      _majStatutTerminal(e);
      return {'error': messageErreurApi(e, 'Erreur réseau — impossible de contacter le serveur.')};
    }
  }
}
