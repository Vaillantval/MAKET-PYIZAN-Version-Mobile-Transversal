import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import '../core/offline/cache_manager.dart';
import '../core/notifications/fcm_service.dart';
import '../core/utils/api_error.dart';
import '../models/user.dart';
import 'entreprise_provider.dart';

// État d'authentification
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User?      user;
  final String?    error;
  final bool       isLoading;

  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User?       user,
    String?     error,
    bool?       isLoading,
  }) => AuthState(
    status:    status    ?? this.status,
    user:      user      ?? this.user,
    error:     error,
    isLoading: isLoading ?? this.isLoading,
  );
}

/// Identifiant du compte connecté (null en visiteur). Les données propres
/// au compte (panier, portefeuille, commandes…) le surveillent pour être
/// rechargées à la connexion, à la déconnexion et au changement de compte.
final sessionUtilisateurProvider = Provider<int?>(
    (ref) => ref.watch(authProvider.select((s) => s.user?.id)));

final StateNotifierProvider<AuthNotifier, AuthState> authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(apiClientProvider),
    ref.read(secureStorageProvider),
    ref.read(cacheManagerProvider),
    ref,
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient      _api;
  final SecureStorage  _storage;
  final CacheManager   _cache;
  final Ref            _ref;

  AuthNotifier(this._api, this._storage, this._cache, this._ref)
      : super(const AuthState(status: AuthStatus.unknown)) {
    checkAuth();
  }

  // Vérifier si l'utilisateur est déjà connecté au démarrage
  Future<void> checkAuth() async {
    final isLogged = await _storage.isLoggedIn();
    if (!isLogged) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    // Charger le profil depuis le cache
    final cachedUser = _cache.getUser();
    if (cachedUser != null) {
      final user = User.fromJson(cachedUser);
      // Persister role/id ici aussi : ce statut "authenticated" déclenche
      // déjà la redirection (donc de possibles appels API immédiats,
      // ex: header X-POS-Device) avant même que le rafraîchissement
      // réseau ci-dessous n'ait eu le temps de le faire.
      await _storage.saveUserRole(user.role);
      await _storage.saveUserId(user.id);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user:   user,
      );
    }

    // Rafraîchir depuis l'API si en ligne
    try {
      final response = await _api.get(AppEndpoints.me);
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final user = User.fromJson(
          data['data'] as Map<String, dynamic>
        );
        // Persister role/id : l'intercepteur API (header X-POS-Device
        // notamment) les lit directement du storage, pas de AuthState.
        await _storage.saveUserRole(user.role);
        await _storage.saveUserId(user.id);
        await _cache.saveUser(data['data'] as Map<String, dynamic>);
        await _ref.read(entrepriseActiveIdProvider.notifier)
            .synchroniser(user.entreprises);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user:   user,
        );
        // Session ouverte au démarrage : renvoyer le jeton FCM (sinon un
        // compte resté connecté n'est jamais joignable par push)
        unawaited(_ref.read(fcmServiceProvider).enregistrer(uneFoisParLancement: true));
      }
    } catch (_) {
      // Pas de réseau → utiliser le cache
      if (cachedUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(
        AppEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final d = data['data'] as Map<String, dynamic>;
        await _storage.saveAccessToken(d['access']  as String);
        await _storage.saveRefreshToken(d['refresh'] as String);

        final user = User.fromJson(d['user'] as Map<String, dynamic>);
        await _storage.saveUserRole(user.role);
        await _storage.saveUserId(user.id);
        await _cache.saveUser(d['user'] as Map<String, dynamic>);
        await _ref.read(entrepriseActiveIdProvider.notifier).quitter();

        state = state.copyWith(
          status:    AuthStatus.authenticated,
          user:      user,
          isLoading: false,
        );
        // Jeton FCM : sans attendre (demande de permission, réseau)
        unawaited(_ref.read(fcmServiceProvider).enregistrer());
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error:     extraireMessageErreur(data['error'], 'Erreur de connexion'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     messageErreurApi(e, 'Vérifiez votre connexion internet.'),
      );
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String telephone = '',
    String? codeParrainage,
    // Entreprise à créer avec le compte (cf. EntrepriseFormController) :
    // vendre passe par une entreprise, plus par le rôle « producteur ».
    Map<String, dynamic>? entreprise,
    // Profil acheteur (tous optionnels côté backend).
    String? departement,
    String? typeAcheteur,
    String? nomOrganisation,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(
        AppEndpoints.register,
        data: {
          'username':   username,
          'email':      email,
          'password':   password,
          'password2':  password, // requis par le backend
          'role':       'acheteur',
          'first_name': firstName,
          'last_name':  lastName,
          'telephone':  telephone,
          if (codeParrainage != null && codeParrainage.isNotEmpty)
            'code_parrainage': codeParrainage,
          if (departement != null && departement.isNotEmpty)
            'departement': departement,
          if (entreprise != null) 'entreprise': entreprise,
          if (typeAcheteur != null && typeAcheteur.isNotEmpty)
            'type_acheteur': typeAcheteur,
          if (nomOrganisation != null && nomOrganisation.isNotEmpty)
            'nom_organisation': nomOrganisation,
        },
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final d    = data['data'] as Map<String, dynamic>;
        await _storage.saveAccessToken(d['access']  as String);
        await _storage.saveRefreshToken(d['refresh'] as String);

        final user = User.fromJson(d['user'] as Map<String, dynamic>);
        await _storage.saveUserRole(user.role);
        await _storage.saveUserId(user.id);
        await _cache.saveUser(d['user'] as Map<String, dynamic>);
        // Entreprise créée avec le compte : ouvrir directement son espace
        // (écran « en attente de validation ») — fait avant le passage à
        // `authenticated`, qui redirige aussitôt vers l'accueil.
        final active = _ref.read(entrepriseActiveIdProvider.notifier);
        if (entreprise != null && user.entreprises.isNotEmpty) {
          await active.activer(user.entreprises.first);
        } else {
          await active.quitter();
        }

        state = state.copyWith(
          status:    AuthStatus.authenticated,
          user:      user,
          isLoading: false,
        );
        // Jeton FCM : sans attendre (demande de permission, réseau)
        unawaited(_ref.read(fcmServiceProvider).enregistrer());
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error:     extraireMessageErreur(data['error'], 'Erreur d\'inscription'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     messageErreurApi(e, 'Vérifiez votre connexion internet.'),
      );
      return false;
    }
  }

  Future<void> logout() async {
    // Le serveur invalide le refresh et retire ce jeton FCM du compte
    final fcm     = _ref.read(fcmServiceProvider);
    final refresh = await _storage.getRefreshToken();
    final jeton   = await fcm.jetonActuel();
    try {
      await _api.post(AppEndpoints.logout, data: {
        'refresh': refresh ?? '',
        if (jeton != null) 'fcm_token': jeton,
      });
    } catch (_) {}
    unawaited(fcm.oublier());
    await _storage.clearAll();
    await _cache.clearAll();
    await _ref.read(entrepriseActiveIdProvider.notifier).quitter();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Session refusée par le serveur (renouvellement du jeton impossible) :
  /// repasser en déconnecté sans appel réseau. Les écrans publics (boutique,
  /// panier visiteur) restent accessibles, le reste redemande la connexion.
  Future<void> sessionExpiree() async {
    if (state.status != AuthStatus.authenticated) return;
    await _storage.clearAll();
    await _cache.clearAll();
    await _ref.read(entrepriseActiveIdProvider.notifier).quitter();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      error: 'Votre session a expiré. Reconnectez-vous.',
    );
  }

  /// Recharger le profil (ex: après création d'une entreprise ou pour
  /// vérifier si une entreprise a été validée).
  Future<void> rafraichirProfil() => checkAuth();
}
