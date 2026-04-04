# PROMPT CLAUDE CODE — Makèt Peyizan Mobile
# Flutter — Partie 2 : App Acheteur complète

---

## CONTEXTE

La Partie 1 (Fondations, Auth, Offline Engine) est déjà implémentée.
Tu vas maintenant créer tous les écrans de l'**expérience Acheteur**.

**Rappel palette :**
- Vert foncé  : `#1A6B2F`  — AppColors.vertFonce
- Vert vif    : `#27AE60`  — AppColors.vertVif
- Vert menthe : `#E8F8EE`  — AppColors.vertMenthe
- Jaune       : `#E8D800`  — AppColors.jaune

**API Base URL :** déjà configurée dans AppConstants.baseUrl

---

## FICHIERS À CRÉER

```
lib/features/acheteur/
├── screens/
│   ├── accueil_screen.dart
│   ├── catalogue_screen.dart
│   ├── produit_detail_screen.dart
│   ├── panier_screen.dart
│   ├── checkout_screen.dart
│   ├── commandes_screen.dart
│   ├── commande_detail_screen.dart
│   ├── profil_screen.dart
│   ├── adresses_screen.dart
│   ├── paiement_moncash_screen.dart
│   └── voucher_screen.dart
├── providers/
│   ├── catalogue_provider.dart
│   ├── panier_provider.dart
│   ├── commande_provider.dart
│   └── adresse_provider.dart
└── widgets/
    ├── produit_card.dart
    ├── categorie_chip.dart
    ├── panier_badge.dart
    ├── commande_statut_badge.dart
    └── adresse_card.dart

lib/shared/widgets/
├── offline_banner.dart        (déjà créé)
├── loading_widget.dart
├── empty_state.dart
├── error_widget.dart
├── htg_text.dart
└── geo_selector.dart          → sélecteur cascade géographique
```

---

## ÉTAPE 1 — Providers Catalogue

### `lib/features/acheteur/providers/catalogue_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/cache_manager.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/produit.dart';
import '../../../models/categorie.dart';

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
```

---

## ÉTAPE 2 — Provider Panier

### `lib/features/acheteur/providers/panier_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/offline_manager.dart';
import '../../../core/offline/sync_queue.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../models/panier.dart';

final panierProvider =
    StateNotifierProvider<PanierNotifier, AsyncValue<Panier>>((ref) {
  return PanierNotifier(
    ref.read(apiClientProvider),
    ref.read(offlineManagerProvider),
    ConnectivityService(),
  );
});

class PanierNotifier extends StateNotifier<AsyncValue<Panier>> {
  final ApiClient          _api;
  final OfflineManager     _offline;
  final ConnectivityService _conn;

  PanierNotifier(this._api, this._offline, this._conn)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.panier);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = AsyncValue.data(
          Panier.fromJson(data['data'] as Map<String, dynamic>)
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> ajouter(String slug, int quantite) async {
    final result = await _offline.execute(SyncAction(
      type:     SyncActionType.panierAjouter,
      endpoint: AppEndpoints.panierAjouter,
      method:   'POST',
      payload:  {'slug': slug, 'quantite': quantite},
    ));

    if (result.isSuccess && !result.isQueued) {
      final data = result.data as Map<String, dynamic>?;
      if (data?['success'] == true) {
        state = AsyncValue.data(
          Panier.fromJson(data!['data'] as Map<String, dynamic>)
        );
        return null; // succès
      }
      return data?['error']?.toString() ?? 'Erreur';
    } else if (result.isQueued) {
      return null; // mis en queue offline
    }
    return result.error;
  }

  Future<void> modifier(String slug, int quantite) async {
    final result = await _offline.execute(SyncAction(
      type:     SyncActionType.panierModifier,
      endpoint: AppEndpoints.panierModifier(slug),
      method:   'PATCH',
      payload:  {'quantite': quantite},
    ));
    if (result.isSuccess && !result.isQueued) {
      final data = result.data as Map<String, dynamic>?;
      if (data?['success'] == true) {
        state = AsyncValue.data(
          Panier.fromJson(data!['data'] as Map<String, dynamic>)
        );
      }
    }
  }

  Future<void> retirer(String slug) async {
    await _offline.execute(SyncAction(
      type:     SyncActionType.panierRetirer,
      endpoint: AppEndpoints.panierRetirer(slug),
      method:   'DELETE',
      payload:  {},
    ));
    await charger();
  }

  Future<void> vider() async {
    await _offline.execute(SyncAction(
      type:     SyncActionType.panierVider,
      endpoint: AppEndpoints.panierVider,
      method:   'DELETE',
      payload:  {},
    ));
    await charger();
  }

  int get nbArticles {
    return state.whenOrNull(data: (p) => p.nbArticles) ?? 0;
  }
}
```

---

## ÉTAPE 3 — Provider Commandes

### `lib/features/acheteur/providers/commande_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/commande.dart';

final commandesProvider =
    StateNotifierProvider<CommandeNotifier, AsyncValue<List<Commande>>>((ref) {
  return CommandeNotifier(ref.read(apiClientProvider));
});

class CommandeNotifier
    extends StateNotifier<AsyncValue<List<Commande>>> {
  final ApiClient _api;

  CommandeNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.mesCommandes);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => Commande.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Map<String, dynamic>?> passer({
    required String methodePaiement,
    required String modeLivraison,
    int?    adresseId,
    String  adresseTexte = '',
    String  ville        = '',
    String  departement  = '',
    String  notes        = '',
  }) async {
    try {
      final body = <String, dynamic>{
        'methode_paiement': methodePaiement,
        'mode_livraison':   modeLivraison,
        'notes':            notes,
      };
      if (adresseId != null) {
        body['adresse_livraison_id'] = adresseId;
      } else {
        body['adresse_livraison_text'] = adresseTexte;
        body['ville_livraison']        = ville;
        body['departement_livraison']  = departement;
      }

      final res  = await _api.post(AppEndpoints.commander, data: body);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await charger(); // Rafraîchir la liste
      }
      return data;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

// Détail d'une commande
final commandeDetailProvider =
    FutureProvider.family<Commande?, String>((ref, numero) async {
  final api = ref.read(apiClientProvider);
  try {
    final res  = await api.get(AppEndpoints.maCommande(numero));
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return Commande.fromJson(data['data'] as Map<String, dynamic>);
    }
  } catch (_) {}
  return null;
});
```

---

## ÉTAPE 4 — Provider Adresses

### `lib/features/acheteur/providers/adresse_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/adresse.dart';

final adressesProvider =
    StateNotifierProvider<AdresseNotifier, AsyncValue<List<Adresse>>>((ref) {
  return AdresseNotifier(ref.read(apiClientProvider));
});

class AdresseNotifier
    extends StateNotifier<AsyncValue<List<Adresse>>> {
  final ApiClient _api;

  AdresseNotifier(this._api) : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.adresses);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => Adresse.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> creer(Map<String, dynamic> body) async {
    try {
      final res  = await _api.post(AppEndpoints.adresses, data: body);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await charger();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> setDefault(int id) async {
    try {
      await _api.patch(AppEndpoints.adresseDefault(id), data: {});
      await charger();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> supprimer(int id) async {
    try {
      await _api.delete(AppEndpoints.adresseDetail(id));
      await charger();
      return true;
    } catch (_) {
      return false;
    }
  }

  Adresse? get adresseDefaut {
    return state.whenOrNull(
      data: (list) => list.firstWhere(
        (a) => a.isDefault,
        orElse: () => list.isNotEmpty ? list.first : null as Adresse,
      ),
    );
  }
}
```

---

## ÉTAPE 5 — Widgets partagés

### `lib/shared/widgets/loading_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({this.message, super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.vertVif),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, style: const TextStyle(color: AppColors.grisTexte)),
        ],
      ],
    ),
  );
}
```

---

### `lib/shared/widgets/empty_state.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String  emoji;
  final String  titre;
  final String? description;
  final String? boutonLabel;
  final VoidCallback? onBouton;

  const EmptyState({
    required this.emoji,
    required this.titre,
    this.description,
    this.boutonLabel,
    this.onBouton,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(titre,
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.vertFonce,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(description!,
              style: const TextStyle(
                fontSize: 14, color: AppColors.grisTexte,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (boutonLabel != null && onBouton != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBouton,
              child: Text(boutonLabel!),
            ),
          ],
        ],
      ),
    ),
  );
}
```

---

### `lib/shared/widgets/htg_text.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/utils/format_utils.dart';
import '../../core/constants/app_colors.dart';

class HtgText extends StatelessWidget {
  final dynamic  montant;
  final double   fontSize;
  final FontWeight fontWeight;
  final Color    color;
  final String?  suffix;

  const HtgText(
    this.montant, {
    this.fontSize   = 16,
    this.fontWeight = FontWeight.w700,
    this.color      = AppColors.vertFonce,
    this.suffix,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Text(
    '${FormatUtils.htg(montant)}${suffix ?? ''}',
    style: TextStyle(
      fontSize:   fontSize,
      fontWeight: fontWeight,
      color:      color,
    ),
  );
}
```

---

### `lib/shared/widgets/geo_selector.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/offline/cache_manager.dart';
import '../../core/constants/app_constants.dart';

/// Sélecteur géographique cascade :
/// Département → Commune → Section Communale
class GeoSelector extends ConsumerStatefulWidget {
  final Function(String dept, String commune, String section) onChanged;
  final String? initialDept;
  final String? initialCommune;
  final String? initialSection;

  const GeoSelector({
    required this.onChanged,
    this.initialDept,
    this.initialCommune,
    this.initialSection,
    super.key,
  });

  @override
  ConsumerState<GeoSelector> createState() => _GeoSelectorState();
}

class _GeoSelectorState extends ConsumerState<GeoSelector> {
  List<Map<String, dynamic>> _depts    = [];
  List<Map<String, dynamic>> _communes = [];
  List<String>               _sections = [];

  String? _selectedDept;
  String? _selectedCommune;
  String? _selectedSection;
  bool    _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerDepts();
  }

  Future<void> _chargerDepts() async {
    final cache = ref.read(cacheManagerProvider);
    final api   = ref.read(apiClientProvider);

    // Essayer le cache 24h
    final cached = cache.getGeo();
    if (cached != null) {
      final depts = (cached['departements'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      setState(() { _depts = depts; _loading = false; });
      _setInitialValues();
      return;
    }

    try {
      final res  = await api.get(AppEndpoints.geoArbre);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final geoData = data['data'] as Map<String, dynamic>;
        await cache.saveGeo(geoData);
        final depts = (geoData['departements'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        setState(() { _depts = depts; _loading = false; });
        _setInitialValues();
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _setInitialValues() {
    if (widget.initialDept != null) {
      _selectedDept = widget.initialDept;
      _chargerCommunes(widget.initialDept!);
    }
  }

  void _chargerCommunes(String deptSlug) {
    final dept = _depts.firstWhere(
      (d) => d['slug'] == deptSlug || d['nom'] == deptSlug,
      orElse: () => {},
    );
    if (dept.isEmpty) return;

    final communes = <Map<String, dynamic>>[];
    for (final arrond in (dept['arrondissements'] as List? ?? [])) {
      for (final commune in (arrond['communes'] as List? ?? [])) {
        communes.add(Map<String, dynamic>.from(commune as Map));
      }
    }
    setState(() {
      _communes        = communes;
      _selectedCommune = widget.initialCommune;
      _selectedSection = null;
      _sections        = [];
    });

    if (widget.initialCommune != null) {
      _chargerSections(widget.initialCommune!);
    }
  }

  void _chargerSections(String communeNom) {
    final commune = _communes.firstWhere(
      (c) => c['nom'] == communeNom,
      orElse: () => {},
    );
    if (commune.isEmpty) return;

    final sections = List<String>.from(
      (commune['sections_communales'] as List? ?? []).cast<String>()
    );
    setState(() {
      _sections        = sections;
      _selectedSection = widget.initialSection;
    });
  }

  void _notifyChanged() {
    widget.onChanged(
      _selectedDept    ?? '',
      _selectedCommune ?? '',
      _selectedSection ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.vertVif),
      );
    }

    return Column(
      children: [
        // Département
        _buildDropdown(
          label:    'Département',
          value:    _selectedDept,
          items:    _depts.map((d) => DropdownMenuItem(
            value: d['slug'] as String,
            child: Text(d['nom'] as String),
          )).toList(),
          onChanged: (v) {
            setState(() {
              _selectedDept    = v;
              _selectedCommune = null;
              _selectedSection = null;
              _communes        = [];
              _sections        = [];
            });
            if (v != null) _chargerCommunes(v);
            _notifyChanged();
          },
        ),
        const SizedBox(height: 12),

        // Commune
        _buildDropdown(
          label:    'Commune',
          value:    _selectedCommune,
          enabled:  _communes.isNotEmpty,
          items:    _communes.map((c) => DropdownMenuItem(
            value: c['nom'] as String,
            child: Text(c['nom'] as String),
          )).toList(),
          onChanged: (v) {
            setState(() {
              _selectedCommune = v;
              _selectedSection = null;
              _sections        = [];
            });
            if (v != null) _chargerSections(v);
            _notifyChanged();
          },
        ),
        const SizedBox(height: 12),

        // Section communale (optionnel)
        _buildDropdown(
          label:    'Section communale (optionnel)',
          value:    _selectedSection,
          enabled:  _sections.isNotEmpty,
          items:    _sections.map((s) => DropdownMenuItem(
            value: s, child: Text(s),
          )).toList(),
          onChanged: (v) {
            setState(() => _selectedSection = v);
            _notifyChanged();
          },
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String                    label,
    required T?                        value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>          onChanged,
    bool                               enabled = true,
  }) => DropdownButtonFormField<T>(
    value:       value,
    items:       items,
    onChanged:   enabled ? onChanged : null,
    isExpanded:  true,
    decoration: InputDecoration(
      labelText:   label,
      enabled:     enabled,
      filled:      true,
      fillColor:   enabled ? Colors.white : AppColors.grisClair,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
    ),
    hint: Text(
      enabled ? 'Sélectionner...' : 'Choisir d\'abord le niveau précédent',
      style: TextStyle(
        color: enabled ? AppColors.noir : AppColors.grisTexte,
        fontSize: 13,
      ),
    ),
  );
}
```

---

## ÉTAPE 6 — Widgets Acheteur

### `lib/features/acheteur/widgets/produit_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/produit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/format_utils.dart';

class ProduitCard extends StatelessWidget {
  final Produit      produit;
  final VoidCallback onTap;
  final VoidCallback? onAjouter;

  const ProduitCard({
    required this.produit,
    required this.onTap,
    this.onAjouter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ImageUtils.imageUrl(produit.imagePrincipale);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color:       Colors.black.withOpacity(0.07),
              blurRadius:  8,
              offset:      const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          height:   140,
                          width:    double.infinity,
                          fit:      BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor:      Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 140,
                              color:  Colors.white,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 140,
                            color:  AppColors.vertMenthe,
                            child:  const Center(
                              child: Text('🌿', style: TextStyle(fontSize: 40)),
                            ),
                          ),
                        )
                      : Container(
                          height: 140,
                          color:  AppColors.vertMenthe,
                          child:  const Center(
                            child: Text('🌿', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                ),
                // Badge featured
                if (produit.isFeatured)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:        AppColors.jaune,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '⭐ Vedette',
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.noir,
                        ),
                      ),
                    ),
                  ),
                // Badge stock faible
                if (produit.stockReel <= 5 && produit.stockReel > 0)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:        AppColors.rouge,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⚡ ${produit.stockReel} restants',
                        style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie
                  if (produit.categorie != null)
                    Text(
                      produit.categorie!['nom']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 10, color: AppColors.vertVif,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .3,
                      ),
                    ),
                  const SizedBox(height: 2),

                  // Nom
                  Text(
                    produit.nom,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.vertFonce,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Producteur
                  if (produit.producteur != null)
                    Text(
                      '📍 ${produit.producteur!['commune'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 11, color: AppColors.grisTexte,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Prix + bouton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FormatUtils.htg(produit.prixUnitaire),
                            style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: AppColors.vertFonce,
                            ),
                          ),
                          Text(
                            '/ ${produit.uniteVenteLabel}',
                            style: const TextStyle(
                              fontSize: 10, color: AppColors.grisTexte,
                            ),
                          ),
                        ],
                      ),
                      if (onAjouter != null)
                        GestureDetector(
                          onTap: onAjouter,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:        AppColors.vertVif,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### `lib/features/acheteur/widgets/commande_statut_badge.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CommandeStatutBadge extends StatelessWidget {
  final String statut;
  const CommandeStatutBadge(this.statut, {super.key});

  static const _config = {
    'en_attente':     ('En attente',      AppColors.statutAttente),
    'confirmee':      ('Confirmée',       AppColors.statutConfirmee),
    'en_preparation': ('En préparation',  AppColors.statutConfirmee),
    'prete':          ('Prête',           AppColors.vertVif),
    'en_collecte':    ('En collecte',     AppColors.orange),
    'livree':         ('Livrée',          AppColors.statutLivree),
    'annulee':        ('Annulée',         AppColors.statutAnnulee),
    'litige':         ('En litige',       AppColors.rouge),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _config[statut] ??
        ('Inconnu', AppColors.grisTexte);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   12,
          fontWeight: FontWeight.w600,
          color:      color,
        ),
      ),
    );
  }
}
```

---

## ÉTAPE 7 — Écran Accueil Acheteur

### `lib/features/acheteur/screens/accueil_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../providers/catalogue_provider.dart';
import '../providers/panier_provider.dart';
import '../widgets/produit_card.dart';
import '../../../core/offline/offline_banner.dart';
import '../../../shared/widgets/loading_widget.dart';

class AccueilScreen extends ConsumerWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user       = ref.watch(authProvider).user;
    final catState   = ref.watch(catalogueProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ── Header ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.vertFonce, Color(0xFF1E8449)],
                          begin:  Alignment.topLeft,
                          end:    Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bonjou ${user?.firstName ?? ''} 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'PlayfairDisplay',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Text(
                                    'Kisa ou bezwen jodi a ?',
                                    style: TextStyle(
                                      color: Color(0xBBFFFFFF),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              // Badge panier
                              GestureDetector(
                                onTap: () => context.go('/acheteur/panier'),
                                child: Stack(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Color(0x33FFFFFF),
                                      child: Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0, right: 0,
                                      child: Consumer(
                                        builder: (_, ref, __) {
                                          final nb = ref
                                              .watch(panierProvider.notifier)
                                              .nbArticles;
                                          if (nb == 0) return const SizedBox.shrink();
                                          return Container(
                                            width:  18, height: 18,
                                            decoration: const BoxDecoration(
                                              color:  AppColors.jaune,
                                              shape:  BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '$nb',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.noir,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Barre de recherche
                          GestureDetector(
                            onTap: () => context.go('/acheteur/catalogue'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:        Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.search,
                                    color: AppColors.grisTexte),
                                  SizedBox(width: 10),
                                  Text(
                                    'Chercher haricot, maïs, légumes...',
                                    style: TextStyle(
                                      color:   AppColors.grisTexte,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Catégories ───────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: const Text(
                        'Catégories',
                        style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800,
                          color: AppColors.vertFonce,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44,
                      child: categories.when(
                        data: (cats) => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: cats.length + 1,
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              return _CategorieChip(
                                label:    '🛒 Tout',
                                selected: catState.filtre.categorieSlug.isEmpty,
                                onTap: () => ref
                                    .read(catalogueProvider.notifier)
                                    .appliquerFiltre(
                                      catState.filtre.copyWith(categorieSlug: ''),
                                    ),
                              );
                            }
                            final cat = cats[i - 1];
                            final slug = cat['slug'] as String;
                            return _CategorieChip(
                              label:    '${cat['icone'] ?? '🌿'} ${cat['nom']}',
                              selected: catState.filtre.categorieSlug == slug,
                              onTap: () => ref
                                  .read(catalogueProvider.notifier)
                                  .appliquerFiltre(
                                    catState.filtre.copyWith(categorieSlug: slug),
                                  ),
                            );
                          },
                        ),
                        loading: () => const SizedBox.shrink(),
                        error:   (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ),

                  // ── Produits en vedette ───────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '⭐ En vedette',
                            style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800,
                              color: AppColors.vertFonce,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/acheteur/catalogue'),
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Grille produits ───────────────────────────
                  if (catState.isLoading)
                    const SliverFillRemaining(child: LoadingWidget())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            if (i == catState.produits.length) {
                              // Bouton charger plus
                              if (!catState.hasMore) return null;
                              return Center(
                                child: catState.isLoadingMore
                                    ? const CircularProgressIndicator(
                                        color: AppColors.vertVif)
                                    : ElevatedButton(
                                        onPressed: () => ref
                                            .read(catalogueProvider.notifier)
                                            .chargerPlus(),
                                        child: const Text('Voir plus'),
                                      ),
                              );
                            }
                            final p = catState.produits[i];
                            return ProduitCard(
                              produit: p,
                              onTap:   () => context.go(
                                '/acheteur/produit/${p.slug}',
                              ),
                              onAjouter: () async {
                                final err = await ref
                                    .read(panierProvider.notifier)
                                    .ajouter(p.slug, 1);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        err == null
                                            ? '✅ ${p.nom} ajouté au panier'
                                            : '❌ $err',
                                      ),
                                      backgroundColor: err == null
                                          ? AppColors.vertVif
                                          : AppColors.rouge,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                          childCount: catState.produits.length +
                              (catState.hasMore ? 1 : 0),
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:   2,
                          childAspectRatio: 0.72,
                          mainAxisSpacing:  12,
                          crossAxisSpacing: 10,
                        ),
                      ),
                    ),

                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 80),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorieChip extends StatelessWidget {
  final String label;
  final bool   selected;
  final VoidCallback onTap;
  const _CategorieChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.vertFonce : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.vertFonce : const Color(0xFFDDDDDD),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   13,
          fontWeight: FontWeight.w600,
          color:      selected ? Colors.white : AppColors.noir,
        ),
      ),
    ),
  );
}
```

---

## ÉTAPE 8 — Écran Panier

### `lib/features/acheteur/screens/panier_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../providers/panier_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/htg_text.dart';

class PanierScreen extends ConsumerWidget {
  const PanierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panierState = ref.watch(panierProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          panierState.whenOrNull(
            data: (p) => p.items.isNotEmpty
                ? TextButton(
                    onPressed: () => _confirmerVider(context, ref),
                    child: const Text(
                      'Vider',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : null,
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: panierState.when(
        loading: () => const LoadingWidget(message: 'Chargement du panier...'),
        error:   (e, _) => Center(child: Text('Erreur : $e')),
        data:    (panier) {
          if (panier.items.isEmpty) {
            return EmptyState(
              emoji:       '🛒',
              titre:       'Votre panier est vide',
              description: 'Ajoutez des produits depuis le catalogue.',
              boutonLabel: 'Voir le catalogue',
              onBouton:    () => context.go('/acheteur/catalogue'),
            );
          }

          return Column(
            children: [
              // Liste des articles
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: panier.items.length,
                  itemBuilder: (_, i) {
                    final item = panier.items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:        Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:     Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.image != null
                                ? CachedNetworkImage(
                                    imageUrl: ImageUtils.imageUrl(item.image),
                                    width: 64, height: 64,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 64, height: 64,
                                    color: AppColors.vertMenthe,
                                    child: const Center(
                                      child: Text('🌿',
                                        style: TextStyle(fontSize: 28)),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),

                          // Infos
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.vertFonce,
                                  ),
                                ),
                                Text(
                                  item.producteurNom,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grisTexte,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                HtgText(item.prixUnitaire,
                                  fontSize: 13,
                                  suffix:   ' / ${item.uniteVente}',
                                ),
                              ],
                            ),
                          ),

                          // Quantité
                          Column(
                            children: [
                              _QuantiteControl(
                                quantite:    item.quantite,
                                stockMax:    item.stockReel,
                                onIncrement: () => ref
                                    .read(panierProvider.notifier)
                                    .modifier(item.slug, item.quantite + 1),
                                onDecrement: () {
                                  if (item.quantite <= 1) {
                                    ref.read(panierProvider.notifier)
                                        .retirer(item.slug);
                                  } else {
                                    ref.read(panierProvider.notifier)
                                        .modifier(item.slug, item.quantite - 1);
                                  }
                                },
                              ),
                              const SizedBox(height: 4),
                              HtgText(item.sousTotal, fontSize: 13),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Récapitulatif + Bouton commander
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color:     Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset:    const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Producteurs
                    if (panier.producteurs.length > 1)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:        AppColors.jauneClair,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.jaune),
                        ),
                        child: Text(
                          'ℹ️ ${panier.producteurs.length} producteurs — '
                          '${panier.producteurs.length} commandes seront créées.',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${panier.nbArticles} article${panier.nbArticles > 1 ? 's' : ''}',
                          style: const TextStyle(color: AppColors.grisTexte),
                        ),
                        HtgText(panier.total, fontSize: 20),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      icon:      const Icon(Icons.shopping_bag_outlined),
                      label:     const Text('Passer la commande'),
                      onPressed: () => context.go('/acheteur/checkout'),
                      style:     ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vertFonce,
                        minimumSize:     const Size(double.infinity, 52),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmerVider(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vider le panier ?'),
        content: const Text('Tous les articles seront supprimés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(panierProvider.notifier).vider();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rouge,
            ),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }
}

class _QuantiteControl extends StatelessWidget {
  final int quantite;
  final int stockMax;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantiteControl({
    required this.quantite,
    required this.stockMax,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _Btn(
        icon:      Icons.remove,
        onTap:     onDecrement,
        color:     quantite <= 1 ? AppColors.rouge : AppColors.vertVif,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          '$quantite',
          style: const TextStyle(
            fontWeight: FontWeight.w800, fontSize: 16,
          ),
        ),
      ),
      _Btn(
        icon:      Icons.add,
        onTap:     quantite < stockMax ? onIncrement : null,
        color:     AppColors.vertVif,
      ),
    ],
  );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  const _Btn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color:        onTap != null ? color.withOpacity(.15) : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon,
        size:  16,
        color: onTap != null ? color : Colors.grey,
      ),
    ),
  );
}
```

---

## ÉTAPE 9 — Écran Checkout

### `lib/features/acheteur/screens/checkout_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/commande_provider.dart';
import '../providers/adresse_provider.dart';
import '../providers/panier_provider.dart';
import '../../../shared/widgets/htg_text.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _methodePaiement  = 'cash';
  String _modeLivraison    = 'domicile';
  int?   _adresseId;
  String _notes            = '';
  bool   _isLoading        = false;

  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _commander() async {
    setState(() => _isLoading = true);

    final result = await ref.read(commandesProvider.notifier).passer(
      methodePaiement: _methodePaiement,
      modeLivraison:   _modeLivraison,
      adresseId:       _adresseId,
      notes:           _notes,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result?['success'] == true) {
      final data = result!['data'] as Map<String, dynamic>;

      // MonCash → ouvrir WebView
      if (_methodePaiement == 'moncash' &&
          data['redirect_url'] != null) {
        context.push(
          '/acheteur/paiement/moncash',
          extra: data['redirect_url'] as String,
        );
        return;
      }

      // Succès → aller aux commandes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']?.toString() ??
              'Commande passée avec succès !'),
          backgroundColor: AppColors.vertVif,
        ),
      );
      context.go('/acheteur/commandes');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['error']?.toString() ?? 'Erreur'),
          backgroundColor: AppColors.rouge,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adressesState = ref.watch(adressesProvider);
    final panierState   = ref.watch(panierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmer la commande')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Méthode de paiement ──────────────────────────
            _Section(
              titre: '💳 Méthode de paiement',
              child: Column(
                children: [
                  for (final m in [
                    ('cash',      '💵 Espèces'),
                    ('moncash',   '📱 MonCash'),
                    ('hors_ligne','🏦 Virement / Dépôt'),
                  ])
                    RadioListTile<String>(
                      value:      m.$1,
                      groupValue: _methodePaiement,
                      title:      Text(m.$2),
                      activeColor: AppColors.vertVif,
                      onChanged: (v) =>
                          setState(() => _methodePaiement = v!),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Mode de livraison ────────────────────────────
            _Section(
              titre: '🚚 Mode de livraison',
              child: Column(
                children: [
                  for (final m in [
                    ('domicile', '🏠 Livraison à domicile'),
                    ('retrait',  '🌾 Retrait chez le producteur'),
                    ('collecte', '📦 Point de collecte'),
                  ])
                    RadioListTile<String>(
                      value:      m.$1,
                      groupValue: _modeLivraison,
                      title:      Text(m.$2),
                      activeColor: AppColors.vertVif,
                      onChanged: (v) =>
                          setState(() => _modeLivraison = v!),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Adresse de livraison ─────────────────────────
            if (_modeLivraison == 'domicile')
              _Section(
                titre: '📍 Adresse de livraison',
                child: adressesState.when(
                  loading: () => const CircularProgressIndicator(),
                  error:   (_, __) => const Text('Erreur chargement'),
                  data: (adresses) {
                    if (adresses.isEmpty) {
                      return Column(
                        children: [
                          const Text('Aucune adresse enregistrée.'),
                          TextButton(
                            onPressed: () =>
                                context.push('/acheteur/adresses'),
                            child: const Text('Ajouter une adresse'),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: adresses.map((a) => RadioListTile<int>(
                        value:      a.id,
                        groupValue: _adresseId ?? adresses.first.id,
                        title:      Text('${a.rue}, ${a.commune}'),
                        subtitle:   Text(a.departement),
                        activeColor: AppColors.vertVif,
                        onChanged: (v) =>
                            setState(() => _adresseId = v),
                        contentPadding: EdgeInsets.zero,
                      )).toList(),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // ── Notes ────────────────────────────────────────
            _Section(
              titre: '📝 Notes (optionnel)',
              child: TextField(
                controller: _notesCtrl,
                maxLines:   3,
                decoration: const InputDecoration(
                  hintText: 'Ex: Livrer avant midi, appeler avant...',
                ),
                onChanged: (v) => _notes = v,
              ),
            ),
            const SizedBox(height: 16),

            // ── Récapitulatif ─────────────────────────────────
            _Section(
              titre: '🧾 Récapitulatif',
              child: panierState.whenOrNull(
                data: (p) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${p.nbArticles} article(s)'),
                        HtgText(p.total),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                        HtgText(p.total, fontSize: 20),
                      ],
                    ),
                  ],
                ),
              ) ?? const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // ── Bouton commander ──────────────────────────────
            ElevatedButton(
              onPressed: _isLoading ? null : _commander,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertFonce,
                minimumSize:     const Size(double.infinity, 54),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _methodePaiement == 'moncash'
                          ? '📱 Payer avec MonCash'
                          : '✅ Confirmer la commande',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String titre;
  final Widget child;
  const _Section({required this.titre, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: AppColors.vertFonce,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
```

---

## ÉTAPE 10 — Écran Paiement MonCash (WebView)

### `lib/features/acheteur/screens/paiement_moncash_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';

class PaiementMoncashScreen extends StatefulWidget {
  final String redirectUrl;
  const PaiementMoncashScreen({required this.redirectUrl, super.key});

  @override
  State<PaiementMoncashScreen> createState() =>
      _PaiementMoncashScreenState();
}

class _PaiementMoncashScreenState
    extends State<PaiementMoncashScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted:  (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) {
            // Détecter le retour MonCash
            if (req.url.contains('/commander/moncash/retour/') ||
                req.url.contains('success') ||
                req.url.contains('cancel')) {
              _onPaiementTermine(req.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  void _onPaiementTermine(String url) {
    final success = url.contains('success');
    context.go('/acheteur/commandes');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ Paiement MonCash effectué !'
              : '❌ Paiement annulé ou échoué.',
        ),
        backgroundColor:
            success ? AppColors.vertVif : AppColors.rouge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Paiement MonCash'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Annuler le paiement ?'),
            content: const Text(
              'Votre commande a été créée. Vous pouvez la payer plus tard.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuer le paiement'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/acheteur/commandes');
                },
                child: const Text('Quitter',
                  style: TextStyle(color: AppColors.rouge)),
              ),
            ],
          ),
        ),
      ),
    ),
    body: Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.vertVif),
          ),
      ],
    ),
  );
}
```

---

## ÉTAPE 11 — Écran Mes Commandes

### `lib/features/acheteur/screens/commandes_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/commande_provider.dart';
import '../widgets/commande_statut_badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_widget.dart';

class CommandesScreen extends ConsumerWidget {
  const CommandesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commandesProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(commandesProvider.notifier).charger(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const LoadingWidget(message: 'Chargement...'),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (commandes) {
          if (commandes.isEmpty) {
            return EmptyState(
              emoji:       '📦',
              titre:       'Aucune commande',
              description: 'Vos commandes apparaîtront ici.',
              boutonLabel: 'Voir le catalogue',
              onBouton:    () => context.go('/acheteur/catalogue'),
            );
          }

          return RefreshIndicator(
            color:     AppColors.vertVif,
            onRefresh: () =>
                ref.read(commandesProvider.notifier).charger(),
            child: ListView.builder(
              padding:   const EdgeInsets.all(12),
              itemCount: commandes.length,
              itemBuilder: (_, i) {
                final c = commandes[i];
                return GestureDetector(
                  onTap: () => context.go(
                    '/acheteur/commande/${c.numeroCommande}',
                  ),
                  child: Container(
                    margin:  const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:     Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.numeroCommande,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize:   15,
                                color:      AppColors.vertFonce,
                              ),
                            ),
                            CommandeStatutBadge(c.statut),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '🌾 ${c.producteur}',
                          style: const TextStyle(
                            fontSize: 13,
                            color:    AppColors.grisTexte,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              FormatUtils.date(c.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color:    AppColors.grisTexte,
                              ),
                            ),
                            Text(
                              FormatUtils.htg(c.total),
                              style: const TextStyle(
                                fontSize:   16,
                                fontWeight: FontWeight.w800,
                                color:      AppColors.vertFonce,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

---

## ÉTAPE 12 — Mettre à jour le router avec les nouvelles routes

Dans `lib/router/app_router.dart`, remplacer les `Placeholder()`
du shell Acheteur par les vrais écrans :

```dart
import '../features/acheteur/screens/accueil_screen.dart';
import '../features/acheteur/screens/catalogue_screen.dart';
import '../features/acheteur/screens/panier_screen.dart';
import '../features/acheteur/screens/commandes_screen.dart';
import '../features/acheteur/screens/commande_detail_screen.dart';
import '../features/acheteur/screens/checkout_screen.dart';
import '../features/acheteur/screens/profil_screen.dart';
import '../features/acheteur/screens/paiement_moncash_screen.dart';

// Dans les routes du shell Acheteur :
GoRoute(path: '/acheteur/accueil',   builder: (_, __) => const AccueilScreen()),
GoRoute(path: '/acheteur/catalogue', builder: (_, __) => const CatalogueScreen()),
GoRoute(path: '/acheteur/panier',    builder: (_, __) => const PanierScreen()),
GoRoute(path: '/acheteur/commandes', builder: (_, __) => const CommandesScreen()),
GoRoute(path: '/acheteur/profil',    builder: (_, __) => const ProfilScreen()),

// Routes hors shell (plein écran)
GoRoute(
  path:    '/acheteur/produit/:slug',
  builder: (_, state) => ProduitDetailScreen(
    slug: state.pathParameters['slug']!,
  ),
),
GoRoute(
  path:    '/acheteur/commande/:numero',
  builder: (_, state) => CommandeDetailScreen(
    numero: state.pathParameters['numero']!,
  ),
),
GoRoute(
  path:    '/acheteur/checkout',
  builder: (_, __) => const CheckoutScreen(),
),
GoRoute(
  path:    '/acheteur/paiement/moncash',
  builder: (_, state) => PaiementMoncashScreen(
    redirectUrl: state.extra as String,
  ),
),
GoRoute(
  path:    '/acheteur/adresses',
  builder: (_, __) => const AdressesScreen(),
),
```

---

## ÉTAPE 13 — Écrans restants à créer (stubs fonctionnels)

Crée ces fichiers avec un écran basique que tu completeras :

### `lib/features/acheteur/screens/catalogue_screen.dart`
Catalogue avec barre de recherche, filtres, infinite scroll.
Utilise `catalogueProvider`, `categoriesProvider`, `ProduitCard`.
Affiche la `OfflineBanner` en haut.

### `lib/features/acheteur/screens/produit_detail_screen.dart`
Utilise `produitDetailProvider(slug)`.
Affiche : galerie images, prix, stock, producteur, bouton "Ajouter au panier".
Section "Produits similaires".

### `lib/features/acheteur/screens/commande_detail_screen.dart`
Utilise `commandeDetailProvider(numero)`.
Affiche : articles, statut, paiement, adresse, timeline historique.

### `lib/features/acheteur/screens/profil_screen.dart`
PATCH `/api/auth/me/` avec upload photo (image_picker + Dio multipart).
Affiche : photo, nom, email, téléphone, bouton changer mot de passe.
Lien vers adresses et déconnexion.

### `lib/features/acheteur/screens/adresses_screen.dart`
Liste des adresses avec `adressesProvider`.
Bouton créer → modal avec `GeoSelector`.
Swipe pour supprimer, tap pour définir par défaut.

---

## ÉTAPE 14 — Générer les fichiers Freezed

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

---

## RÉSUMÉ — Ce que ce prompt crée

| Composant | Description |
|---|---|
| **4 providers** | Catalogue (filtres + offline + infinite scroll), Panier, Commandes, Adresses |
| **Widgets partagés** | LoadingWidget, EmptyState, HtgText, GeoSelector cascade |
| **ProduitCard** | Image cached, badges, prix HTG, bouton ajouter |
| **CommandeStatutBadge** | 8 statuts colorés |
| **AccueilScreen** | Header vert, recherche, catégories, grille produits |
| **PanierScreen** | Articles, contrôle quantité, récap, bouton commander |
| **CheckoutScreen** | Méthode paiement, mode livraison, adresse, notes, total |
| **PaiementMoncashScreen** | WebView MonCash avec détection retour |
| **CommandesScreen** | Liste avec pull-to-refresh |
| **Router mis à jour** | Toutes les routes acheteur |

**Prochaine étape → Prompt 3 : App Producteur**
(Dashboard stats, commandes reçues, gestion produits, collectes)
