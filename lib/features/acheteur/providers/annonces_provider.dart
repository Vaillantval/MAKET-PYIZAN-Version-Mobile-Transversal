import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/offline/cache_manager.dart';
import 'catalogue_provider.dart';

/// Annonce du carrousel de l'accueil : les mêmes « slides » que la page
/// d'accueil du site, gérées depuis le tableau de bord superadmin.
class Annonce {
  final int id;
  final String titre;
  final String sousTitre;
  final String texteBouton;
  final String lien;
  final String image;

  const Annonce({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.texteBouton,
    required this.lien,
    required this.image,
  });

  factory Annonce.fromJson(Map<String, dynamic> j) => Annonce(
        id:          (j['id'] as num?)?.toInt() ?? 0,
        titre:       (j['titre'] ?? '').toString(),
        sousTitre:   (j['sous_titre'] ?? '').toString(),
        texteBouton: (j['texte_bouton'] ?? '').toString(),
        lien:        (j['lien'] ?? '').toString(),
        image:       (j['image'] ?? '').toString(),
      );
}

/// Annonces actives, dans l'ordre du site. Gardées 1 h en cache, et la
/// dernière liste connue sert hors ligne ; vide en cas d'échec (l'accueil
/// affiche alors son bandeau habituel).
final annoncesProvider = FutureProvider<List<Annonce>>((ref) async {
  final api   = ref.read(apiClientProvider);
  final cache = ref.read(cacheManagerProvider);

  List<Annonce> lire(dynamic liste) => (liste as List)
      .whereType<Map>()
      .map((m) => Annonce.fromJson(Map<String, dynamic>.from(m)))
      .where((a) => a.image.isNotEmpty)
      .toList();

  final frais = cache.getData('annonces', ttl: const Duration(hours: 1));
  if (frais != null) return lire(frais);

  try {
    final res  = await api.get(AppEndpoints.annonces);
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      final liste = data['data'] as List;
      await cache.saveData('annonces', liste);
      return lire(liste);
    }
  } catch (_) {
    final ancien = cache.getData('annonces');
    if (ancien != null) return lire(ancien);
  }
  return const [];
});

/// Ouvre le lien d'une annonce. Les liens du site (`#catalogue`,
/// `/produits/<slug>/`, `/inscription/`…) mènent à l'écran équivalent de
/// l'app ; les autres pages du site et les sites externes s'ouvrent dans
/// le navigateur.
void ouvrirLienAnnonce(BuildContext context, WidgetRef ref, String lien) {
  final cible = routeAnnonce(lien);
  if (cible == null) return;
  if (cible.route != null) {
    final categorie = cible.categorie;
    if (categorie != null) {
      final notifier = ref.read(catalogueProvider.notifier);
      notifier.appliquerFiltre(ref
          .read(catalogueProvider)
          .filtre
          .copyWith(categorieSlug: categorie));
    }
    context.go(cible.route!);
  } else {
    launchUrl(cible.web!, mode: LaunchMode.externalApplication);
  }
}

/// Destination d'un lien d'annonce : un écran de l'app ([route], avec une
/// [categorie] à filtrer pour le catalogue) ou une page web ([web]).
class CibleAnnonce {
  final String? route;
  final String? categorie;
  final Uri? web;
  const CibleAnnonce.ecran(this.route, {this.categorie}) : web = null;
  const CibleAnnonce.web(this.web) : route = null, categorie = null;
}

CibleAnnonce? routeAnnonce(String lien) {
  final l = lien.trim();
  if (l.isEmpty) return null;
  if (l.startsWith('#')) {
    // Ancres de la page d'accueil du site
    return l == '#catalogue'
        ? const CibleAnnonce.ecran('/acheteur/catalogue')
        : const CibleAnnonce.ecran('/acheteur/accueil');
  }

  final site = Uri.parse(AppConstants.baseUrl);
  final uri  = Uri.tryParse(l);
  if (uri == null) return null;
  final duSite = !uri.hasScheme ||
      uri.host == site.host ||
      uri.host == 'www.${site.host}';
  if (!duSite) {
    return uri.isScheme('http') || uri.isScheme('https')
        ? CibleAnnonce.web(uri)
        : null;
  }

  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  final premier  = segments.isEmpty ? '' : segments.first;
  switch (premier) {
    case '':
      return uri.fragment == 'catalogue'
          ? const CibleAnnonce.ecran('/acheteur/catalogue')
          : const CibleAnnonce.ecran('/acheteur/accueil');
    case 'catalogue':
      return CibleAnnonce.ecran('/acheteur/catalogue',
          categorie: uri.queryParameters['categorie']);
    case 'produits':
      return segments.length > 1
          ? CibleAnnonce.ecran('/acheteur/produit/${segments[1]}')
          : const CibleAnnonce.ecran('/acheteur/catalogue');
    case 'panier':
      return const CibleAnnonce.ecran('/acheteur/panier');
    case 'inscription':
      return const CibleAnnonce.ecran('/register');
    case 'connexion':
      return const CibleAnnonce.ecran('/login');
  }
  // Page du site sans équivalent dans l'app (à propos, FAQ…)
  return CibleAnnonce.web(site.replace(
    path: uri.path,
    query: uri.hasQuery ? uri.query : null,
    fragment: uri.hasFragment ? uri.fragment : null,
  ));
}
