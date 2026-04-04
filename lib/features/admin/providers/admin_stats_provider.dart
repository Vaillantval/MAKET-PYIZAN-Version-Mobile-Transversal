import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/cache_manager.dart';
import '../../../core/offline/connectivity_service.dart';

class AdminStats {
  // Utilisateurs
  final int totalUsers;
  final int totalProducteurs;
  final int producteursActifs;
  final int producteursAttente;
  final int totalAcheteurs;
  final int nouveauxUsers30j;
  // Commandes
  final int    totalCommandes;
  final int    commandesEnAttente;
  final int    commandesLivrees;
  final int    commandesLitige;
  final int    commandesMois;
  // Revenus
  final double revenuTotal;
  final double revenuMois;
  final double revenu7j;
  // Paiements
  final int    paiementsAVerifier;
  final double montantAVerifier;
  // Produits & Stock
  final int totalProduits;
  final int produitsEpuises;
  final int alertesStock;
  // Collectes
  final int collectesPlanifiees;
  final int collectesEnCours;
  final int collectesEnRetard;
  // Vouchers
  final int vouchersActifs;

  const AdminStats({
    this.totalUsers           = 0,
    this.totalProducteurs     = 0,
    this.producteursActifs    = 0,
    this.producteursAttente   = 0,
    this.totalAcheteurs       = 0,
    this.nouveauxUsers30j     = 0,
    this.totalCommandes       = 0,
    this.commandesEnAttente   = 0,
    this.commandesLivrees     = 0,
    this.commandesLitige      = 0,
    this.commandesMois        = 0,
    this.revenuTotal          = 0,
    this.revenuMois           = 0,
    this.revenu7j             = 0,
    this.paiementsAVerifier   = 0,
    this.montantAVerifier     = 0,
    this.totalProduits        = 0,
    this.produitsEpuises      = 0,
    this.alertesStock         = 0,
    this.collectesPlanifiees  = 0,
    this.collectesEnCours     = 0,
    this.collectesEnRetard    = 0,
    this.vouchersActifs       = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> j) => AdminStats(
    totalUsers:          j['total_users']           as int?    ?? 0,
    totalProducteurs:    j['total_producteurs']      as int?    ?? 0,
    producteursActifs:   j['producteurs_actifs']     as int?    ?? 0,
    producteursAttente:  j['producteurs_attente']    as int?    ?? 0,
    totalAcheteurs:      j['total_acheteurs']        as int?    ?? 0,
    nouveauxUsers30j:    j['nouveaux_users_30j']     as int?    ?? 0,
    totalCommandes:      j['total_commandes']        as int?    ?? 0,
    commandesEnAttente:  j['commandes_en_attente']   as int?    ?? 0,
    commandesLivrees:    j['commandes_livrees']      as int?    ?? 0,
    commandesLitige:     j['commandes_litige']       as int?    ?? 0,
    commandesMois:       j['commandes_mois']         as int?    ?? 0,
    revenuTotal:         double.tryParse(j['revenu_total']?.toString() ?? '0')  ?? 0,
    revenuMois:          double.tryParse(j['revenu_mois']?.toString()  ?? '0')  ?? 0,
    revenu7j:            double.tryParse(j['revenu_7j']?.toString()    ?? '0')  ?? 0,
    paiementsAVerifier:  j['paiements_a_verifier']  as int?    ?? 0,
    montantAVerifier:    double.tryParse(j['montant_a_verifier']?.toString() ?? '0') ?? 0,
    totalProduits:       j['total_produits']         as int?    ?? 0,
    produitsEpuises:     j['produits_epuises']       as int?    ?? 0,
    alertesStock:        j['alertes_stock']          as int?    ?? 0,
    collectesPlanifiees: j['collectes_planifiees']   as int?    ?? 0,
    collectesEnCours:    j['collectes_en_cours']     as int?    ?? 0,
    collectesEnRetard:   j['collectes_en_retard']    as int?    ?? 0,
    vouchersActifs:      j['vouchers_actifs']        as int?    ?? 0,
  );
}

final adminStatsProvider =
    StateNotifierProvider<AdminStatsNotifier, AsyncValue<AdminStats>>((ref) {
  return AdminStatsNotifier(
    ref.read(apiClientProvider),
    ref.read(cacheManagerProvider),
    ConnectivityService(),
  );
});

class AdminStatsNotifier
    extends StateNotifier<AsyncValue<AdminStats>> {
  final ApiClient           _api;
  final CacheManager        _cache;
  final ConnectivityService _conn;
  static const _key = 'admin_stats';

  AdminStatsNotifier(this._api, this._cache, this._conn)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();

    if (!_conn.isOnline) {
      final cached = _cache.getData(_key,
          ttl: const Duration(minutes: 30));
      if (cached != null) {
        state = AsyncValue.data(
          AdminStats.fromJson(cached as Map<String, dynamic>));
        return;
      }
    }

    try {
      final res  = await _api.get(AppEndpoints.adminStats);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final d = data['data'] as Map<String, dynamic>;
        await _cache.saveData(_key, d,
            ttl: const Duration(minutes: 30));
        state = AsyncValue.data(AdminStats.fromJson(d));
      }
    } catch (e, st) {
      final cached = _cache.getData(_key,
          ttl: const Duration(minutes: 30));
      if (cached != null) {
        state = AsyncValue.data(
          AdminStats.fromJson(cached as Map<String, dynamic>));
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
