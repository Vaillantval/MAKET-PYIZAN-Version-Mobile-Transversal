import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/offline/offline_manager.dart';
import '../../../core/offline/sync_queue.dart';
import '../../../core/storage/local_storage.dart';
import '../../../models/panier.dart';
import '../../../models/produit.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/choix_unite.dart';

/// Panier du visiteur, gardé sur l'appareil (comme le panier de session du
/// site) puis transféré sur le compte à la connexion.
const _clePanierInvite = 'panier_invite';

final panierProvider =
    StateNotifierProvider<PanierNotifier, AsyncValue<Panier>>((ref) {
  final session = ref.watch(sessionUtilisateurProvider); // recharger au changement de compte
  return PanierNotifier(
    ref.read(apiClientProvider),
    ref.read(offlineManagerProvider),
    ref.read(localStorageProvider),
    connecte: session != null,
  );
});

class PanierNotifier extends StateNotifier<AsyncValue<Panier>> {
  final ApiClient      _api;
  final OfflineManager _offline;
  final LocalStorage   _local;
  final bool           connecte;

  PanierNotifier(this._api, this._offline, this._local, {required this.connecte})
      : super(const AsyncValue.loading()) {
    connecte ? _transfererPuisCharger() : _publierLocal();
  }

  // ── Panier local (visiteur) ────────────────────────────────────────

  List<LignePanier> get _lignesLocales => (_local.getJsonList(_clePanierInvite) ?? const [])
      .map((j) => LignePanier.fromJson(Map<String, dynamic>.from(j as Map)))
      .toList();

  Future<void> _enregistrerLocal(List<LignePanier> lignes) async {
    await _local.setJsonList(_clePanierInvite, [for (final l in lignes) l.toJson()]);
    _publierLocal(lignes);
  }

  void _publierLocal([List<LignePanier>? lignes]) {
    final items = lignes ?? _lignesLocales;
    final producteurs = <int, Map<String, dynamic>>{};
    for (final l in items) {
      producteurs[l.producteurId] = {'id': l.producteurId, 'nom': l.producteurNom};
    }
    state = AsyncValue.data(Panier(
      items:       items,
      total:       items.fold(0.0, (t, l) => t + l.sousTotal),
      nbArticles:  items.fold(0, (n, l) => n + l.quantite),
      nbItems:     items.length,
      producteurs: producteurs.values.toList(),
    ));
  }

  bool _memeLigne(LignePanier l, String slug, int? uniteId) =>
      l.slug == slug && l.uniteVenteId == uniteId;

  /// Stock (unités de base) déjà pris par les autres lignes du produit.
  int _stockPrisAilleurs(List<LignePanier> lignes, String slug, int? uniteId) => lignes
      .where((l) => l.slug == slug && !_memeLigne(l, slug, uniteId))
      .fold(0, (t, l) => t + (l.quantite * l.facteur).ceil());

  String? _verifierStock(List<LignePanier> lignes, String slug, int? uniteId,
      int quantite, double facteur, int stock, String nom) {
    final pris = _stockPrisAilleurs(lignes, slug, uniteId) + (quantite * facteur).ceil();
    return pris > stock ? "Stock insuffisant pour '$nom'. Disponible : $stock." : null;
  }

  /// Après connexion : envoie le panier local sur le compte, puis le vide.
  Future<void> _transfererPuisCharger() async {
    final locales = _lignesLocales;
    for (final l in locales) {
      try {
        await _api.post(AppEndpoints.panierAjouter, data: {
          'slug': l.slug,
          'quantite': l.quantite,
          if (l.uniteVenteId != null) 'unite_id': l.uniteVenteId,
        });
      } catch (_) {
        // Stock épuisé entre-temps, produit retiré… : la ligne est perdue
        // plutôt que de bloquer le reste du panier.
      }
    }
    if (locales.isNotEmpty) await _local.remove(_clePanierInvite);
    await charger();
  }

  // ── API commune ────────────────────────────────────────────────────

  Future<void> charger() async {
    if (!connecte) return _publierLocal();
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

  /// Ajoute [quantite] de [produit] dans l'[unite] choisie (unité de base
  /// par défaut). Renvoie un message d'erreur, ou null en cas de succès.
  Future<String?> ajouter(Produit produit, int quantite, {OptionUnite? unite}) async {
    final u = unite ?? OptionUnite.pour(produit).first;
    if (!connecte) {
      final lignes = _lignesLocales;
      final i = lignes.indexWhere((l) => _memeLigne(l, produit.slug, u.id));
      final nouvelle = (i >= 0 ? lignes[i].quantite : 0) + quantite;
      final erreur = _verifierStock(lignes, produit.slug, u.id, nouvelle,
          u.facteur, produit.stockReel, produit.nom);
      if (erreur != null) return erreur;
      final ligne = LignePanier(
        id:            i >= 0 ? lignes[i].id : -DateTime.now().microsecondsSinceEpoch,
        slug:          produit.slug,
        nom:           produit.nom,
        quantite:      nouvelle,
        prixUnitaire:  u.prix.toStringAsFixed(2),
        sousTotal:     u.prix * nouvelle,
        uniteVente:    u.code,
        uniteVenteId:  u.id,
        uniteVenteLabel: u.libelle,
        producteurId:  (produit.producteur?['id'] as int?) ?? 0,
        producteurNom: (produit.producteur?['nom'] ?? '').toString(),
        image:         produit.imagePrincipale,
        stockReel:     produit.stockReel,
        facteur:       u.facteur,
      );
      if (i >= 0) {
        lignes[i] = ligne;
      } else {
        lignes.add(ligne);
      }
      await _enregistrerLocal(lignes);
      return null;
    }

    final result = await _offline.execute(SyncAction(
      type:     SyncActionType.panierAjouter,
      endpoint: AppEndpoints.panierAjouter,
      method:   'POST',
      payload:  {
        'slug': produit.slug,
        'quantite': quantite,
        if (u.id != null) 'unite_id': u.id,
      },
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

  Future<void> modifier(LignePanier ligne, int quantite) async {
    if (!connecte) {
      final lignes = _lignesLocales;
      final i = lignes.indexWhere((l) => _memeLigne(l, ligne.slug, ligne.uniteVenteId));
      if (i < 0) return;
      if (_verifierStock(lignes, ligne.slug, ligne.uniteVenteId, quantite,
              ligne.facteur, ligne.stockReel, ligne.nom) != null) {
        return;
      }
      final prix = double.tryParse(ligne.prixUnitaire) ?? 0;
      lignes[i] = lignes[i].copyWith(quantite: quantite, sousTotal: prix * quantite);
      return _enregistrerLocal(lignes);
    }
    final result = await _offline.execute(SyncAction(
      type:     SyncActionType.panierModifier,
      endpoint: _avecUnite(AppEndpoints.panierModifier(ligne.slug), ligne.uniteVenteId),
      method:   'PATCH',
      payload:  {
        'quantite': quantite,
        if (ligne.uniteVenteId != null) 'unite_id': ligne.uniteVenteId,
      },
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

  Future<void> retirer(LignePanier ligne) async {
    if (!connecte) {
      return _enregistrerLocal(_lignesLocales
          .where((l) => !_memeLigne(l, ligne.slug, ligne.uniteVenteId))
          .toList());
    }
    await _offline.execute(SyncAction(
      type:     SyncActionType.panierRetirer,
      endpoint: _avecUnite(AppEndpoints.panierRetirer(ligne.slug), ligne.uniteVenteId),
      method:   'DELETE',
      payload:  {},
    ));
    await charger();
  }

  Future<void> vider() async {
    if (!connecte) return _enregistrerLocal(const []);
    await _offline.execute(SyncAction(
      type:     SyncActionType.panierVider,
      endpoint: AppEndpoints.panierVider,
      method:   'DELETE',
      payload:  {},
    ));
    await charger();
  }

  /// Le backend cible la ligne d'une unité précise via ?unite_id=.
  String _avecUnite(String endpoint, int? uniteId) =>
      uniteId == null ? endpoint : '$endpoint?unite_id=$uniteId';

  int get nbArticles {
    return state.whenOrNull(data: (p) => p.nbArticles) ?? 0;
  }
}
