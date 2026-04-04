import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/cache_manager.dart';
import '../../../core/offline/connectivity_service.dart';

class DashboardStats {
  final int     commandesEnAttente;
  final int     commandesConfirmees;
  final int     commandesLivrees;
  final int     commandesTotal;
  final double  revenusTotal;
  final double  revenusMois;
  final int     nbProduitsActifs;
  final int     nbProduitsEpuises;
  final int     alertesStock;
  final int     collectesAVenir;

  const DashboardStats({
    this.commandesEnAttente  = 0,
    this.commandesConfirmees = 0,
    this.commandesLivrees    = 0,
    this.commandesTotal      = 0,
    this.revenusTotal        = 0,
    this.revenusMois         = 0,
    this.nbProduitsActifs    = 0,
    this.nbProduitsEpuises   = 0,
    this.alertesStock        = 0,
    this.collectesAVenir     = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      DashboardStats(
        commandesEnAttente:  json['commandes_en_attente']  as int? ?? 0,
        commandesConfirmees: json['commandes_confirmees']  as int? ?? 0,
        commandesLivrees:    json['commandes_livrees']     as int? ?? 0,
        commandesTotal:      json['commandes_total']       as int? ?? 0,
        revenusTotal:        double.tryParse(
                               json['revenus_total']?.toString() ?? '0'
                             ) ?? 0,
        revenusMois:         double.tryParse(
                               json['revenus_mois']?.toString() ?? '0'
                             ) ?? 0,
        nbProduitsActifs:    json['nb_produits_actifs']    as int? ?? 0,
        nbProduitsEpuises:   json['nb_produits_epuises']   as int? ?? 0,
        alertesStock:        json['alertes_stock']         as int? ?? 0,
        collectesAVenir:     json['collectes_a_venir']     as int? ?? 0,
      );
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardStats>>((ref) {
  return DashboardNotifier(
    ref.read(apiClientProvider),
    ref.read(cacheManagerProvider),
    ConnectivityService(),
  );
});

class DashboardNotifier
    extends StateNotifier<AsyncValue<DashboardStats>> {
  final ApiClient           _api;
  final CacheManager        _cache;
  final ConnectivityService _conn;
  static const _cacheKey = 'dashboard_stats';

  DashboardNotifier(this._api, this._cache, this._conn)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();

    // Cache offline
    if (!_conn.isOnline) {
      final cached = _cache.getData(
        _cacheKey, ttl: const Duration(hours: 1),
      );
      if (cached != null) {
        state = AsyncValue.data(
          DashboardStats.fromJson(cached as Map<String, dynamic>)
        );
        return;
      }
    }

    try {
      final res  = await _api.get(AppEndpoints.producteurStats);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final d = data['data'] as Map<String, dynamic>;
        await _cache.saveData(_cacheKey, d);
        state = AsyncValue.data(DashboardStats.fromJson(d));
      }
    } catch (e, st) {
      final cached = _cache.getData(_cacheKey,
          ttl: const Duration(hours: 1));
      if (cached != null) {
        state = AsyncValue.data(
          DashboardStats.fromJson(cached as Map<String, dynamic>)
        );
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
