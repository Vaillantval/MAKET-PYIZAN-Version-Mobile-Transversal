import '../../../core/sons/sons_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/ui/ui.dart';
import '../providers/pos_session_provider.dart';
import '../providers/pos_vente_provider.dart';

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

  void _showSnack(String msg, {bool isError = false}) =>
      afficherMessage(context, msg, succes: !isError);

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
      SonsApp.jouer(SonApp.sessionOuverte);
      _fondsCtrl.clear();
      _showSnack('Session ouverte');
    } else if (erreur.contains('déjà ouverte')) {
      // Session restée ouverte côté serveur mais inconnue de ce terminal
      // (réinstallation, données effacées, autre terminal) : sans moyen de
      // la clôturer ici, l'opérateur restait bloqué.
      await _proposerFermetureSessionServeur(erreur);
    } else {
      _showSnack(erreur, isError: true);
    }
  }

  Future<void> _proposerFermetureSessionServeur(String message) async {
    final comptageCtrl = TextEditingController();
    final comptage = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Session déjà ouverte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            const Text('Pour la clôturer, saisissez le montant compté dans la caisse :'),
            TextField(
              controller:   comptageCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration:   const InputDecoration(labelText: 'Comptage de clôture (HTG)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx,
                double.tryParse(comptageCtrl.text.trim().replaceAll(',', '.'))),
            child: const Text('Clôturer'),
          ),
        ],
      ),
    );
    comptageCtrl.dispose();
    if (comptage == null || comptage < 0 || !mounted) return;

    setState(() => _loading = true);
    final resultat = await ref.read(posSessionProvider.notifier).fermer(comptage);
    setState(() => _loading = false);
    if (!mounted) return;
    if (resultat['error'] != null) {
      _showSnack(resultat['error'].toString(), isError: true);
      return;
    }
    _afficherRecap(resultat);
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
    SonsApp.jouer(SonApp.sessionCloturee);
    final ecart = double.tryParse('${recap['ecart_caisse'] ?? 0}') ?? 0;
    final totalVentes = double.tryParse('${recap['total_ventes'] ?? 0}') ?? 0;
    final nbVentes = recap['nb_ventes'] ?? 0;
    // Structure backend : {methode: {nb, montant}}
    final parMethode = recap['par_methode'] as Map<String, dynamic>?;

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
            const SizedBox(height: 8),
            if (parMethode != null && parMethode.isNotEmpty)
              ...parMethode.entries.map((e) {
                final detail  = e.value as Map<String, dynamic>? ?? {};
                final nb      = detail['nb'] ?? 0;
                final montant = double.tryParse('${detail['montant'] ?? 0}') ?? 0;
                return _RecapRow(
                  label: '${e.key.toUpperCase()} ($nb)',
                  value: FormatUtils.htg(montant),
                );
              })
            else
              const _RecapRow(
                label: 'Répartition',
                value: 'Répartition indisponible',
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
    final isOnline     = ref.watch(isOnlineProvider);
    // Ventes du jour (historique local + serveur) pour les indicateurs
    final ventes = ref.watch(posHistoriqueProvider).valueOrNull ?? const [];
    final chiffre = ventes.fold<double>(0, (t, v) => t + v.montantTotal);
    final enAttente = ventes.where((v) => v.syncStatus == 'enAttente').length;

    return Scaffold(
      body: SafeArea(
        child: sessionState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:   (e, _) => ErreurChargement(e),
          data: (session) {
            final ouverte = session != null && session.statut == 'ouverte';

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                const EnTeteEcran('Session', padding: EdgeInsets.fromLTRB(4, 12, 0, 12)),

                if (!isOnline) ...[
                  const BandeauAlerte(
                    icone: Icons.cloud_off_outlined,
                    couleur: AppColors.orange,
                    texte: 'Hors ligne : ouvrir ou fermer une session demande '
                        'internet. Les ventes restent possibles si une session '
                        'est déjà ouverte.',
                  ),
                  const SizedBox(height: 4),
                ],

                // ── État de la session ──────────────────────────────
                // La carte se retourne à l'ouverture et à la clôture
                CarteRetournable(
                  child: Container(
                  key: ValueKey(ouverte),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  decoration: BoxDecoration(
                    color: ouverte ? AppColors.noir : AppColors.blanc,
                    borderRadius: BorderRadius.circular(22),
                    border: ouverte ? null : Border.all(color: AppColors.grisBord),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ouverte ? 'Session en cours' : 'Caisse fermée',
                              style: TextStyle(
                                fontSize: 13,
                                color: ouverte ? const Color(0xB3FFFFFF) : AppColors.grisTexte,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ouverte
                                  ? 'Depuis ${FormatUtils.heure(session.ouverteLe)}'
                                  : 'Aucune session ouverte',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: ouverte ? AppColors.blanc : AppColors.noir,
                              ),
                            ),
                            if (ouverte) ...[
                              const SizedBox(height: 6),
                              Text('Fonds d\'ouverture ${FormatUtils.htg(session.fondsOuverture)}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xB3FFFFFF))),
                            ],
                          ],
                        ),
                      ),
                      TuileIcone(
                        ouverte ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                        couleur: ouverte ? AppColors.vertVif : AppColors.grisTexte,
                        taille: 48,
                        plein: ouverte,
                      ),
                    ],
                  ),
                ),
                ),

                // ── Indicateurs du jour ─────────────────────────────
                const TitreSection("Aujourd'hui"),
                GrilleIndicateurs([
                  CarteIndicateur(
                    libelle: 'Ventes',
                    valeur: '${ventes.length}',
                    precision: enAttente > 0 ? '$enAttente à synchroniser' : 'synchronisées',
                    icone: Icons.receipt_long_outlined,
                    couleur: AppColors.bleu,
                  ),
                  CarteIndicateur(
                    libelle: "Chiffre d'affaires",
                    valeur: FormatUtils.htg(chiffre),
                    icone: Icons.payments_outlined,
                    couleur: AppColors.vertVif,
                  ),
                ], hauteur: 112),

                // ── Ouvrir / fermer ─────────────────────────────────
                TitreSection(ouverte ? 'Fermer la session' : 'Ouvrir une session'),
                Surface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        ouverte
                            ? 'Comptez l\'argent de la caisse et saisissez le montant : '
                              'l\'écart avec les ventes est calculé automatiquement.'
                            : 'Saisissez le fonds de caisse de départ (monnaie disponible).',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.grisTexte, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _fondsCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: ouverte ? 'Montant compté' : 'Fonds d\'ouverture',
                          suffixText: 'HTG',
                          prefixIcon: const Icon(Icons.payments_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: (!isOnline || _loading) ? null : (ouverte ? _fermer : _ouvrir),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ouverte ? AppColors.rouge : AppColors.noir,
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 22, width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(ouverte ? 'Fermer la session' : 'Ouvrir la session'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
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
