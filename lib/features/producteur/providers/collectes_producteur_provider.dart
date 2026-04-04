import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class ParticipationCollecte {
  final int    id;
  final String statut;
  final String statutLabel;
  final Map<String, dynamic> collecte;
  final double? quantitePrevue;
  final double? quantiteRecue;
  final double? montantPaye;
  final bool    paiementEffectue;

  const ParticipationCollecte({
    required this.id,
    required this.statut,
    required this.statutLabel,
    required this.collecte,
    this.quantitePrevue,
    this.quantiteRecue,
    this.montantPaye,
    this.paiementEffectue = false,
  });

  factory ParticipationCollecte.fromJson(Map<String, dynamic> json) =>
      ParticipationCollecte(
        id:               json['id'] as int,
        statut:           json['statut'] as String? ?? '',
        statutLabel:      json['statut_label'] as String? ?? '',
        collecte:         Map<String, dynamic>.from(
                            json['collecte'] as Map? ?? {}),
        quantitePrevue:   double.tryParse(
                            json['quantite_prevue']?.toString() ?? ''),
        quantiteRecue:    double.tryParse(
                            json['quantite_recue']?.toString() ?? ''),
        montantPaye:      double.tryParse(
                            json['montant_paye']?.toString() ?? ''),
        paiementEffectue: json['paiement_effectue'] as bool? ?? false,
      );
}

final collectesProducteurProvider = StateNotifierProvider<
    CollectesProducteurNotifier,
    AsyncValue<List<ParticipationCollecte>>>((ref) {
  return CollectesProducteurNotifier(ref.read(apiClientProvider));
});

class CollectesProducteurNotifier
    extends StateNotifier<AsyncValue<List<ParticipationCollecte>>> {
  final ApiClient _api;

  CollectesProducteurNotifier(this._api)
      : super(const AsyncValue.loading()) {
    charger();
  }

  Future<void> charger() async {
    state = const AsyncValue.loading();
    try {
      final res  = await _api.get(AppEndpoints.mesParticipations);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => ParticipationCollecte.fromJson(
                  e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> confirmer(
    int id, {
    double? quantitePrevue,
    String  notes = '',
  }) async {
    try {
      final body = <String, dynamic>{'notes': notes};
      if (quantitePrevue != null) {
        body['quantite_prevue'] = quantitePrevue;
      }
      final res  = await _api.patch(
        AppEndpoints.confirmerParticipation(id), data: body,
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) { await charger(); return true; }
      return false;
    } catch (_) { return false; }
  }
}
