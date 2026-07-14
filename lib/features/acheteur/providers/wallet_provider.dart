import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/wallet.dart';
import '../../../models/wallet_transaction.dart';
import '../../../models/wallet_recharge.dart';
import '../../../models/wallet_retrait.dart';
import '../../../models/bon_cadeau.dart';
import '../../../models/wallet_code_paiement.dart';

/// Extrait la liste d'une réponse paginée
/// ({"results": [...], "count": ..., "next": ..., "previous": ...})
/// tout en tolérant l'ancien format où `data` était directement une liste.
List<dynamic> _extraireListe(dynamic data) {
  if (data is List) return data;
  if (data is Map<String, dynamic> && data['results'] is List) {
    return data['results'] as List;
  }
  return const [];
}

/// Résultat d'une page (initiale ou suivante) d'une liste paginée.
class _PageResult<T> {
  final List<T> items;
  final String? next;
  final String? erreur;
  const _PageResult({required this.items, this.next, this.erreur});
}

/// Charge une page depuis [url] (chemin relatif ou URL absolue — le
/// `next` renvoyé par le backend est une URL absolue, Dio la gère
/// nativement sans repasser par la baseUrl).
Future<_PageResult<T>> _chargerPage<T>(
  ApiClient api,
  String url,
  T Function(Map<String, dynamic>) fromJson,
  String erreurDefaut,
) async {
  try {
    final res  = await api.get(url);
    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      return _PageResult(items: const [], erreur: data['error']?.toString() ?? erreurDefaut);
    }
    final page  = data['data'];
    final items = _extraireListe(page)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
    final next = page is Map<String, dynamic> ? page['next'] as String? : null;
    return _PageResult(items: items, next: next);
  } catch (e) {
    return _PageResult(items: const [], erreur: e.toString());
  }
}

// ── Provider principal — solde wallet ─────────────────────────────────

final walletProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<Wallet>>((ref) {
  return WalletNotifier(ref.read(apiClientProvider));
});

// ── Providers de listes (paginées, infinite scroll) ────────────────────

final walletTransactionsProvider =
    StateNotifierProvider<WalletTransactionsNotifier,
        AsyncValue<List<WalletTransaction>>>((ref) {
  return WalletTransactionsNotifier(ref.read(apiClientProvider));
});

final walletRechargesProvider =
    StateNotifierProvider<WalletRechargesNotifier,
        AsyncValue<List<WalletRecharge>>>((ref) {
  return WalletRechargesNotifier(ref.read(apiClientProvider));
});

final walletRetraitsProvider =
    StateNotifierProvider<WalletRetraitsNotifier,
        AsyncValue<List<WalletRetrait>>>((ref) {
  return WalletRetraitsNotifier(ref.read(apiClientProvider));
});

final bonsAchetesProvider =
    StateNotifierProvider<BonsAchetesNotifier,
        AsyncValue<List<BonCadeau>>>((ref) {
  return BonsAchetesNotifier(ref.read(apiClientProvider));
});

final bonsRecusProvider =
    StateNotifierProvider<BonsRecusNotifier,
        AsyncValue<List<BonCadeau>>>((ref) {
  return BonsRecusNotifier(ref.read(apiClientProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// WalletNotifier — solde + toutes les opérations wallet
// ═══════════════════════════════════════════════════════════════════════

class WalletNotifier extends StateNotifier<AsyncValue<Wallet>> {
  final ApiClient _api;

  WalletNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  /// Charge / rafraîchit le solde depuis le serveur.
  /// TOUJOURS appelé depuis l'écran — jamais depuis un cache local.
  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.wallet);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          Wallet.fromJson(data['data'] as Map<String, dynamic>),
        );
      } else {
        state = AsyncValue.error(
          data['error']?.toString() ?? 'Erreur wallet',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Alias lisible pour l'UI
  Future<void> rafraichir() => charger();

  // ── Recharge ──────────────────────────────────────────────────────

  /// Initie une recharge Moncash/Natcash.
  /// Retourne l'URL de paiement Plopplop (à ouvrir en WebView)
  /// ou lance une exception avec le message d'erreur.
  Future<Map<String, dynamic>> initierRecharge({
    required double montant,
    required String methode,
  }) async {
    final res  = await _api.post(
      AppEndpoints.walletRechargeInitier,
      data: {
        'montant': montant,
        'methode': methode,
      },
    );
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['error']?.toString() ?? 'Erreur initiation recharge');
  }

  /// Vérifie le statut d'une recharge après retour WebView.
  Future<bool> verifierRecharge(int rechargeId) async {
    try {
      final res  = await _api.post(
        AppEndpoints.walletRechargeVerifier,
        data: {'recharge_id': rechargeId},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await rafraichir(); // Mettre à jour le solde
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Vérifie une recharge en réessayant plusieurs fois, espacé : la
  /// confirmation du fournisseur de paiement (webhook) peut arriver
  /// avec un léger décalage après le retour de l'utilisateur sur l'app.
  Future<bool> verifierRechargeAvecRetry(
    int rechargeId, {
    int tentatives = 4,
    Duration delai = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < tentatives; i++) {
      if (await verifierRecharge(rechargeId)) return true;
      if (i < tentatives - 1) await Future.delayed(delai);
    }
    return false;
  }

  /// Recharge hors ligne avec preuve image (multipart).
  Future<bool> soumettreRechargeHorsLigne({
    required double montant,
    required XFile preuve,
  }) async {
    try {
      final formData = FormData.fromMap({
        'montant': montant,
        'preuve': await MultipartFile.fromFile(
          preuve.path,
          filename: preuve.name,
        ),
      });
      final res  = await _api.postMultipart(
        AppEndpoints.walletRechargeHorsLigne,
        formData,
      );
      final data = res.data as Map<String, dynamic>;
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── Paiement commande ─────────────────────────────────────────────

  /// Paiement intégral d'une commande avec le wallet.
  Future<Map<String, dynamic>> payerCommande(String numeroCommande) async {
    final res  = await _api.post(
      AppEndpoints.walletPayer,
      data: {'numero_commande': numeroCommande},
    );
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      await rafraichir();
    }
    return data;
  }

  /// Paiement partiel (hybride) : wallet couvre une partie, autre méthode le reste.
  Future<Map<String, dynamic>> payerPartiel(String numeroCommande) async {
    final res  = await _api.post(
      AppEndpoints.walletPayerPartiel,
      data: {'numero_commande': numeroCommande},
    );
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      await rafraichir();
    }
    return data;
  }

  // ── Retrait ───────────────────────────────────────────────────────

  Future<bool> demanderRetrait({
    required double montant,
    required String canal,
    required String numeroTelephone,
  }) async {
    try {
      final res  = await _api.post(
        AppEndpoints.walletRetrait,
        data: {
          'montant':          montant,
          'canal':            canal,
          'numero_telephone': numeroTelephone,
        },
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await rafraichir();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── Bons cadeaux ─────────────────────────────────────────────────

  Future<bool> acheterBon({
    required double montant,
    String? emailDestinataire,
  }) async {
    try {
      final body = <String, dynamic>{'montant': montant};
      if (emailDestinataire != null && emailDestinataire.isNotEmpty) {
        body['email_destinataire'] = emailDestinataire;
      }
      final res  = await _api.post(AppEndpoints.walletBonAcheter, data: body);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await rafraichir();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>?> verifierBon(String code) async {
    try {
      final res  = await _api.post(
        AppEndpoints.walletBonVerifier,
        data: {'code': code},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> encaisserBon(String code) async {
    try {
      final res  = await _api.post(
        AppEndpoints.walletBonEncaisser,
        data: {'code': code},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await rafraichir();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── Code de paiement comptoir (POS) ─────────────────────────────────

  /// Génère un code de paiement à 6 chiffres, valable 5 minutes, à
  /// présenter à un opérateur POS. ONLINE UNIQUEMENT.
  Future<WalletCodePaiement> genererCodePaiement() async {
    final res  = await _api.post(AppEndpoints.walletCodePaiement);
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return WalletCodePaiement.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data['error']?.toString() ?? 'Erreur lors de la génération du code');
  }

  // ── Getters pratiques ─────────────────────────────────────────────

  double get solde => state.whenOrNull(data: (w) => w.solde) ?? 0.0;
  bool   get isActive => state.whenOrNull(data: (w) => w.isActive) ?? false;
}

// ═══════════════════════════════════════════════════════════════════════
// Notifiers pour les listes — infinite scroll via le curseur `next`
// ═══════════════════════════════════════════════════════════════════════

class WalletTransactionsNotifier
    extends StateNotifier<AsyncValue<List<WalletTransaction>>> {
  final ApiClient _api;
  String? _nextUrl;
  bool    _chargementPlus = false;

  WalletTransactionsNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  bool get hasPlus => _nextUrl != null;
  bool get chargementPlus => _chargementPlus;

  Future<void> charger() async {
    state = const AsyncValue.loading();
    final r = await _chargerPage(
      _api, AppEndpoints.walletTransactions, WalletTransaction.fromJson, 'Erreur transactions');
    _nextUrl = r.next;
    state = (r.erreur != null && r.items.isEmpty)
        ? AsyncValue.error(r.erreur!, StackTrace.current)
        : AsyncValue.data(r.items);
  }

  Future<void> chargerPlus() async {
    if (_nextUrl == null || _chargementPlus) return;
    _chargementPlus = true;
    state = AsyncValue.data(List.of(state.valueOrNull ?? const []));

    final r = await _chargerPage(
      _api, _nextUrl!, WalletTransaction.fromJson, 'Erreur transactions');
    _nextUrl = r.next;
    if (r.erreur == null) {
      state = AsyncValue.data([...(state.valueOrNull ?? const []), ...r.items]);
    }
    _chargementPlus = false;
    state = AsyncValue.data(List.of(state.valueOrNull ?? const []));
  }
}

class WalletRechargesNotifier
    extends StateNotifier<AsyncValue<List<WalletRecharge>>> {
  final ApiClient _api;
  String? _nextUrl;
  bool    _chargementPlus = false;

  WalletRechargesNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  bool get hasPlus => _nextUrl != null;
  bool get chargementPlus => _chargementPlus;

  Future<void> charger() async {
    state = const AsyncValue.loading();
    final r = await _chargerPage(
      _api, AppEndpoints.walletRecharges, WalletRecharge.fromJson, 'Erreur recharges');
    _nextUrl = r.next;
    state = (r.erreur != null && r.items.isEmpty)
        ? AsyncValue.error(r.erreur!, StackTrace.current)
        : AsyncValue.data(r.items);
  }

  Future<void> chargerPlus() async {
    if (_nextUrl == null || _chargementPlus) return;
    _chargementPlus = true;
    state = AsyncValue.data(List.of(state.valueOrNull ?? const []));

    final r = await _chargerPage(
      _api, _nextUrl!, WalletRecharge.fromJson, 'Erreur recharges');
    _nextUrl = r.next;
    if (r.erreur == null) {
      state = AsyncValue.data([...(state.valueOrNull ?? const []), ...r.items]);
    }
    _chargementPlus = false;
    state = AsyncValue.data(List.of(state.valueOrNull ?? const []));
  }
}

class WalletRetraitsNotifier
    extends StateNotifier<AsyncValue<List<WalletRetrait>>> {
  final ApiClient _api;
  String? _nextUrl;
  bool    _chargementPlus = false;

  WalletRetraitsNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  bool get hasPlus => _nextUrl != null;
  bool get chargementPlus => _chargementPlus;

  Future<void> charger() async {
    state = const AsyncValue.loading();
    final r = await _chargerPage(
      _api, AppEndpoints.walletRetraits, WalletRetrait.fromJson, 'Erreur retraits');
    _nextUrl = r.next;
    state = (r.erreur != null && r.items.isEmpty)
        ? AsyncValue.error(r.erreur!, StackTrace.current)
        : AsyncValue.data(r.items);
  }

  Future<void> chargerPlus() async {
    if (_nextUrl == null || _chargementPlus) return;
    _chargementPlus = true;
    state = AsyncValue.data(List.of(state.valueOrNull ?? const []));

    final r = await _chargerPage(
      _api, _nextUrl!, WalletRetrait.fromJson, 'Erreur retraits');
    _nextUrl = r.next;
    if (r.erreur == null) {
      state = AsyncValue.data([...(state.valueOrNull ?? const []), ...r.items]);
    }
    _chargementPlus = false;
    state = AsyncValue.data(List.of(state.valueOrNull ?? const []));
  }
}

class BonsAchetesNotifier
    extends StateNotifier<AsyncValue<List<BonCadeau>>> {
  final ApiClient _api;
  String? _nextUrl;
  bool    _chargementPlus = false;

  BonsAchetesNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  bool get hasPlus => _nextUrl != null;
  bool get chargementPlus => _chargementPlus;

  Future<void> charger() async {
    state = const AsyncValue.loading();
    final r = await _chargerPage(
      _api, AppEndpoints.walletBons, BonCadeau.fromJson, 'Erreur bons achetés');
    _nextUrl = r.next;
    state = (r.erreur != null && r.items.isEmpty)
        ? AsyncValue.error(r.erreur!, StackTrace.current)
        : AsyncValue.data(r.items);
  }

  Future<void> chargerPlus() async {
    if (_nextUrl == null || _chargementPlus) return;
    _chargementPlus = true;
    state = AsyncValue.data(List.of(state.valueOrNull ?? const []));

    final r = await _chargerPage(
      _api, _nextUrl!, BonCadeau.fromJson, 'Erreur bons achetés');
    _nextUrl = r.next;
    if (r.erreur == null) {
      state = AsyncValue.data([...(state.valueOrNull ?? const []), ...r.items]);
    }
    _chargementPlus = false;
    state = AsyncValue.data(List.of(state.valueOrNull ?? const []));
  }
}

class BonsRecusNotifier
    extends StateNotifier<AsyncValue<List<BonCadeau>>> {
  final ApiClient _api;
  String? _nextUrl;
  bool    _chargementPlus = false;

  BonsRecusNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  bool get hasPlus => _nextUrl != null;
  bool get chargementPlus => _chargementPlus;

  Future<void> charger() async {
    state = const AsyncValue.loading();
    final r = await _chargerPage(
      _api, AppEndpoints.walletBonsRecus, BonCadeau.fromJson, 'Erreur bons reçus');
    _nextUrl = r.next;
    state = (r.erreur != null && r.items.isEmpty)
        ? AsyncValue.error(r.erreur!, StackTrace.current)
        : AsyncValue.data(r.items);
  }

  Future<void> chargerPlus() async {
    if (_nextUrl == null || _chargementPlus) return;
    _chargementPlus = true;
    state = AsyncValue.data(List.of(state.valueOrNull ?? const []));

    final r = await _chargerPage(
      _api, _nextUrl!, BonCadeau.fromJson, 'Erreur bons reçus');
    _nextUrl = r.next;
    if (r.erreur == null) {
      state = AsyncValue.data([...(state.valueOrNull ?? const []), ...r.items]);
    }
    _chargementPlus = false;
    state = AsyncValue.data(List.of(state.valueOrNull ?? const []));
  }
}
