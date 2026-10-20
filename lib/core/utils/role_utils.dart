import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Vrai quand l'écran courant est monté dans l'espace entreprise
/// (`/producteur/...`) plutôt que dans l'espace acheteur.
bool estEspaceEntreprise(BuildContext context) =>
    GoRouterState.of(context).matchedLocation.startsWith('/producteur');

/// Le wallet est accessible depuis l'espace acheteur (portefeuille
/// personnel) ET l'espace entreprise (portefeuille de l'entreprise,
/// propriétaires seulement), avec les mêmes écrans montés sous deux
/// préfixes de route différents.
String walletBasePath(BuildContext context) =>
    estEspaceEntreprise(context) ? '/producteur' : '/acheteur';
