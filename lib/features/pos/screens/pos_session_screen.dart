import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/pos_session_provider.dart';

class PosSessionScreen extends ConsumerStatefulWidget {
  const PosSessionScreen({super.key});

  @override
  ConsumerState<PosSessionScreen> createState() => _PosSessionScreenState();
}

class _PosSessionScreenState extends ConsumerState<PosSessionScreen> {
  final _fondsCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _fondsCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.rouge : AppColors.vertVif,
    ));
  }

  Future<void> _ouvrir() async {
    final montant = double.tryParse(_fondsCtrl.text.trim().replaceAll(',', '.'));
    if (montant == null || montant < 0) {
      _showSnack('Montant du fonds d\'ouverture invalide.', isError: true);
      return;
    }
    setState(() => _loading = true);
    final erreur = await ref.read(posSessionProvider.notifier).ouvrir(montant);
    setState(() => _loading = false);
    if (!mounted) return;
    if (erreur == null) {
      _fondsCtrl.clear();
      _showSnack('Session ouverte avec succès !');
    } else {
      _showSnack(erreur, isError: true);
    }
  }

  Future<void> _fermer() async {
    final montant = double.tryParse(_fondsCtrl.text.trim().replaceAll(',', '.'));
    if (montant == null || montant < 0) {
      _showSnack('Montant du fonds de fermeture invalide.', isError: true);
      return;
    }
    setState(() => _loading = true);
    final resultat = await ref.read(posSessionProvider.notifier).fermer(montant);
    setState(() => _loading = false);
    if (!mounted) return;

    if (resultat['error'] != null) {
      _showSnack(resultat['error'].toString(), isError: true);
      return;
    }
    _fondsCtrl.clear();
    _afficherRecap(resultat);
  }

  void _afficherRecap(Map<String, dynamic> recap) {
    final ecart = double.tryParse('${recap['ecart_caisse'] ?? 0}') ?? 0;
    final totalVentes = double.tryParse('${recap['total_ventes'] ?? 0}') ?? 0;
    final nbVentes = recap['nb_ventes'] ?? 0;
    final repartition = recap['repartition_paiement'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Session fermée — récapitulatif'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecapRow(label: 'Nombre de ventes', value: '$nbVentes'),
            _RecapRow(label: 'Total des ventes', value: FormatUtils.htg(totalVentes)),
            if (repartition != null)
              ...repartition.entries.map(
                (e) => _RecapRow(label: e.key, value: FormatUtils.htg(e.value)),
              ),
            const Divider(height: 20),
            _RecapRow(
              label: 'Écart de caisse',
              value: FormatUtils.htg(ecart),
              valueColor: ecart == 0 ? AppColors.vertVif : AppColors.rouge,
              bold: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(posSessionProvider);
    final isOnline      = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Session de caisse')),
      body: sessionState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.vertVif)),
        error:   (e, _) => Center(child: Text('Erreur : $e')),
        data: (session) {
          final ouverte = session != null && session.statut == 'ouverte';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isOnline)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.orange),
                    ),
                    child: const Text(
                      'Hors ligne — l\'ouverture et la fermeture de session '
                      'nécessitent une connexion internet. Les ventes restent '
                      'possibles si une session est déjà ouverte.',
                      style: TextStyle(fontSize: 13, color: AppColors.orange),
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ouverte ? AppColors.vertFonce : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ouverte ? 'Session en cours' : 'Aucune session ouverte',
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          color: ouverte ? Colors.white : AppColors.vertFonce,
                        ),
                      ),
                      if (ouverte) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Ouverte depuis ${FormatUtils.heure(session.ouverteLe)} — '
                          'fonds : ${FormatUtils.htg(session.fondsOuverture)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  ouverte ? 'Fermer la session' : 'Ouvrir une session',
                  style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.vertFonce,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _fondsCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: ouverte ? 'Fonds de fermeture' : 'Fonds d\'ouverture',
                    suffixText: 'HTG',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: (!isOnline || _loading) ? null : (ouverte ? _fermer : _ouvrir),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ouverte ? AppColors.rouge : AppColors.vertFonce,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          ouverte ? 'Fermer la session' : 'Ouvrir la session',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  const _RecapRow({required this.label, required this.value, this.valueColor, this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grisTexte)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.noir,
          ),
        ),
      ],
    ),
  );
}
