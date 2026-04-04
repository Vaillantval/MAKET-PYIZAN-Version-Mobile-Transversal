import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/cache_manager.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/produit.dart';

// ── Filtres catalogue ──────────────────────────────────────────

class CatalogueFiltre {
  final String search;
  final String categorieSlug;
  final String departement;
  final double? prixMin;
  final double? prixMax;
  final bool    featuredOnly;
  final int     page;

  const CatalogueFiltre({
    this.search        = '',
    this.categorieSlug = '',
    this.departement   = '',
    this.prixMin,
    this.prixMax,
    this.featuredOnly  = false,
    this.page          = 1,
  });

  CatalogueFiltre copyWith({
    String? search,
    String? categorieSlug,
    String? departement,
    double? prixMin,
    double? prixMax,
    bool?   featuredOnly,
    int?    page,
  }) => CatalogueFiltre(
    search:        search        ?? this.search,
    categorieSlug: categorieSlug ?? this.categorieSlug,
    departement:   departement   ?? this.departement,
    prixMin:       prixMin       ?? this.prixMin,
    prixMax:       prixMax       ?? this.prixMax,
    featuredOnly:  featuredOnly  ?? this.featuredOnly,
    page:          page          ?? this.page,
  );

  Map<String, dynamic> toQueryParams() {
    final p = <String, dynamic>{'page': page, 'page_size': AppConstants.pageSize};
    if (search.isNotEmpty)        p['search']      = search;
    if (categorieSlug.isNotEmpty) p['categorie']   = categorieSlug;
    if (departement.isNotEmpty)   p['departement'] = departement;
    if (prixMin != null)          p['prix_min']    = prixMin;
    if (prixMax != null)          p['prix_max']    = prixMax;
    if (featuredOnly)             p['featured']    = '1';
    return p;
  }
}

// ── État catalogue ─────────────────────────────────────────────

class CatalogueState {
  final List<Produit> produits;
  final List<Produit> produitsFeatured;
  final int           total;
  final bool          hasMore;
  final bool          isLoading;
  final bool          isLoadingMore;
  final bool          isOffline;
  final String?       error;
  final CatalogueFiltre filtre;

  const CatalogueState({
    this.produits         = const [],
    this.produitsFeatured = const [],
    this.total            = 0,
    this.hasMore          = false,
    this.isLoading        = false,
    this.isLoadingMore    = false,
    this.isOffline        = false,
    this.error,
    this.filtre           = const CatalogueFiltre(),
  });

  CatalogueState copyWith({
    List<Produit>?    produits,
    List<Produit>?    produitsFeatured,
    int?              total,
    bool?             hasMore,
    bool?             isLoading,
    bool?             isLoadingMore,
    bool?             isOffline,
    String?           error,
    CatalogueFiltre?  filtre,
  }) => CatalogueState(
    produits:         produits         ?? this.produits,
    produitsFeatured: produitsFeatured ?? this.produitsFeatured,
    total:            total            ?? this.total,
    hasMore:          hasMore          ?? this.hasMore,
    isLoading:        isLoading        ?? this.isLoading,
    isLoadingMore:    isLoadingMore    ?? this.isLoadingMore,
    isOffline:        isOffline        ?? this.isOffline,
    error:            error,
    filtre:           filtre           ?? this.filtre,
  );
}

// ── Provider Catalogue ─────────────────────────────────────────

final catalogueProvider =
    StateNotifierProvider<CatalogueNotifier, CatalogueState>((ref) {
  return CatalogueNotifier(
    ref.read(apiClientProvider),
    ref.read(cacheManagerProvider),
    ConnectivityService(),
  );
});

class CatalogueNotifier extends StateNotifier<CatalogueState> {
  final ApiClient          _api;
  final CacheManager       _cache;
  final ConnectivityService _conn;

  CatalogueNotifier(this._api, this._cache, this._conn)
      : super(const CatalogueState()) {
    charger();
  }

  Future<void> charger({CatalogueFiltre? filtre}) async {
    final f = filtre ?? const CatalogueFiltre();
    state = state.copyWith(isLoading: true, error: null, filtre: f);

    // Essayer le cache si hors ligne
    if (!_conn.isOnline) {
      final cached = _cache.getCatalogue();
      if (cached != null) {
        final produits = cached
            .map((e) => Produit.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          produits:  produits,
          isLoading: false,
          isOffline: true,
        );
        return;
      }
    }

    try {
      final res = await _api.get(
        AppEndpoints.produits,
        queryParameters: f.toQueryParams(),
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final d       = data['data'] as Map<String, dynamic>;
        final results = (d['results'] as List)
            .map((e) => Produit.fromJson(e as Map<String, dynamic>))
            .toList();

        // Mettre en cache
        await _cache.saveCatalogue(d['results'] as List);

        state = state.copyWith(
          produits:  results,
          total:     d['count'] as int? ?? 0,
          hasMore:   d['next'] != null,
          isLoading: false,
          isOffline: false,
          filtre:    f,
        );
      }
    } catch (e) {
      // Fallback cache
      final cached = _cache.getCatalogue();
      if (cached != null) {
        state = state.copyWith(
          produits:  cached
              .map((e) => Produit.fromJson(e as Map<String, dynamic>))
              .toList(),
          isLoading: false,
          isOffline: true,
        );
      } else {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> chargerPlus() async {
    if (!state.hasMore || state.isLoadingMore) return;
    final nextPage = state.filtre.page + 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      final res = await _api.get(
        AppEndpoints.produits,
        queryParameters: state.filtre
            .copyWith(page: nextPage)
            .toQueryParams(),
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final d       = data['data'] as Map<String, dynamic>;
        final results = (d['results'] as List)
            .map((e) => Produit.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          produits:      [...state.produits, ...results],
          hasMore:       d['next'] != null,
          isLoadingMore: false,
          filtre:        state.filtre.copyWith(page: nextPage),
        );
      }
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void appliquerFiltre(CatalogueFiltre filtre) => charger(filtre: filtre);

  void reinitialiser() => charger(filtre: const CatalogueFiltre());
}

// ── Provider Catégories ────────────────────────────────────────

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api   = ref.read(apiClientProvider);
  final cache = ref.read(cacheManagerProvider);

  final cached = cache.getData('categories', ttl: const Duration(hours: 6));
  if (cached != null) return List<Map<String, dynamic>>.from(cached as List);

  final res  = await api.get(AppEndpoints.categories);
  final data = res.data as Map<String, dynamic>;
  if (data['success'] == true) {
    final list = data['data'] as List;
    await cache.saveData('categories', list);
    return List<Map<String, dynamic>>.from(list);
  }
  return [];
});

// ── Provider Détail Produit ────────────────────────────────────

final produitDetailProvider =
    FutureProvider.family<Produit?, String>((ref, slug) async {
  final api = ref.read(apiClientProvider);
  try {
    final res  = await api.get(AppEndpoints.produitDetail(slug));
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return Produit.fromJson(data['data'] as Map<String, dynamic>);
    }
  } catch (_) {}
  return null;
});
