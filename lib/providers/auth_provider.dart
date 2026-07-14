import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import '../core/offline/cache_manager.dart';
import '../core/notifications/fcm_service.dart';
import '../models/user.dart';

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

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
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
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user:   user,
        );
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

        state = state.copyWith(
          status:    AuthStatus.authenticated,
          user:      user,
          isLoading: false,
        );
        try {
          await _ref.read(fcmServiceProvider)
              .initialize(role: user.role)
              .timeout(const Duration(seconds: 5));
        } catch (_) {}
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error:     data['error']?.toString() ?? 'Erreur de connexion',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     'Vérifiez votre connexion internet.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String lastName,
    String telephone = '',
    String? codeParrainage,
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
          'role':       role,
          'first_name': firstName,
          'last_name':  lastName,
          'telephone':  telephone,
          if (codeParrainage != null && codeParrainage.isNotEmpty)
            'code_parrainage': codeParrainage,
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

        state = state.copyWith(
          status:    AuthStatus.authenticated,
          user:      user,
          isLoading: false,
        );
        try {
          await _ref.read(fcmServiceProvider)
              .initialize(role: user.role)
              .timeout(const Duration(seconds: 5));
        } catch (_) {}
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error:     data['error']?.toString(),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _ref.read(fcmServiceProvider).dispose().timeout(
        const Duration(seconds: 5),
      );
    } catch (_) {}
    final refresh = await _storage.getRefreshToken();
    try {
      await _api.post(AppEndpoints.logout, data: {'refresh': refresh});
    } catch (_) {}
    await _storage.clearAll();
    await _cache.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  bool get isProducteurEnAttente =>
      state.user?.role == 'producteur' &&
      state.user?.profilProducteurStatut == 'en_attente';
}
