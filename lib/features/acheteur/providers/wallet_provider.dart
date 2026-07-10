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

// ── Provider principal — solde wallet ─────────────────────────────────

final walletProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<Wallet>>((ref) {
  return WalletNotifier(ref.read(apiClientProvider));
});

// ── Providers de listes ────────────────────────────────────────────────

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
// Notifiers pour les listes
// ═══════════════════════════════════════════════════════════════════════

class WalletTransactionsNotifier
    extends StateNotifier<AsyncValue<List<WalletTransaction>>> {
  final ApiClient _api;

  WalletTransactionsNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.walletTransactions);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      } else {
        state = AsyncValue.error(
          data['error']?.toString() ?? 'Erreur transactions',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class WalletRechargesNotifier
    extends StateNotifier<AsyncValue<List<WalletRecharge>>> {
  final ApiClient _api;

  WalletRechargesNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.walletRecharges);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => WalletRecharge.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      } else {
        state = AsyncValue.error(
          data['error']?.toString() ?? 'Erreur recharges',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class WalletRetraitsNotifier
    extends StateNotifier<AsyncValue<List<WalletRetrait>>> {
  final ApiClient _api;

  WalletRetraitsNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.walletRetraits);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => WalletRetrait.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      } else {
        state = AsyncValue.error(
          data['error']?.toString() ?? 'Erreur retraits',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class BonsAchetesNotifier
    extends StateNotifier<AsyncValue<List<BonCadeau>>> {
  final ApiClient _api;

  BonsAchetesNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.walletBons);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => BonCadeau.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      } else {
        state = AsyncValue.error(
          data['error']?.toString() ?? 'Erreur bons achetés',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class BonsRecusNotifier
    extends StateNotifier<AsyncValue<List<BonCadeau>>> {
  final ApiClient _api;

  BonsRecusNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.walletBonsRecus);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => BonCadeau.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      } else {
        state = AsyncValue.error(
          data['error']?.toString() ?? 'Erreur bons reçus',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
