import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/utils/api_error.dart';

final entrepriseServiceProvider = Provider<EntrepriseService>((ref) {
  return EntrepriseService(ref.read(apiClientProvider));
});

/// Membre d'une entreprise (GET /api/entreprises/<id>/membres/).
class Membre {
  final int    id;
  final int    userId;
  final String nom;
  final String email;
  final String role;
  final String roleLabel;

  const Membre({
    required this.id,
    required this.userId,
    required this.nom,
    required this.email,
    required this.role,
    required this.roleLabel,
  });

  bool get estProprietaire => role == 'proprietaire';

  factory Membre.fromJson(Map<String, dynamic> json) => Membre(
        id:        json['id']       as int,
        userId:    json['user_id']  as int? ?? 0,
        nom:       json['nom']      as String? ?? '',
        email:     json['email']    as String? ?? '',
        role:      json['role']     as String? ?? 'gestionnaire',
        roleLabel: json['role_label'] as String? ?? '',
      );
}

/// Erreur métier renvoyée par l'API, avec un message affichable.
class EntrepriseException implements Exception {
  final String message;
  const EntrepriseException(this.message);
  @override
  String toString() => message;
}

class EntrepriseService {
  final ApiClient _api;
  EntrepriseService(this._api);

  Future<T> _appel<T>(Future<dynamic> Function() requete,
      T Function(dynamic data) lire, String erreurDefaut) async {
    try {
      final res  = await requete();
      final body = res.data as Map<String, dynamic>;
      if (body['success'] == true) return lire(body['data']);
      throw EntrepriseException(
          extraireMessageErreur(body['error'], erreurDefaut));
    } on EntrepriseException {
      rethrow;
    } catch (e) {
      throw EntrepriseException(messageErreurApi(e, erreurDefaut));
    }
  }

  /// POST /api/entreprises/ — le compte en devient propriétaire ;
  /// l'entreprise reste « en attente » jusqu'à validation par l'admin.
  Future<Map<String, dynamic>> creer(Map<String, dynamic> donnees) => _appel(
        () => _api.post(AppEndpoints.entreprises, data: donnees),
        (d) => d as Map<String, dynamic>,
        'Impossible de créer l\'entreprise.',
      );

  Future<List<Membre>> membres(int entrepriseId) => _appel(
        () => _api.get(AppEndpoints.entrepriseMembres(entrepriseId)),
        (d) => (d as List)
            .map((e) => Membre.fromJson(e as Map<String, dynamic>))
            .toList(),
        'Impossible de charger les membres.',
      );

  /// Ajouter un compte déjà inscrit, désigné par son email (propriétaire).
  Future<Membre> ajouterMembre(int entrepriseId, String email, String role) =>
      _appel(
        () => _api.post(AppEndpoints.entrepriseMembres(entrepriseId),
            data: {'email': email, 'role': role}),
        (d) => Membre.fromJson(d as Map<String, dynamic>),
        'Impossible d\'ajouter ce membre.',
      );

  Future<Membre> changerRole(int entrepriseId, int membreId, String role) =>
      _appel(
        () => _api.patch(AppEndpoints.entrepriseMembre(entrepriseId, membreId),
            data: {'role': role}),
        (d) => Membre.fromJson(d as Map<String, dynamic>),
        'Impossible de changer le rôle.',
      );

  /// Retirer un membre (propriétaire), ou quitter l'entreprise (soi-même).
  Future<void> retirerMembre(int entrepriseId, int membreId) => _appel(
        () => _api.delete(AppEndpoints.entrepriseMembre(entrepriseId, membreId)),
        (_) {},
        'Impossible de retirer ce membre.',
      );

  /// GET/PATCH /api/auth/producteur/profil/ — fiche de l'entreprise active.
  Future<Map<String, dynamic>> profil() => _appel(
        () => _api.get(AppEndpoints.producteurProfil),
        (d) => d as Map<String, dynamic>,
        'Impossible de charger la fiche de l\'entreprise.',
      );

  Future<Map<String, dynamic>> modifierProfil(Map<String, dynamic> donnees) =>
      _appel(
        () => _api.patch(AppEndpoints.producteurProfil, data: donnees),
        (d) => d as Map<String, dynamic>,
        'Impossible d\'enregistrer les modifications.',
      );
}
