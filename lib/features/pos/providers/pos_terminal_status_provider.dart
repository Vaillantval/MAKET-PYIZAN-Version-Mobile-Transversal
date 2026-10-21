import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

/// Statut d'autorisation du terminal POS courant, tel que renvoyé par
/// GET /api/pos/terminal/statut/ ou déduit en direct du `code` d'une 403
/// sur /api/pos/* (voir core/utils/api_error.dart).
///
/// Volontairement non-bloquant : ce statut alimente un badge (voir
/// PosTerminalBanner et l'onglet Profil), jamais une redirection forcée —
/// l'opérateur reste libre de naviguer même terminal non actif.
enum PosTerminalStatut { actif, enAttente, rejetee, revoque, roleInvalide, inconnu }

class PosTerminalInfo {
  final PosTerminalStatut statut;
  final int?    tentatives;
  final String? nom;
  final String? commune;

  const PosTerminalInfo({
    required this.statut,
    this.tentatives,
    this.nom,
    this.commune,
  });

  // Optimiste par défaut (comme ConnectivityService) : tant qu'aucun appel
  // n'a encore répondu, ne pas afficher un badge d'alerte sans raison.
  static const PosTerminalInfo initial = PosTerminalInfo(statut: PosTerminalStatut.actif);
}

final posTerminalStatusProvider =
    StateNotifierProvider<PosTerminalStatusNotifier, PosTerminalInfo>((ref) {
  return PosTerminalStatusNotifier(ref.read(apiClientProvider));
});

class PosTerminalStatusNotifier extends StateNotifier<PosTerminalInfo> {
  final ApiClient _api;

  PosTerminalStatusNotifier(this._api) : super(PosTerminalInfo.initial);

  /// GET /api/pos/terminal/statut/ — n'exige pas un terminal déjà actif
  /// (IsAuthenticated seulement), donc utilisable à tout moment (démarrage,
  /// reprise de l'app, bouton "Vérifier maintenant", réception d'un push).
  Future<void> verifier() async {
    try {
      final res = await _api.get(AppEndpoints.posTerminalStatut);
      final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
      final device = data?['device'] as Map<String, dynamic>?;
      state = PosTerminalInfo(
        statut:     _parse(data?['statut']?.toString()),
        tentatives: data?['tentatives'] as int?,
        nom:        device?['nom']?.toString(),
        commune:    device?['commune']?.toString(),
      );
    } catch (_) {
      // Best-effort — un échec de vérification ne doit pas casser l'UI ;
      // le statut affiché reste celui déjà connu.
    }
  }

  /// Mis à jour en direct par les providers POS (catalogue, session,
  /// vente) dès qu'une 403 {code} révèle le statut, sans attendre le
  /// prochain verifier().
  void definir(PosTerminalStatut statut) {
    if (state.statut == statut) return;
    state = PosTerminalInfo(
      statut:     statut,
      tentatives: state.tentatives,
      nom:        state.nom,
      commune:    state.commune,
    );
  }

  /// Code d'une 403 sur /api/pos/* ({code}) : met à jour le statut et
  /// renvoie vrai s'il s'agit d'un refus lié au terminal ou au compte.
  bool depuisCode(String? code) {
    final statut = switch (code) {
      'TERMINAL_EN_ATTENTE' => PosTerminalStatut.enAttente,
      'TERMINAL_REVOQUE'    => PosTerminalStatut.revoque,
      'ROLE_INVALIDE'       => PosTerminalStatut.roleInvalide,
      _                     => null,
    };
    if (statut == null) return false;
    definir(statut);
    return true;
  }

  /// Statut reçu dans un push pos_terminal (rejete / revoque / actif).
  void depuisPush(String? statut) {
    final s = _parse(statut);
    if (s == PosTerminalStatut.actif || s == PosTerminalStatut.inconnu) {
      verifier();
    } else {
      definir(s);
    }
  }

  static PosTerminalStatut _parse(String? s) {
    switch (s) {
      case 'actif':      return PosTerminalStatut.actif;
      case 'en_attente': return PosTerminalStatut.enAttente;
      case 'rejetee':
      case 'rejete':     return PosTerminalStatut.rejetee;
      case 'revoque':    return PosTerminalStatut.revoque;
      default:           return PosTerminalStatut.inconnu;
    }
  }
}
