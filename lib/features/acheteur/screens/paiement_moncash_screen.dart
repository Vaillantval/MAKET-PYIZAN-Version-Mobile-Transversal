import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/logo_paiement.dart';

class PaiementMoncashScreen extends StatefulWidget {
  final String redirectUrl;
  const PaiementMoncashScreen({required this.redirectUrl, super.key});

  @override
  State<PaiementMoncashScreen> createState() =>
      _PaiementMoncashScreenState();
}

class _PaiementMoncashScreenState
    extends State<PaiementMoncashScreen> {
  late final WebViewController _controller;
  bool _loading = true;

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
            // Détecter le retour MonCash
            if (req.url.contains('/commander/moncash/retour/') ||
                req.url.contains('success') ||
                req.url.contains('cancel')) {
              _onPaiementTermine(req.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  void _onPaiementTermine(String url) {
    final success = url.contains('success');
    context.go('/acheteur/commandes');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ Paiement MonCash effectué !'
              : '❌ Paiement annulé ou échoué.',
        ),
        backgroundColor:
            success ? AppColors.vertVif : AppColors.rouge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LogoPaiement('moncash', taille: 24),
          SizedBox(width: 10),
          Text('Paiement MonCash'),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Annuler le paiement ?'),
            content: const Text(
              'Votre commande a été créée. Vous pouvez la payer plus tard.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuer le paiement'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/acheteur/commandes');
                },
                child: const Text('Quitter',
                  style: TextStyle(color: AppColors.rouge)),
              ),
            ],
          ),
        ),
      ),
    ),
    body: Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.vertVif),
          ),
      ],
    ),
  );
}
