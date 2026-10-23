import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/sons/sons_app.dart';
import '../../../shared/ui/animations.dart';
import '../../../shared/widgets/logo_paiement.dart';
import '../providers/commande_provider.dart';

/// Paiement MonCash / NatCash via la passerelle Plopplop (page web).
///
/// Au retour de la passerelle (/commander/paiement/retour/, ancien
/// /commander/moncash/retour/), le résultat n'est jamais déduit de l'URL :
/// l'app demande au serveur de vérifier la transaction
/// (POST /api/payments/plopplop-verify/), qui confirme alors les commandes.
class PaiementMoncashScreen extends ConsumerStatefulWidget {
  final String redirectUrl;
  /// Numéro de la première commande du panier (référence du lot payé).
  final String? commandeRef;
  final String methode; // moncash | natcash
  const PaiementMoncashScreen({
    required this.redirectUrl,
    this.commandeRef,
    this.methode = 'moncash',
    super.key,
  });

  @override
  ConsumerState<PaiementMoncashScreen> createState() =>
      _PaiementMoncashScreenState();
}

enum _Etape { paiement, verification, paye, nonAbouti, inconnu }

class _PaiementMoncashScreenState extends ConsumerState<PaiementMoncashScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  _Etape _etape = _Etape.paiement;

  String get _nom => widget.methode == 'natcash' ? 'NatCash' : 'MonCash';

  static bool _estRetour(String url) =>
      url.contains('/commander/paiement/retour/') ||
      url.contains('/commander/moncash/retour/');

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted:  (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) {
            if (_estRetour(req.url)) {
              _verifier();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  Future<void> _verifier() async {
    if (_etape == _Etape.verification) return;
    final ref_ = widget.commandeRef;
    if (ref_ == null) {
      setState(() => _etape = _Etape.inconnu);
      return;
    }
    setState(() => _etape = _Etape.verification);
    final ok = await ref.read(commandesProvider.notifier).verifierPaiementMobile(ref_);
    if (!mounted) return;
    setState(() => _etape = switch (ok) {
          true  => _Etape.paye,
          false => _Etape.nonAbouti,
          null  => _Etape.inconnu,
        });
    SonsApp.jouer(ok == true ? SonApp.commande : SonApp.erreur);
  }

  void _quitter() => context.go('/acheteur/commandes');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LogoPaiement(widget.methode, taille: 24),
              const SizedBox(width: 10),
              Text('Paiement $_nom'),
            ],
          ),
          leading: _etape == _Etape.paiement
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (dialogue) => AlertDialog(
                      title: const Text('Annuler le paiement ?'),
                      content: const Text(
                          'Votre commande a été créée. Vous pourrez la payer '
                          'plus tard depuis « Mes commandes ».'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogue),
                          child: const Text('Continuer le paiement'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogue);
                            // Le client a peut-être payé avant de fermer
                            _verifier();
                          },
                          child: const Text('Quitter',
                              style: TextStyle(color: AppColors.rouge)),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _etape == _Etape.paiement
              ? Stack(
                  key: const ValueKey('web'),
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_loading)
                      const Center(
                        child: CircularProgressIndicator(color: AppColors.vertVif),
                      ),
                  ],
                )
              : _Resultat(
                  key: ValueKey(_etape),
                  etape: _etape,
                  nom: _nom,
                  onReessayer: _verifier,
                  onQuitter: _quitter,
                ),
        ),
      );
}

class _Resultat extends StatelessWidget {
  final _Etape etape;
  final String nom;
  final VoidCallback onReessayer;
  final VoidCallback onQuitter;
  const _Resultat({
    required this.etape,
    required this.nom,
    required this.onReessayer,
    required this.onQuitter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final (Widget visuel, String titre, String texte) = switch (etape) {
      _Etape.verification => (
          const SizedBox(
              width: 72, height: 72,
              child: CircularProgressIndicator(strokeWidth: 5)),
          'Vérification du paiement…',
          'Nous confirmons votre paiement $nom auprès de la passerelle.',
        ),
      _Etape.paye => (
          const CocheAnimee(taille: 96),
          'Paiement confirmé',
          'Merci ! Votre commande est confirmée.',
        ),
      _Etape.nonAbouti => (
          const Icon(Icons.cancel_rounded, size: 96, color: AppColors.rouge),
          'Paiement non abouti',
          'Le paiement $nom n\'a pas été validé. Votre commande reste '
              'en attente : vous pouvez la payer depuis « Mes commandes ».',
        ),
      _ => (
          const Icon(Icons.help_rounded, size: 96, color: AppColors.orange),
          'Vérification impossible',
          'Nous n\'avons pas pu confirmer le paiement pour l\'instant. '
              'S\'il a été débité, la commande sera mise à jour sous peu.',
        ),
    };
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          visuel,
          const SizedBox(height: 24),
          Text(titre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(texte,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grisTexte, height: 1.4)),
          const SizedBox(height: 28),
          if (etape != _Etape.verification) ...[
            ElevatedButton(
              onPressed: onQuitter,
              child: const Text('Voir mes commandes'),
            ),
            if (etape == _Etape.inconnu) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onReessayer,
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52)),
                child: const Text('Vérifier à nouveau'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
