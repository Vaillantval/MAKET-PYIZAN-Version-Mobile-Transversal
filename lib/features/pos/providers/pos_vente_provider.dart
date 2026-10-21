import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/offline/offline_manager.dart';
import '../../../core/offline/sync_queue.dart';
import '../../../core/storage/pos_local_storage.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/pos_item.dart';
import '../../../models/pos_sale.dart';
import 'pos_catalogue_provider.dart';
import 'pos_exceptions.dart';
import 'pos_session_provider.dart';
import 'pos_terminal_status_provider.dart';

final posHistoriqueProvider =
    StateNotifierProvider<PosHistoriqueNotifier, AsyncValue<List<PosSale>>>((ref) {
  return PosHistoriqueNotifier(
    ref.read(apiClientProvider),
    ref.read(posLocalStorageProvider),
    ref.read(syncQueueProvider),
    ref.read(offlineManagerProvider),
    ref,
  );
});

class PosHistoriqueNotifier extends StateNotifier<AsyncValue<List<PosSale>>> {
  final ApiClient       _api;
  final PosLocalStorage _local;
  final SyncQueue       _queue;
  final OfflineManager  _offline;
  final Ref             _ref;

  PosHistoriqueNotifier(this._api, this._local, this._queue, this._offline, this._ref)
      : super(const AsyncValue.loading()) {
    charger();
  }

  /// Recharge l'historique local. Si en ligne, synchronise d'abord les
  /// ventes POS en attente (résultat détaillé par vente), puis tente
  /// une réconciliation best-effort via le rapport serveur pour tout
  /// ce qui resterait "enAttente".
  Future<void> charger() async {
    if (ConnectivityService().isOnline) {
      await synchroniserVentesPos();
      await _reconcilierAvecServeur();
    }

    final ventes = _local.getAllSales()
        .map((e) => PosSale.fromJson(e))
        .toList()
      ..sort((a, b) => b.vendueLe.compareTo(a.vendueLe));

    state = AsyncValue.data(ventes);
  }

  /// Synchronise spécifiquement les ventes POS en attente en traitant
  /// le résultat PAR VENTE renvoyé par POST /api/pos/sync/ (contrat
  /// confirmé) :
  /// - created / duplicate → vente confirmée localement (purge de la
  ///   file) ; si stock_conflict: true, la vente reste créée mais un
  ///   badge d'avertissement est affiché.
  /// - rejected → DÉFINITIF, jamais re-queuée (ex : paiement wallet
  ///   refusé) — l'opérateur est alerté via le statut "Rejetée".
  /// - erreur réseau → l'action reste en file pour une prochaine
  ///   tentative (retry incrémenté).
  ///
  /// Ne touche jamais aux autres types d'action de la SyncQueue
  /// partagée (OfflineManager.syncAll() s'en charge, et ignore lui-même
  /// les ventes POS pour éviter toute course entre les deux).
  Future<void> synchroniserVentesPos() async {
    if (!ConnectivityService().isOnline) return;

    final actions = _queue.getAll()
        .where((a) => a.type == SyncActionType.posSale)
        .toList();
    if (actions.isEmpty) return;

    for (final action in actions) {
      try {
        final res  = await _api.post(action.endpoint, data: action.payload);
        final data = res.data as Map<String, dynamic>;
        // Contrat backend : data['data']['resultats'] (repli sur l'ancien
        // emplacement plat data['resultats'] par tolérance).
        final d = data['data'];
        final resultats = (d is Map<String, dynamic>
            ? d['resultats']
            : data['resultats']) as List? ?? const [];

        for (final raw in resultats) {
          final r   = raw as Map<String, dynamic>;
          final key = r['idempotency_key']?.toString();
          if (key == null) continue;

          final localSale = _local.getAllSales()
              .map((e) => PosSale.fromJson(e))
              .where((s) => s.idempotencyKey == key)
              .firstOrNull;
          if (localSale == null) continue;

          switch (r['status']?.toString()) {
            case 'created':
            case 'duplicate':
              await _local.saveSale(localSale.copyWith(
                numeroVente:   r['numero_vente']?.toString() ?? localSale.numeroVente,
                statut:        'validee',
                syncStatus:    'synchronisee',
                stockConflict: r['stock_conflict'] == true,
              ).toJson());
              break;
            case 'rejected':
              await _local.saveSale(localSale.copyWith(
                statut:     'rejetee',
                syncStatus: 'rejetee',
                erreurSync: r['erreur']?.toString(),
              ).toJson());
              break;
          }
        }

        await _queue.remove(action.id);
      } catch (e) {
        if (_isNetworkError(e)) {
          await _queue.incrementRetry(action.id);
          break; // Réseau instable — on arrête, on réessaiera plus tard
        } else {
          // Erreur inattendue (ni réseau, ni un rejet métier normal déjà
          // couvert par 'resultats') : on retente plus tard plutôt que
          // de perdre discrètement la vente.
          await _queue.incrementRetry(action.id);
        }
      }
    }
  }

  Future<void> _reconcilierAvecServeur() async {
    final pendantes = _local.getAllSales()
        .map((e) => PosSale.fromJson(e))
        .where((s) => s.syncStatus == 'enAttente')
        .toList();
    if (pendantes.isEmpty) return;

    try {
      // Priorité à session_id (contrat backend) quand une session est
      // suivie localement ; repli sur date sinon (ex: ventes orphelines
      // d'une session déjà fermée localement).
      final sessionId = _ref.read(posSessionProvider).valueOrNull?.id;
      final Map<String, dynamic> queryParams;
      if (sessionId != null) {
        queryParams = {'session_id': sessionId};
      } else {
        final today = DateTime.now();
        final dateStr = '${today.year.toString().padLeft(4, '0')}-'
            '${today.month.toString().padLeft(2, '0')}-'
            '${today.day.toString().padLeft(2, '0')}';
        queryParams = {'date': dateStr};
      }

      final res = await _api.get(AppEndpoints.posRapports, queryParameters: queryParams);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] != true) return;

      // Contrat backend : data['data']['ventes'] = [{idempotency_key, numero_vente, statut}, ...]
      final rawData = data['data'];
      final ventesData = rawData is Map<String, dynamic> ? rawData['ventes'] : null;
      if (ventesData is! List) {
        final queryStr = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
        debugPrint(
          '[POS] Réconciliation : clé "ventes" absente de la réponse '
          'de ${AppEndpoints.posRapports}?$queryStr',
        );
        return;
      }
      final serverVentes = ventesData;

      for (final raw in serverVentes) {
        final m   = raw as Map<String, dynamic>;
        final key = m['idempotency_key']?.toString();
        if (key == null) continue;
        final match = pendantes.where((s) => s.idempotencyKey == key).firstOrNull;
        if (match == null) continue;

        final updated = match.copyWith(
          numeroVente: m['numero_vente']?.toString() ?? match.numeroVente,
          statut:      m['statut']?.toString() ?? match.statut,
          syncStatus:  'synchronisee',
        );
        await _local.saveSale(updated.toJson());
      }
    } catch (_) {
      // Best-effort — on garde l'historique local tel quel
    }
  }

  /// Force une synchronisation complète de la SyncQueue puis réconcilie.
  Future<void> synchroniserMaintenant() async {
    await _offline.syncAll();
    await charger();
  }

  int get nbEnAttente => _local.countBySyncStatus('enAttente');

  /// Crée une vente et l'enregistre dans l'historique local.
  ///
  /// CASH / MONCASH / NATCASH (montantWallet == 0, déclaratif pour
  /// moncash/natcash) : ONLINE → POST direct sur /api/pos/vente/ ;
  /// OFFLINE → mise en SyncQueue existante (batch de 1) vers
  /// /api/pos/sync/, tolérant côté serveur au stock et idempotent via
  /// idempotency_key.
  ///
  /// WALLET / HYBRIDE (montantWallet > 0) : RÈGLE ABSOLUE — ne passe
  /// JAMAIS par la SyncQueue. Exige d'être en ligne (sinon
  /// [PosVenteException] code OFFLINE) et propage toute erreur métier
  /// (CODE_INVALIDE, SOLDE_INSUFFISANT) ou réseau via [PosVenteException]
  /// au lieu de mettre en file d'attente.
  Future<PosSale> vendre({
    required List<PosItem> items,
    required double montantTotal,
    String methodePaiement = 'cash',
    double montantWallet = 0,
    String? codePaiement,
    String? referenceTransaction,
  }) async {
    final idempotencyKey = const Uuid().v4();
    // Horodatage UTC explicite : le backend rattache une vente synchronisée
    // à la session qui couvrait vendue_le — une heure « naïve » serait lue
    // à l'heure d'Haïti, faussée sur un terminal réglé sur un autre fuseau.
    final vendueLe = DateTime.now().toUtc().toIso8601String();

    final payloadVente = <String, dynamic>{
      'idempotency_key':  idempotencyKey,
      'items':            items.map((i) => i.toPayload()).toList(),
      'methode_paiement': methodePaiement,
      'vendue_le':        vendueLe,
      if (montantWallet > 0)
        'montant_wallet': double.parse(montantWallet.toStringAsFixed(2)),
      if (codePaiement != null && codePaiement.isNotEmpty)
        'code_paiement': codePaiement,
      if (referenceTransaction != null && referenceTransaction.isNotEmpty)
        'reference_transaction': referenceTransaction,
    };

    var sale = PosSale(
      idempotencyKey:  idempotencyKey,
      items:           items,
      montantTotal:    montantTotal,
      methodePaiement: methodePaiement,
      montantWallet:   montantWallet,
      vendueLe:        vendueLe,
      syncStatus:      'enAttente',
    );

    final walletImplique = montantWallet > 0;

    if (walletImplique) {
      // Wallet / hybride : jamais de mise en queue, jamais offline.
      if (!ConnectivityService().isOnline) {
        throw const PosVenteException(
          'OFFLINE',
          'Le paiement par portefeuille nécessite une connexion internet.',
        );
      }
      try {
        final res  = await _posterVenteWallet(payloadVente);
        final data = res.data as Map<String, dynamic>;
        if (data['success'] != true) {
          final erreur = data['error']?.toString();
          final code   = _classifierErreurWallet(data['code']?.toString(), erreur);
          throw PosVenteException(code, _messageErreurWallet(code, erreur));
        }
        final v = _extraireVente(data);
        sale = sale.copyWith(
          numeroVente: v['numero_vente']?.toString(),
          statut:      v['statut']?.toString() ?? 'validee',
          syncStatus:  'synchronisee',
        );
      } on PosVenteException {
        rethrow;
      } catch (e) {
        final codeTerminal = _signalerTerminalNonAutorise(e);
        if (codeTerminal != null) {
          throw PosVenteException(codeTerminal, messagePosErreur(e) ??
              'Terminal non autorisé — contactez votre administrateur.');
        }
        // Refus métier (HTTP 400 : solde insuffisant, code invalide ou
        // expiré, session fermée…) — Dio le lève en exception.
        final refus = _refusMetier(e);
        if (refus != null) {
          _verifierSessionFermee(refus.message);
          final code = _classifierErreurWallet(refus.code, refus.message);
          throw PosVenteException(code, _messageErreurWallet(code, refus.message));
        }
        throw const PosVenteException(
          'OFFLINE',
          'La connexion a été interrompue pendant le paiement : la vente n\'a '
          'peut-être pas été enregistrée. Vérifiez l\'historique avant de '
          'réessayer (un code déjà utilisé sera refusé, sans double débit).',
        );
      }
    } else if (ConnectivityService().isOnline) {
      try {
        final res  = await _api.post(AppEndpoints.posVente, data: payloadVente);
        final data = res.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final v = _extraireVente(data);
          sale = sale.copyWith(
            numeroVente: v['numero_vente']?.toString(),
            statut:      v['statut']?.toString() ?? 'validee',
            syncStatus:  'synchronisee',
          );
        } else {
          final message = extraireMessageErreur(
              data['error'], 'Vente refusée par le serveur.');
          _verifierSessionFermee(message);
          throw PosVenteException('REJETEE', message);
        }
      } on PosVenteException {
        rethrow;
      } catch (e) {
        // Refus définitif (400 métier, 403 terminal) : la vente n'existe
        // pas côté serveur — ne pas l'enregistrer comme faite, ne pas
        // vider le panier ni décrémenter le stock local.
        final codeTerminal = _signalerTerminalNonAutorise(e);
        if (codeTerminal != null) {
          throw PosVenteException(codeTerminal, messagePosErreur(e) ??
              'Terminal non autorisé — contactez votre administrateur.');
        }
        final refus = _refusMetier(e);
        if (refus != null) {
          _verifierSessionFermee(refus.message);
          throw PosVenteException('REJETEE', refus.message);
        }
        // Réseau ou erreur serveur (5xx) : la vente a pu passer ou non —
        // la file la resoumet avec la même idempotency_key (sans doublon).
        await _mettreEnQueue(idempotencyKey, payloadVente);
      }
    } else {
      await _mettreEnQueue(idempotencyKey, payloadVente);
    }

    await _local.saveSale(sale.toJson());

    // Décrémenter le stock EN CACHE (cohérence visuelle entre deux syncs).
    // Le stock est toujours suivi en unité de base — convertir la
    // quantité vendue (ex: 2 sacs) via facteurConversion (ex: 50) pour
    // décrémenter du bon montant (ex: 100 kg), pas juste "2".
    final catalogueNotifier = _ref.read(posCatalogueProvider.notifier);
    for (final item in items) {
      await catalogueNotifier.decrementerStock(
        item.produitId, item.lotId, item.quantite * item.facteurConversion,
      );
    }

    await charger();
    return sale;
  }

  /// POST /api/pos/vente/ imbrique la vente sous data['data']['vente']
  /// (avec un frère 'created'). Repli sur data['data'] directement au
  /// cas où un ancien contrat plat serait encore servi.
  Map<String, dynamic> _extraireVente(Map<String, dynamic> data) {
    final d = data['data'] as Map<String, dynamic>;
    final v = d['vente'];
    return v is Map<String, dynamic> ? v : d;
  }

  /// POST /api/pos/vente/ pour un paiement wallet, avec UNE nouvelle
  /// tentative (même idempotency_key) si la réponse se perd en route : le
  /// backend renvoie alors la vente existante sans re-débiter le client.
  Future<Response> _posterVenteWallet(Map<String, dynamic> payload) async {
    try {
      return await _api.post(AppEndpoints.posVente, data: payload);
    } catch (e) {
      if (!_isNetworkError(e) && !_isErreurServeur(e)) rethrow;
      return _api.post(AppEndpoints.posVente, data: payload);
    }
  }

  /// 403 TERMINAL_* / ROLE_INVALIDE : met à jour le statut du terminal
  /// (écran bloquant de la caisse) et renvoie le code (null sinon).
  String? _signalerTerminalNonAutorise(Object e) {
    final code = codePosErreur(e);
    return _ref.read(posTerminalStatusProvider.notifier).depuisCode(code)
        ? code
        : null;
  }

  /// Refus métier du backend (HTTP 4xx avec {success:false, error, code?}
  /// ou {code, message} pour les permissions POS).
  /// « Aucune session de caisse ouverte » : l'administration a clôturé la
  /// session depuis le tableau de bord. Oublier la session locale et
  /// signaler SESSION_FERMEE (l'écran propose d'en ouvrir une nouvelle).
  void _verifierSessionFermee(String message) {
    final m = message.toLowerCase();
    if (!m.contains('session') || !(m.contains('aucune') || m.contains('clôtur') ||
        m.contains('ferm'))) {
      return;
    }
    _ref.read(posSessionProvider.notifier).sessionFermeeParServeur();
    throw const PosVenteException(
      'SESSION_FERMEE',
      'Votre session de caisse a été clôturée par l\'administration. '
      'Ouvrez une nouvelle session pour continuer à vendre.',
    );
  }

  ({String? code, String message})? _refusMetier(Object e) {
    if (e is! DioException) return null;
    final status = e.response?.statusCode ?? 0;
    if (status < 400 || status >= 500) return null;
    final data = e.response?.data;
    if (data is! Map) {
      return (code: null, message: 'Vente refusée par le serveur ($status).');
    }
    return (
      code: data['code']?.toString(),
      message: extraireMessageErreur(
        data['error'] ?? data['message'] ?? data['detail'] ?? data,
        'Vente refusée par le serveur.',
      ),
    );
  }

  String _classifierErreurWallet(String? codeServeur, String? erreur) {
    if (codeServeur == 'SOLDE_INSUFFISANT') return 'SOLDE_INSUFFISANT';
    final e = (erreur ?? '').toUpperCase();
    if (e.contains('CODE')) return 'CODE_INVALIDE';
    if (e.contains('SOLDE') || e.contains('INSUFFISANT')) return 'SOLDE_INSUFFISANT';
    return 'AUTRE';
  }

  String _messageErreurWallet(String code, String? erreurBrute) {
    switch (code) {
      case 'CODE_INVALIDE':
        return 'Code invalide ou expiré — demandez au client de générer '
            'un nouveau code.';
      case 'SOLDE_INSUFFISANT':
        return 'Solde insuffisant — le code reste valable : le client peut '
            'recharger son portefeuille puis vous pouvez réessayer.';
      default:
        return erreurBrute ?? 'Erreur lors du paiement par portefeuille.';
    }
  }

  Future<void> _mettreEnQueue(String idempotencyKey, Map<String, dynamic> payloadVente) {
    return _queue.add(SyncAction(
      type:     SyncActionType.posSale,
      endpoint: AppEndpoints.posSync,
      method:   'POST',
      payload:  {'ventes': [payloadVente]},
      localId:  idempotencyKey,
    ));
  }

  bool _isErreurServeur(dynamic e) =>
      e is DioException && (e.response?.statusCode ?? 0) >= 500;

  bool _isNetworkError(dynamic e) =>
      e is DioException &&
      (e.type == DioExceptionType.connectionTimeout ||
       e.type == DioExceptionType.receiveTimeout    ||
       e.type == DioExceptionType.connectionError);
}
