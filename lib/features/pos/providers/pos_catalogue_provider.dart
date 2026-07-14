import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/cache_manager.dart';
import '../../../core/utils/string_utils.dart';
import '../../../models/pos_produit_catalogue.dart';

final posCatalogueProvider =
    StateNotifierProvider<PosCatalogueNotifier, AsyncValue<List<PosProduitCatalogue>>>((ref) {
  return PosCatalogueNotifier(ref.read(apiClientProvider), ref.read(cacheManagerProvider));
});

class PosCatalogueNotifier extends StateNotifier<AsyncValue<List<PosProduitCatalogue>>> {
  final ApiClient    _api;
  final CacheManager _cache;

  PosCatalogueNotifier(this._api, this._cache) : super(const AsyncValue.loading()) {
    charger();
  }

  /// GET /api/pos/catalogue/ avec revalidation ETag (If-None-Match).
  /// Sert toujours le cache local en attendant/à défaut de réseau.
  Future<void> charger() async {
    final cached = _cache.getPosCatalogue();
    if (cached != null) {
      state = AsyncValue.data(_parse(cached));
    }

    // Pas de pré-vérification isOnline ici : cette heuristique peut donner
    // un faux négatif durable sur certains réseaux, ce qui laissait cet
    // écran bloqué indéfiniment sur le chargement sans jamais rien
    // tenter ni afficher d'erreur. Le try/catch ci-dessous gère déjà
    // correctement un vrai échec réseau (repli sur le cache, ou erreur
    // affichée si aucun cache).
    try {
      final etag = _cache.getPosCatalogueEtag();
      final res = await _api.get(
        AppEndpoints.posCatalogue,
        options: Options(
          headers: etag != null ? {'If-None-Match': etag} : null,
          validateStatus: (code) => code != null && (code == 200 || code == 304),
        ),
      );

      if (res.statusCode == 304) return; // cache toujours à jour

      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = data['data'] as List;
        final newEtag = res.headers.value('etag');
        await _cache.savePosCatalogue(list, etag: newEtag);
        state = AsyncValue.data(_parse(list));
      }
    } catch (e) {
      if (cached == null) {
        state = AsyncValue.error(e, StackTrace.current);
      }
      // sinon : on garde silencieusement le cache déjà affiché
    }
  }

  List<PosProduitCatalogue> _parse(List<dynamic> raw) =>
      raw.map((e) => PosProduitCatalogue.fromJson(e as Map<String, dynamic>)).toList();

  /// Décrémente le stock du lot (ou du 1er lot du produit) EN CACHE,
  /// pour une cohérence visuelle immédiate entre deux synchronisations.
  Future<void> decrementerStock(int produitId, int? lotId, double quantite) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.map((p) {
      if (p.id != produitId || p.lots.isEmpty) return p;
      var dejaDecremente = false;
      final lots = p.lots.map((l) {
        if (dejaDecremente) return l;
        if (lotId != null && l.id != lotId) return l;
        dejaDecremente = true;
        final nouvelleQte = l.quantiteActuelle - quantite;
        return l.copyWith(quantiteActuelle: nouvelleQte < 0 ? 0 : nouvelleQte);
      }).toList();
      return p.copyWith(lots: lots);
    }).toList();

    state = AsyncValue.data(updated);
    await _cache.savePosCatalogue(updated.map((p) => p.toJson()).toList());
  }

  List<PosProduitCatalogue> rechercher(String query) {
    final list = state.valueOrNull ?? [];
    if (query.trim().isEmpty) return list;
    return list.where((p) => StringUtils.contains(p.nom, query)).toList();
  }

  List<String> get categories {
    final list = state.valueOrNull ?? [];
    final set = <String>{};
    for (final p in list) {
      if (p.categorie.isNotEmpty) set.add(p.categorie);
    }
    return set.toList()..sort();
  }
}
