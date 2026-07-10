import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'pos_exceptions.dart';

final posWalletProvider = Provider<PosWalletService>((ref) {
  return PosWalletService(ref.read(apiClientProvider));
});

/// Infos client renvoyées après vérification d'un code de paiement.
class PosClientWallet {
  final String nom;
  final double solde;
  const PosClientWallet({required this.nom, required this.solde});

  factory PosClientWallet.fromJson(Map<String, dynamic> json) {
    final client = json['client'];
    String nom = 'Client';
    if (client is Map) {
      nom = (client['nom'] ??
              client['username'] ??
              client['first_name'] ??
              client['telephone'] ??
              'Client')
          .toString();
    } else if (client is String && client.isNotEmpty) {
      nom = client;
    }
    final solde = double.tryParse('${json['solde'] ?? 0}') ?? 0.0;
    return PosClientWallet(nom: nom, solde: solde);
  }
}

class PosWalletService {
  final ApiClient _api;
  PosWalletService(this._api);

  /// Vérifie le code de paiement à 6 chiffres présenté par le client.
  /// Lève [PosVenteException] (CODE_INVALIDE) si le code est invalide,
  /// expiré ou déjà utilisé.
  Future<PosClientWallet> verifierCode(String code) async {
    try {
      final res  = await _api.post(
        AppEndpoints.posVerifierCodeClient,
        data: {'code': code},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return PosClientWallet.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw PosVenteException(
        'CODE_INVALIDE',
        data['error']?.toString() ??
            'Code invalide ou expiré — demandez au client de régénérer un nouveau code.',
      );
    } on PosVenteException {
      rethrow;
    } catch (_) {
      throw const PosVenteException(
        'RESEAU',
        'Impossible de vérifier le code — vérifiez la connexion.',
      );
    }
  }
}
