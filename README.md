# Makèt Peyizan — App mobile

Application Flutter du marketplace agricole haïtien Makèt Peyizan. Un seul
binaire couvre plusieurs rôles, chacun avec son propre parcours et sa propre
navigation :

- **Acheteur** — catalogue, panier, commandes, portefeuille prépayé (wallet)
- **Producteur** — dépôt de produits, commandes reçues, collectes, wallet
- **Collecteur** — collectes terrain
- **Admin** — gestion utilisateurs, commandes, paiements, catalogue, stocks
- **Opérateur de caisse (`pos_operator`)** — app comptoir hors-ligne d'abord :
  vente, session de caisse, historique, impression de reçu (Sunmi)

## Stack technique

- **Flutter** (Dart) — Riverpod (state management), go_router (navigation),
  Dio (HTTP), Freezed + json_serializable (modèles)
- **Stockage local** — SharedPreferences (préférences + tokens JWT), Hive
  (données POS hors-ligne)
- **Backend** — API REST Django, enveloppe uniforme
  `{"success": bool, "data"/"error": ...}`
- **Firebase** — notifications push (FCM)
- **Sunmi Printer** — impression de reçus thermiques sur les terminaux Sunmi,
  avec dégradation gracieuse sur les autres appareils

## Prérequis

- Flutter SDK (stable)
- Android SDK (cmdline-tools, platform-tools, build-tools) pour le build
  Android
- JDK 17
- Un fichier `.env` à la racine (voir `AppConstants` pour les clés
  attendues) et `android/app/google-services.json` (config Firebase
  Android — non versionné, à demander à l'équipe)

## Configuration

L'URL de l'API backend est surchargeable au build :

```bash
flutter run --dart-define=BASE_URL=https://maketpeyizan.ht
```

Par défaut (sans `--dart-define`), l'app pointe vers `https://maketpeyizan.ht`.

## Lancer en développement

```bash
flutter pub get
flutter run
```

## Build APK

```bash
# Debug
flutter build apk --debug

# Release — nécessite android/key.properties (voir plus bas)
flutter build apk --release
```

### Signature release

La release est signée via `android/key.properties`, qui référence un
keystore (`.jks`). Ni l'un ni l'autre ne sont versionnés (voir
`.gitignore`) — à demander à l'équipe ou à régénérer avec `keytool`. Sans
`key.properties`, `flutter build apk --release` retombe automatiquement sur
la clé debug pour ne pas casser le build sur un nouveau clone.

## Structure du projet

```
lib/
├── core/            # API client, stockage, offline, thème, utilitaires, impression
├── features/        # Un dossier par rôle (acheteur, producteur, collecteur, admin, pos)
├── models/           # Modèles Freezed / json_serializable
├── providers/        # Providers Riverpod transverses (auth, ...)
├── router/           # Configuration go_router (redirection par rôle)
└── shared/            # Widgets partagés
```

## Notes

- Architecture **offline-first** pour l'app caisse (POS) : ventes mises en
  file d'attente localement (Hive) et synchronisées dès que la connexion
  revient.
- Les montants monétaires transitent en chaînes de caractères côté backend
  (ex: `"500.00"`) — voir `core/utils/json_converters.dart`.
