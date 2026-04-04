# PROMPT CLAUDE CODE — Makèt Peyizan Mobile
# Flutter — Partie 3 : App Producteur & Collecteur

---

## CONTEXTE

Les Parties 1 et 2 (Fondations + App Acheteur) sont déjà implémentées.
Tu vas maintenant créer tous les écrans du **Producteur** et du **Collecteur**.

**Rappel palette :**
- Vert foncé  : `#1A6B2F`  — AppColors.vertFonce
- Vert vif    : `#27AE60`  — AppColors.vertVif
- Jaune       : `#E8D800`  — AppColors.jaune

---

## FICHIERS À CRÉER

```
lib/features/producteur/
├── screens/
│   ├── dashboard_screen.dart
│   ├── commandes_recues_screen.dart
│   ├── commande_detail_screen.dart
│   ├── mes_produits_screen.dart
│   ├── produit_form_screen.dart
│   ├── collectes_screen.dart
│   └── profil_producteur_screen.dart
├── providers/
│   ├── dashboard_provider.dart
│   ├── commandes_producteur_provider.dart
│   ├── mes_produits_provider.dart
│   └── collectes_producteur_provider.dart
└── widgets/
    ├── stat_card.dart
    ├── commande_action_sheet.dart
    └── produit_form_fields.dart

lib/features/collecteur/
├── screens/
│   ├── collectes_terrain_screen.dart
│   └── collecte_detail_screen.dart
├── providers/
│   └── collecteur_provider.dart
└── widgets/
    └── collecte_card.dart
```

---

## ÉTAPE 1 — Provider Dashboard Producteur

### `lib/features/producteur/providers/dashboard_provider.dart`

```dart
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
```

---

## ÉTAPE 2 — Provider Commandes Producteur

### `lib/features/producteur/providers/commandes_producteur_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/commande.dart';

// Liste des commandes reçues
final commandesProducteurProvider = StateNotifierProvider
    .family<CommandesProducteurNotifier, AsyncValue<List<Commande>>, String>(
  (ref, statut) => CommandesProducteurNotifier(
    ref.read(apiClientProvider), statut,
  ),
);

class CommandesProducteurNotifier
    extends StateNotifier<AsyncValue<List<Commande>>> {
  final ApiClient _api;
  final String    _statut;

  CommandesProducteurNotifier(this._api, this._statut)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res = await _api.get(
        AppEndpoints.producteurCommandes,
        queryParameters: _statut.isNotEmpty
            ? {'statut': _statut} : null,
      );
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

  Future<Map<String, dynamic>?> changerStatut(
    String numero,
    String action, {
    String motif = '',
  }) async {
    try {
      final res = await _api.patch(
        AppEndpoints.producteurCommandeStatut(numero),
        data: {'action': action, if (motif.isNotEmpty) 'motif': motif},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) await charger();
      return data;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

// Détail d'une commande
final commandeProducteurDetailProvider =
    FutureProvider.family<Commande?, String>((ref, numero) async {
  final api = ref.read(apiClientProvider);
  try {
    final res  = await api.get(AppEndpoints.producteurCommande(numero));
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return Commande.fromJson(data['data'] as Map<String, dynamic>);
    }
  } catch (_) {}
  return null;
});
```

---

## ÉTAPE 3 — Provider Mes Produits

### `lib/features/producteur/providers/mes_produits_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/produit.dart';

final mesProduitsProvider =
    StateNotifierProvider<MesProduitsNotifier, AsyncValue<List<Produit>>>((ref) {
  return MesProduitsNotifier(ref.read(apiClientProvider));
});

class MesProduitsNotifier
    extends StateNotifier<AsyncValue<List<Produit>>> {
  final ApiClient _api;

  MesProduitsNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.mesProduits);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => Produit.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> creer(Map<String, dynamic> body, {String? imagePath}) async {
    try {
      dynamic payload = body;
      if (imagePath != null) {
        final formData = await _buildFormData(body, imagePath);
        final res  = await _api.postMultipart(AppEndpoints.mesProduits, formData);
        final data = res.data as Map<String, dynamic>;
        if (data['success'] == true) { await charger(); return true; }
        return false;
      }
      final res  = await _api.post(AppEndpoints.mesProduits, data: payload);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }

  Future<bool> modifier(
    String slug,
    Map<String, dynamic> body, {
    String? imagePath,
  }) async {
    try {
      if (imagePath != null) {
        final formData = await _buildFormData(body, imagePath);
        final res  = await _api.postMultipart(AppEndpoints.monProduit(slug), formData);
        final data = res.data as Map<String, dynamic>;
        if (data['success'] == true) { await charger(); return true; }
        return false;
      }
      final res  = await _api.patch(AppEndpoints.monProduit(slug), data: body);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }

  Future<bool> supprimer(String slug) async {
    try {
      await _api.delete(AppEndpoints.monProduit(slug));
      await charger();
      return true;
    } catch (_) { return false; }
  }

  Future<dynamic> _buildFormData(
    Map<String, dynamic> body,
    String imagePath,
  ) async {
    import 'package:dio/dio.dart';
    final map = Map<String, dynamic>.from(body);
    map['image_principale'] = await MultipartFile.fromFile(
      imagePath, filename: 'image.jpg',
    );
    return FormData.fromMap(map);
  }
}
```

---

## ÉTAPE 4 — Provider Collectes Producteur

### `lib/features/producteur/providers/collectes_producteur_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class ParticipationCollecte {
  final int    id;
  final String statut;
  final String statutLabel;
  final Map<String, dynamic> collecte;
  final double? quantitePrevue;
  final double? quantiteRecue;
  final double? montantPaye;
  final bool    paiementEffectue;

  const ParticipationCollecte({
    required this.id,
    required this.statut,
    required this.statutLabel,
    required this.collecte,
    this.quantitePrevue,
    this.quantiteRecue,
    this.montantPaye,
    this.paiementEffectue = false,
  });

  factory ParticipationCollecte.fromJson(Map<String, dynamic> json) =>
      ParticipationCollecte(
        id:               json['id'] as int,
        statut:           json['statut'] as String? ?? '',
        statutLabel:      json['statut_label'] as String? ?? '',
        collecte:         Map<String, dynamic>.from(
                            json['collecte'] as Map? ?? {}),
        quantitePrevue:   double.tryParse(
                            json['quantite_prevue']?.toString() ?? ''),
        quantiteRecue:    double.tryParse(
                            json['quantite_recue']?.toString() ?? ''),
        montantPaye:      double.tryParse(
                            json['montant_paye']?.toString() ?? ''),
        paiementEffectue: json['paiement_effectue'] as bool? ?? false,
      );
}

final collectesProducteurProvider = StateNotifierProvider<
    CollectesProducteurNotifier,
    AsyncValue<List<ParticipationCollecte>>>((ref) {
  return CollectesProducteurNotifier(ref.read(apiClientProvider));
});

class CollectesProducteurNotifier
    extends StateNotifier<AsyncValue<List<ParticipationCollecte>>> {
  final ApiClient _api;

  CollectesProducteurNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.mesParticipations);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => ParticipationCollecte.fromJson(
                  e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> confirmer(
    int id, {
    double? quantitePrevue,
    String  notes = '',
  }) async {
    try {
      final body = <String, dynamic>{'notes': notes};
      if (quantitePrevue != null) {
        body['quantite_prevue'] = quantitePrevue;
      }
      final res  = await _api.patch(
        AppEndpoints.confirmerParticipation(id), data: body,
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
```

---

## ÉTAPE 5 — Widget StatCard

### `lib/features/producteur/widgets/stat_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final String   emoji;
  final String   label;
  final String   valeur;
  final Color    couleur;
  final String?  sousTitre;
  final VoidCallback? onTap;

  const StatCard({
    required this.emoji,
    required this.label,
    required this.valeur,
    this.couleur   = AppColors.vertVif,
    this.sousTitre,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: couleur, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color:     Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset:    const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            valeur,
            style: TextStyle(
              fontSize:   26,
              fontWeight: FontWeight.w900,
              color:      couleur,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12, color: AppColors.grisTexte,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (sousTitre != null)
            Text(
              sousTitre!,
              style: const TextStyle(
                fontSize: 11, color: AppColors.grisTexte,
              ),
            ),
        ],
      ),
    ),
  );
}
```

---

## ÉTAPE 6 — Dashboard Producteur

### `lib/features/producteur/screens/dashboard_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/offline/offline_banner.dart';

class DashboardProducteurScreen extends ConsumerWidget {
  const DashboardProducteurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user    = ref.watch(authProvider).user;
    final dashState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                color:     AppColors.vertVif,
                onRefresh: () =>
                    ref.read(dashboardProvider.notifier).charger(),
                child: CustomScrollView(
                  slivers: [

                    // ── Header ────────────────────────────────
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.vertFonce,
                              Color(0xFF1E8449),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(
                          20, 16, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjou ${user?.firstName ?? ''} 🌾',
                                      style: const TextStyle(
                                        color:      Colors.white,
                                        fontSize:   20,
                                        fontFamily: 'PlayfairDisplay',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Text(
                                      'Tableau de bord producteur',
                                      style: TextStyle(
                                        color:   Color(0xBBFFFFFF),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.15),
                                  child: Text(
                                    (user?.firstName ?? '?')[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color:      Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize:   18,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Revenus du mois
                            dashState.whenOrNull(
                              data: (stats) => Container(
                                margin:  const EdgeInsets.only(top: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:        Colors.white
                                      .withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Revenus ce mois',
                                          style: TextStyle(
                                            color:   Color(0xBBFFFFFF),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          FormatUtils.htg(
                                              stats.revenusMois),
                                          style: const TextStyle(
                                            color:      AppColors.jaune,
                                            fontSize:   24,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'PlayfairDisplay',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Total',
                                          style: TextStyle(
                                            color:   Color(0xBBFFFFFF),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          FormatUtils.htg(
                                              stats.revenusTotal),
                                          style: const TextStyle(
                                            color:      Colors.white,
                                            fontSize:   16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ) ?? const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),

                    // ── Stats Commandes ───────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: const Text(
                          '🧾 Commandes',
                          style: TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.w800,
                            color:      AppColors.vertFonce,
                          ),
                        ),
                      ),
                    ),

                    dashState.when(
                      loading: () => const SliverToBoxAdapter(
                        child: LoadingWidget(),
                      ),
                      error: (e, _) => SliverToBoxAdapter(
                        child: Center(child: Text('Erreur : $e')),
                      ),
                      data: (stats) => SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        sliver: SliverGrid(
                          delegate: SliverChildListDelegate([
                            StatCard(
                              emoji:   '⏳',
                              label:   'En attente',
                              valeur:  '${stats.commandesEnAttente}',
                              couleur: AppColors.statutAttente,
                              onTap: () => context.go(
                                '/producteur/commandes?statut=en_attente',
                              ),
                            ),
                            StatCard(
                              emoji:   '✅',
                              label:   'Confirmées',
                              valeur:  '${stats.commandesConfirmees}',
                              couleur: AppColors.statutConfirmee,
                              onTap: () => context.go(
                                '/producteur/commandes?statut=confirmee',
                              ),
                            ),
                            StatCard(
                              emoji:   '📦',
                              label:   'Livrées',
                              valeur:  '${stats.commandesLivrees}',
                              couleur: AppColors.statutLivree,
                            ),
                            StatCard(
                              emoji:   '📊',
                              label:   'Total',
                              valeur:  '${stats.commandesTotal}',
                              couleur: AppColors.vertFonce,
                            ),
                          ]),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:   2,
                            childAspectRatio: 1.3,
                            mainAxisSpacing:  10,
                            crossAxisSpacing: 10,
                          ),
                        ),
                      ),
                    ),

                    // ── Stats Produits & Stock ─────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: const Text(
                          '🥬 Produits & Stock',
                          style: TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.w800,
                            color:      AppColors.vertFonce,
                          ),
                        ),
                      ),
                    ),

                    dashState.whenOrNull(
                      data: (stats) => SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        sliver: SliverGrid(
                          delegate: SliverChildListDelegate([
                            StatCard(
                              emoji:   '🌿',
                              label:   'Produits actifs',
                              valeur:  '${stats.nbProduitsActifs}',
                              couleur: AppColors.vertVif,
                              onTap: () =>
                                  context.go('/producteur/catalogue'),
                            ),
                            StatCard(
                              emoji:   '🔴',
                              label:   'Épuisés',
                              valeur:  '${stats.nbProduitsEpuises}',
                              couleur: AppColors.rouge,
                            ),
                            StatCard(
                              emoji:   '⚠️',
                              label:   'Alertes stock',
                              valeur:  '${stats.alertesStock}',
                              couleur: AppColors.orange,
                            ),
                            StatCard(
                              emoji:   '🚛',
                              label:   'Collectes à venir',
                              valeur:  '${stats.collectesAVenir}',
                              couleur: AppColors.bleu,
                              onTap: () =>
                                  context.go('/producteur/collectes'),
                            ),
                          ]),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:   2,
                            childAspectRatio: 1.3,
                            mainAxisSpacing:  10,
                            crossAxisSpacing: 10,
                          ),
                        ),
                      ),
                    ) ?? const SliverToBoxAdapter(child: SizedBox.shrink()),

                    // ── Actions rapides ────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚡ Actions rapides',
                              style: TextStyle(
                                fontSize:   16,
                                fontWeight: FontWeight.w800,
                                color:      AppColors.vertFonce,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                child: _ActionBtn(
                                  emoji: '➕',
                                  label: 'Nouveau produit',
                                  onTap: () => context.go(
                                    '/producteur/produit/nouveau',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ActionBtn(
                                  emoji: '📋',
                                  label: 'Commandes reçues',
                                  onTap: () => context.go(
                                    '/producteur/commandes',
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),

                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 80),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String       emoji;
  final String       label;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color:        AppColors.vertMenthe,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.vertVif.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(label,
            style: const TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w700,
              color:      AppColors.vertFonce,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
```

---

## ÉTAPE 7 — Commandes Reçues (Producteur)

### `lib/features/producteur/screens/commandes_recues_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/commandes_producteur_provider.dart';
import '../../acheteur/widgets/commande_statut_badge.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class CommandesRecuesScreen extends ConsumerStatefulWidget {
  final String? statutInitial;
  const CommandesRecuesScreen({this.statutInitial, super.key});

  @override
  ConsumerState<CommandesRecuesScreen> createState() =>
      _CommandesRecuesScreenState();
}

class _CommandesRecuesScreenState
    extends ConsumerState<CommandesRecuesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _filtres = [
    ('',             'Toutes'),
    ('en_attente',   '⏳ Attente'),
    ('confirmee',    '✅ Confirmées'),
    ('en_preparation','🔄 Préparation'),
    ('livree',       '📦 Livrées'),
    ('annulee',      '❌ Annulées'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filtres.length, vsync: this);
    if (widget.statutInitial != null) {
      final idx = _filtres.indexWhere(
        (f) => f.$1 == widget.statutInitial,
      );
      if (idx >= 0) _tabs.index = idx;
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Commandes reçues'),
        bottom: TabBar(
          controller:      _tabs,
          isScrollable:    true,
          labelColor:      AppColors.jaune,
          unselectedLabelColor: Colors.white70,
          indicatorColor:  AppColors.jaune,
          tabs: _filtres.map((f) => Tab(text: f.$2)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: _filtres.map((f) => _CommandesList(
          statut: f.$1,
        )).toList(),
      ),
    );
  }
}

class _CommandesList extends ConsumerWidget {
  final String statut;
  const _CommandesList({required this.statut});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commandesProducteurProvider(statut));

    return state.when(
      loading: () => const LoadingWidget(),
      error:   (e, _) => Center(child: Text('Erreur : $e')),
      data:    (commandes) {
        if (commandes.isEmpty) {
          return const EmptyState(
            emoji:       '📭',
            titre:       'Aucune commande',
            description: 'Aucune commande dans cette catégorie.',
          );
        }

        return RefreshIndicator(
          color:     AppColors.vertVif,
          onRefresh: () =>
              ref.read(commandesProducteurProvider(statut).notifier)
                  .charger(),
          child: ListView.builder(
            padding:   const EdgeInsets.all(12),
            itemCount: commandes.length,
            itemBuilder: (_, i) {
              final c = commandes[i];
              return GestureDetector(
                onTap: () => context.go(
                  '/producteur/commande/${c.numeroCommande}',
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
                      // Acheteur (stocké dans producteur field
                      // pour compatibilité modèle)
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
                      // Boutons action rapide si en_attente
                      if (c.statut == 'en_attente') ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _annuler(context, ref, c.numeroCommande),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.rouge,
                                side: const BorderSide(
                                    color: AppColors.rouge),
                              ),
                              child: const Text('Refuser'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _confirmer(context, ref, c.numeroCommande),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.vertVif,
                              ),
                              child: const Text('Confirmer'),
                            ),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmer(
    BuildContext ctx, WidgetRef ref, String numero,
  ) async {
    final result = await ref
        .read(commandesProducteurProvider('').notifier)
        .changerStatut(numero, 'confirmer');
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(result?['success'] == true
            ? '✅ Commande confirmée !'
            : result?['error']?.toString() ?? 'Erreur'),
        backgroundColor: result?['success'] == true
            ? AppColors.vertVif : AppColors.rouge,
      ));
    }
  }

  Future<void> _annuler(
    BuildContext ctx, WidgetRef ref, String numero,
  ) async {
    final motifCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Refuser la commande ?'),
        content: TextField(
          controller: motifCtrl,
          decoration: const InputDecoration(
            labelText: 'Motif (requis)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rouge),
            child: const Text('Confirmer le refus'),
          ),
        ],
      ),
    );

    if (confirm == true && motifCtrl.text.isNotEmpty) {
      final result = await ref
          .read(commandesProducteurProvider('').notifier)
          .changerStatut(numero, 'annuler',
              motif: motifCtrl.text);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(result?['success'] == true
              ? 'Commande refusée.' : 'Erreur'),
          backgroundColor: result?['success'] == true
              ? AppColors.orange : AppColors.rouge,
        ));
      }
    }
  }
}
```

---

## ÉTAPE 8 — Mes Produits (Producteur)

### `lib/features/producteur/screens/mes_produits_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/mes_produits_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class MesProduitsScreen extends ConsumerWidget {
  const MesProduitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mesProduitsProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Mes Produits'),
        actions: [
          IconButton(
            icon:      const Icon(Icons.add),
            tooltip:   'Nouveau produit',
            onPressed: () =>
                context.go('/producteur/produit/nouveau'),
          ),
        ],
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('Erreur : $e')),
        data:    (produits) {
          if (produits.isEmpty) {
            return EmptyState(
              emoji:       '🌿',
              titre:       'Aucun produit',
              description: 'Ajoutez votre premier produit !',
              boutonLabel: 'Ajouter un produit',
              onBouton: () =>
                  context.go('/producteur/produit/nouveau'),
            );
          }

          return RefreshIndicator(
            color:     AppColors.vertVif,
            onRefresh: () =>
                ref.read(mesProduitsProvider.notifier).charger(),
            child: ListView.builder(
              padding:   const EdgeInsets.all(12),
              itemCount: produits.length,
              itemBuilder: (_, i) {
                final p = produits[i];
                return Container(
                  margin:  const EdgeInsets.only(bottom: 10),
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
                        child: p.imagePrincipale != null
                            ? CachedNetworkImage(
                                imageUrl: ImageUtils.imageUrl(
                                    p.imagePrincipale),
                                width: 70, height: 70,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 70, height: 70,
                                color: AppColors.vertMenthe,
                                child: const Center(
                                  child: Text('🌿',
                                    style: TextStyle(fontSize: 30)),
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
                              p.nom,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize:   15,
                                color:      AppColors.vertFonce,
                              ),
                            ),
                            Text(
                              FormatUtils.htg(p.prixUnitaire) +
                                  ' / ${p.uniteVenteLabel}',
                              style: const TextStyle(
                                fontSize: 13,
                                color:    AppColors.grisTexte,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Stock badge
                            _StockBadge(stock: p.stockReel),
                          ],
                        ),
                      ),

                      // Actions
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.vertVif,
                            ),
                            onPressed: () => context.go(
                              '/producteur/produit/${p.slug}/modifier',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.rouge,
                            ),
                            onPressed: () =>
                                _confirmerSuppression(context, ref, p.slug),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmerSuppression(
    BuildContext ctx, WidgetRef ref, String slug,
  ) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title:   const Text('Supprimer ce produit ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(mesProduitsProvider.notifier)
                  .supprimer(slug);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rouge),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;
  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (stock == 0) {
      color = AppColors.rouge;
      label = '🔴 Épuisé';
    } else if (stock <= 5) {
      color = AppColors.orange;
      label = '⚡ Stock faible : $stock';
    } else {
      color = AppColors.vertVif;
      label = '✅ En stock : $stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   11,
          fontWeight: FontWeight.w600,
          color:      color,
        ),
      ),
    );
  }
}
```

---

## ÉTAPE 9 — Formulaire Produit (Créer / Modifier)

### `lib/features/producteur/screens/produit_form_screen.dart`

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/mes_produits_provider.dart';

class ProduitFormScreen extends ConsumerStatefulWidget {
  final String? slug; // null = nouveau, slug = modifier
  const ProduitFormScreen({this.slug, super.key});

  @override
  ConsumerState<ProduitFormScreen> createState() =>
      _ProduitFormScreenState();
}

class _ProduitFormScreenState extends ConsumerState<ProduitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl   = TextEditingController();
  final _varCtrl   = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _prixCtrl  = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _seuilCtrl = TextEditingController();
  final _origCtrl  = TextEditingController();

  String  _uniteVente  = 'kg';
  int?    _categorieId;
  File?   _imageFile;
  bool    _isLoading   = false;

  static const _unites = [
    ('kg',     'Kilogramme (kg)'),
    ('tonne',  'Tonne'),
    ('sac_50', 'Sac 50 kg'),
    ('sac_25', 'Sac 25 kg'),
    ('botte',  'Botte'),
    ('piece',  'Pièce'),
    ('litre',  'Litre'),
    ('carton', 'Carton'),
    ('douz',   'Douzaine'),
  ];

  @override
  void dispose() {
    _nomCtrl.dispose();
    _varCtrl.dispose();
    _descCtrl.dispose();
    _prixCtrl.dispose();
    _stockCtrl.dispose();
    _seuilCtrl.dispose();
    _origCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth:  800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final body = <String, dynamic>{
      'nom':              _nomCtrl.text.trim(),
      'variete':          _varCtrl.text.trim(),
      'description':      _descCtrl.text.trim(),
      'prix_unitaire':    _prixCtrl.text.trim(),
      'stock_disponible': int.tryParse(_stockCtrl.text) ?? 0,
      'seuil_alerte':     int.tryParse(_seuilCtrl.text) ?? 10,
      'unite_vente':      _uniteVente,
      'origine':          _origCtrl.text.trim(),
      if (_categorieId != null) 'categorie': _categorieId,
    };

    bool success;
    if (widget.slug == null) {
      success = await ref.read(mesProduitsProvider.notifier)
          .creer(body, imagePath: _imageFile?.path);
    } else {
      success = await ref.read(mesProduitsProvider.notifier)
          .modifier(widget.slug!, body, imagePath: _imageFile?.path);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.slug == null
              ? '✅ Produit créé avec succès !'
              : '✅ Produit modifié !'),
          backgroundColor: AppColors.vertVif,
        ),
      );
      context.go('/producteur/catalogue');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Erreur lors de la sauvegarde.'),
          backgroundColor: AppColors.rouge,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.slug == null
              ? 'Nouveau produit'
              : 'Modifier le produit',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Image ──────────────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height:   180,
                  width:    double.infinity,
                  decoration: BoxDecoration(
                    color:        AppColors.vertMenthe,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(
                      color: AppColors.vertVif.withOpacity(0.3),
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                              size:  48,
                              color: AppColors.vertVif,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ajouter une photo',
                              style: TextStyle(
                                color:      AppColors.vertVif,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Nom ────────────────────────────────────────
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(
                  labelText:  'Nom du produit *',
                  prefixIcon: Icon(Icons.eco_outlined),
                ),
                validator: (v) =>
                    v?.isEmpty == true ? 'Requis' : null,
              ),
              const SizedBox(height: 12),

              // ── Variété ────────────────────────────────────
              TextFormField(
                controller: _varCtrl,
                decoration: const InputDecoration(
                  labelText:  'Variété',
                  prefixIcon: Icon(Icons.grass),
                ),
              ),
              const SizedBox(height: 12),

              // ── Description ────────────────────────────────
              TextFormField(
                controller: _descCtrl,
                maxLines:   3,
                decoration: const InputDecoration(
                  labelText:  'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // ── Prix & Unité ───────────────────────────────
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller:   _prixCtrl,
                    keyboardType: const TextInputType
                        .numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText:   'Prix (HTG) *',
                      prefixIcon: Icon(Icons.sell_outlined),
                    ),
                    validator: (v) =>
                        (double.tryParse(v ?? '') ?? 0) <= 0
                            ? 'Prix invalide' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value:    _uniteVente,
                    items:    _unites.map((u) => DropdownMenuItem(
                      value: u.$1,
                      child: Text(u.$2,
                        overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) =>
                        setState(() => _uniteVente = v!),
                    decoration: const InputDecoration(
                      labelText: 'Unité *',
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // ── Stock & Seuil ──────────────────────────────
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller:   _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText:  'Stock disponible *',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller:   _seuilCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText:   'Seuil alerte',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // ── Origine ────────────────────────────────────
              TextFormField(
                controller: _origCtrl,
                decoration: const InputDecoration(
                  labelText:  'Commune / Origine',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 28),

              // ── Bouton sauvegarder ─────────────────────────
              ElevatedButton.icon(
                icon:      Icon(
                  widget.slug == null ? Icons.add : Icons.save,
                ),
                label:     Text(
                  widget.slug == null
                      ? 'Créer le produit'
                      : 'Enregistrer les modifications',
                ),
                onPressed: _isLoading ? null : _sauvegarder,
                style:     ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vertFonce,
                  minimumSize:     const Size(double.infinity, 52),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## ÉTAPE 10 — Collectes Producteur

### `lib/features/producteur/screens/collectes_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/collectes_producteur_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class CollectesProducteurScreen extends ConsumerWidget {
  const CollectesProducteurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectesProducteurProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Mes Collectes'),
        actions: [
          IconButton(
            icon:      const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(collectesProducteurProvider.notifier)
                    .charger(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('Erreur : $e')),
        data:    (participations) {
          if (participations.isEmpty) {
            return const EmptyState(
              emoji:       '🚛',
              titre:       'Aucune collecte planifiée',
              description: 'Vous serez notifié(e) dès qu\'une '
                  'collecte est organisée dans votre zone.',
            );
          }

          return RefreshIndicator(
            color:     AppColors.vertVif,
            onRefresh: () =>
                ref.read(collectesProducteurProvider.notifier)
                    .charger(),
            child: ListView.builder(
              padding:   const EdgeInsets.all(12),
              itemCount: participations.length,
              itemBuilder: (_, i) {
                final part = participations[i];
                final c    = part.collecte;
                final date = c['date_prevue'] as String?;

                return Container(
                  margin:  const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color:        Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color:     Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header collecte
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.vertMenthe,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_shipping,
                              color: AppColors.vertFonce),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['titre'] as String? ??
                                        c['reference'] as String? ??
                                        'Collecte',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.vertFonce,
                                    ),
                                  ),
                                  if (date != null)
                                    Text(
                                      '📅 ${FormatUtils.date(date)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grisTexte,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            _StatutCollecteBadge(part.statut),
                          ],
                        ),
                      ),

                      // Détails
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            if (c['zone'] != null)
                              _InfoRow(
                                '📍', 'Zone',
                                c['zone'].toString(),
                              ),
                            if (part.quantitePrevue != null)
                              _InfoRow(
                                '⚖️', 'Quantité prévue',
                                '${part.quantitePrevue} kg',
                              ),
                            if (part.quantiteRecue != null)
                              _InfoRow(
                                '✅', 'Quantité reçue',
                                '${part.quantiteRecue} kg',
                              ),
                            if (part.montantPaye != null)
                              _InfoRow(
                                '💵', 'Montant reçu',
                                FormatUtils.htg(part.montantPaye),
                              ),

                            // Bouton confirmer si invité
                            if (part.statut == 'invite') ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon:      const Icon(Icons.check),
                                label:     const Text(
                                    'Confirmer ma participation'),
                                onPressed: () =>
                                    _confirmer(context, ref, part.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.vertVif,
                                  minimumSize: const Size(
                                      double.infinity, 44),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmer(
    BuildContext ctx, WidgetRef ref, int id,
  ) async {
    final qteCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    final confirm = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirmer ma participation',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: AppColors.vertFonce,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller:   qteCtrl,
              keyboardType: const TextInputType
                  .numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText:  'Quantité prévue (kg)',
                prefixIcon: Icon(Icons.scale),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText:  'Notes (optionnel)',
                prefixIcon: Icon(Icons.note_outlined),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertVif,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Confirmer'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(collectesProducteurProvider.notifier)
          .confirmer(
            id,
            quantitePrevue: double.tryParse(qteCtrl.text),
            notes: notesCtrl.text,
          );
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(
            success
                ? '✅ Participation confirmée !'
                : '❌ Erreur',
          ),
          backgroundColor:
              success ? AppColors.vertVif : AppColors.rouge,
        ));
      }
    }
  }
}

class _StatutCollecteBadge extends StatelessWidget {
  final String statut;
  const _StatutCollecteBadge(this.statut);

  @override
  Widget build(BuildContext context) {
    final colors = {
      'invite':   (AppColors.grisTexte, 'Invité'),
      'confirme': (AppColors.vertVif,   'Confirmé'),
      'present':  (AppColors.bleu,      'Présent'),
      'absent':   (AppColors.rouge,     'Absent'),
      'reporte':  (AppColors.orange,    'Reporté'),
    };
    final (color, label) = colors[statut] ??
        (AppColors.grisTexte, statut);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String valeur;
  const _InfoRow(this.emoji, this.label, this.valeur);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text(emoji),
        const SizedBox(width: 8),
        Text(label,
          style: const TextStyle(
            color: AppColors.grisTexte, fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(valeur,
          style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13,
            color: AppColors.vertFonce,
          ),
        ),
      ],
    ),
  );
}
```

---

## ÉTAPE 11 — App Collecteur

### `lib/features/collecteur/providers/collecteur_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final collecteurProvider =
    StateNotifierProvider<CollecteurNotifier,
        AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return CollecteurNotifier(ref.read(apiClientProvider));
});

class CollecteurNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiClient _api;

  CollecteurNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.mesParticipations);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = List<Map<String, dynamic>>.from(
          data['data'] as List,
        );
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

---

### `lib/features/collecteur/screens/collectes_terrain_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/collecteur_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class CollectesTerrainScreen extends ConsumerWidget {
  const CollectesTerrainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collecteurProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Mes Collectes Terrain')),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('Erreur : $e')),
        data:    (collectes) {
          if (collectes.isEmpty) {
            return const EmptyState(
              emoji:       '🚛',
              titre:       'Aucune collecte assignée',
              description:
                  'Les collectes qui vous sont assignées apparaîtront ici.',
            );
          }

          return ListView.builder(
            padding:   const EdgeInsets.all(12),
            itemCount: collectes.length,
            itemBuilder: (_, i) {
              final c = collectes[i];
              final collecte = c['collecte'] as Map<String, dynamic>? ?? {};

              return Container(
                margin:  const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:     Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:        AppColors.vertMenthe,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: AppColors.vertFonce,
                            size:  28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                collecte['titre'] as String? ??
                                    collecte['reference'] as String? ??
                                    'Collecte',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize:   16,
                                  color:      AppColors.vertFonce,
                                ),
                              ),
                              Text(
                                collecte['zone'] as String? ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color:    AppColors.grisTexte,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatutBadge(
                          collecte['statut'] as String? ?? '',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Infos collecte
                    Row(children: [
                      const Icon(Icons.calendar_today,
                        size: 14, color: AppColors.grisTexte),
                      const SizedBox(width: 6),
                      Text(
                        FormatUtils.date(
                          collecte['date_prevue'] as String?
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color:    AppColors.grisTexte,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 14),
                    // Nb producteurs
                    Row(children: [
                      const Icon(Icons.people_outline,
                        size: 14, color: AppColors.vertVif),
                      const SizedBox(width: 6),
                      Text(
                        '${collecte['nb_producteurs'] ?? 0} '
                        'producteur(s) participant(s)',
                        style: const TextStyle(
                          fontSize: 13,
                          color:    AppColors.grisTexte,
                        ),
                      ),
                    ]),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;
  const _StatutBadge(this.statut);

  @override
  Widget build(BuildContext context) {
    final map = {
      'planifiee':  (AppColors.bleu,     'Planifiée'),
      'en_cours':   (AppColors.orange,   'En cours'),
      'terminee':   (AppColors.vertVif,  'Terminée'),
      'annulee':    (AppColors.rouge,    'Annulée'),
    };
    final (color, label) = map[statut] ??
        (AppColors.grisTexte, statut);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
```

---

## ÉTAPE 12 — Écran Profil Producteur

### `lib/features/producteur/screens/profil_producteur_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class ProfilProducteurScreen extends ConsumerWidget {
  const ProfilProducteurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user  = ref.watch(authProvider).user;
    final stats = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned:          true,
            backgroundColor: AppColors.vertFonce,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.vertFonce, Color(0xFF1E8449)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius:          40,
                      backgroundColor: AppColors.jaune,
                      child: Text(
                        (user?.firstName ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize:   32,
                          fontWeight: FontWeight.w900,
                          color:      AppColors.vertFonce,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.firstName != null
                          ? '${user!.firstName} ${user.lastName}'
                          : '—',
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                    const Text(
                      '🌾 Producteur',
                      style: TextStyle(
                        color:   Color(0xBBFFFFFF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Stats rapides ──────────────────────────────────
          SliverToBoxAdapter(
            child: stats.whenOrNull(
              data: (s) => Container(
                margin:  const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:     Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickStat('${s.commandesTotal}',  'Commandes'),
                    _Divider(),
                    _QuickStat('${s.nbProduitsActifs}','Produits'),
                    _Divider(),
                    _QuickStat('${s.commandesLivrees}','Livrées'),
                  ],
                ),
              ),
            ) ?? const SizedBox.shrink(),
          ),

          // ── Menu ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _MenuItem(
                    icon:  Icons.person_outline,
                    label: 'Mon profil boutique',
                    onTap: () => context.go(
                        '/producteur/profil/modifier'),
                  ),
                  _MenuItem(
                    icon:  Icons.store_outlined,
                    label: 'Mes produits',
                    onTap: () =>
                        context.go('/producteur/catalogue'),
                  ),
                  _MenuItem(
                    icon:  Icons.receipt_outlined,
                    label: 'Mes commandes',
                    onTap: () =>
                        context.go('/producteur/commandes'),
                  ),
                  _MenuItem(
                    icon:  Icons.lock_outline,
                    label: 'Changer le mot de passe',
                    onTap: () {
                      // TODO: écran changer mot de passe
                    },
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon:  Icons.logout,
                    label: 'Se déconnecter',
                    color: AppColors.rouge,
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String valeur;
  final String label;
  const _QuickStat(this.valeur, this.label);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(valeur,
        style: const TextStyle(
          fontSize:   22,
          fontWeight: FontWeight.w900,
          color:      AppColors.vertFonce,
          fontFamily: 'PlayfairDisplay',
        ),
      ),
      Text(label,
        style: const TextStyle(
          fontSize: 12, color: AppColors.grisTexte,
        ),
      ),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 40, width: 1,
    color: const Color(0xFFEEEEEE),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.noir,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      leading:       Icon(icon, color: color),
      title:         Text(label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color:      color,
        ),
      ),
      trailing:      const Icon(
        Icons.chevron_right,
        color: AppColors.grisTexte,
      ),
      onTap:         onTap,
      shape:         RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
```

---

## ÉTAPE 13 — Mettre à jour le Router

Dans `lib/router/app_router.dart`, remplacer les `Placeholder()`
des shells Producteur et Collecteur :

```dart
// Imports à ajouter
import '../features/producteur/screens/dashboard_screen.dart';
import '../features/producteur/screens/commandes_recues_screen.dart';
import '../features/producteur/screens/mes_produits_screen.dart';
import '../features/producteur/screens/produit_form_screen.dart';
import '../features/producteur/screens/collectes_screen.dart';
import '../features/producteur/screens/profil_producteur_screen.dart';
import '../features/collecteur/screens/collectes_terrain_screen.dart';

// Shell Producteur — routes
GoRoute(
  path: '/producteur/dashboard',
  builder: (_, __) => const DashboardProducteurScreen(),
),
GoRoute(
  path: '/producteur/commandes',
  builder: (_, state) => CommandesRecuesScreen(
    statutInitial: state.uri.queryParameters['statut'],
  ),
),
GoRoute(
  path: '/producteur/commande/:numero',
  builder: (_, state) => CommandeDetailScreen(
    numero: state.pathParameters['numero']!,
  ),
),
GoRoute(
  path: '/producteur/catalogue',
  builder: (_, __) => const MesProduitsScreen(),
),
GoRoute(
  path: '/producteur/produit/nouveau',
  builder: (_, __) => const ProduitFormScreen(),
),
GoRoute(
  path: '/producteur/produit/:slug/modifier',
  builder: (_, state) => ProduitFormScreen(
    slug: state.pathParameters['slug'],
  ),
),
GoRoute(
  path: '/producteur/collectes',
  builder: (_, __) => const CollectesProducteurScreen(),
),
GoRoute(
  path: '/producteur/profil',
  builder: (_, __) => const ProfilProducteurScreen(),
),

// Shell Collecteur — routes
GoRoute(
  path: '/collecteur/collectes',
  builder: (_, __) => const CollectesTerrainScreen(),
),
GoRoute(
  path: '/collecteur/profil',
  builder: (_, __) => const ProfilProducteurScreen(), // réutiliser
),
```

---

## ÉTAPE 14 — Build et tests

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

---

## RÉSUMÉ — Ce que ce prompt crée

| Composant | Description |
|---|---|
| **DashboardProducteurScreen** | Header revenus, grille stats, actions rapides |
| **CommandesRecuesScreen** | Tabs par statut, confirmation/refus rapide |
| **MesProduitsScreen** | Liste avec stock badge, edit/delete |
| **ProduitFormScreen** | Créer/modifier avec image picker |
| **CollectesProducteurScreen** | Participations avec confirmation bottom sheet |
| **ProfilProducteurScreen** | Stats rapides + menu complet |
| **CollectesTerrainScreen** | Vue collecteur terrain |
| **StatCard widget** | Carte stat réutilisable colorée |
| **4 providers** | Dashboard, Commandes, Produits, Collectes |
| **Router complet** | Toutes les routes producteur + collecteur |

**Prochaine étape → Prompt 4 : App Admin mobile + Notifications FCM**
