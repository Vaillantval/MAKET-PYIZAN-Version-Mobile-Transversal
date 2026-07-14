import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/role_utils.dart';
import '../../../models/wallet.dart';
import '../../../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import 'wallet_screen.dart' show EcranWalletHorsLigne;

class WalletRechargeScreen extends ConsumerStatefulWidget {
  const WalletRechargeScreen({super.key});

  @override
  ConsumerState<WalletRechargeScreen> createState() =>
      _WalletRechargeScreenState();
}

class _WalletRechargeScreenState
    extends ConsumerState<WalletRechargeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  // Onglet online
  final _montantCtrl   = TextEditingController();
  String _methodeLigne = 'moncash';
  bool   _loading      = false;

  // Onglet hors ligne
  final _montantHLCtrl = TextEditingController();
  XFile? _preuve;
  bool   _loadingHL    = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _montantCtrl.dispose();
    _montantHLCtrl.dispose();
    super.dispose();
  }

  // ── Recharge en ligne via Plopplop WebView ─────────────────────────

  Future<void> _initierRecharge() async {
    final montantStr = _montantCtrl.text.trim();
    final montant    = double.tryParse(montantStr.replaceAll(',', '.'));

    if (montant == null || montant < 1) {
      _showSnack('Montant minimum : 1 HTG', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await ref.read(walletProvider.notifier).initierRecharge(
        montant: montant,
        methode: _methodeLigne,
      );
      if (!mounted) return;

      final redirectUrl = data['redirect_url'] as String? ??
          data['url'] as String?;
      final rechargeId  = data['id'] as int?;

      if (redirectUrl == null) {
        _showSnack('URL de paiement manquante', isError: true);
        return;
      }

      // Persister AVANT la redirection : si l'app est tuée pendant le
      // passage par l'appli MonCash/NatCash (fréquent sur Android), on
      // pourra reprendre la vérification au retour sur l'écran wallet.
      if (rechargeId != null) {
        await ref.read(localStorageProvider).setInt(
          AppConstants.keyWalletRechargeEnCours,
          rechargeId,
        );
      }
      if (!mounted) return;

      // Ouvrir WebView Plopplop
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PlopplopWebView(
            url:        redirectUrl,
            rechargeId: rechargeId,
            onRetour: (success) async {
              var confirme = false;
              if (success && rechargeId != null) {
                confirme = await ref
                    .read(walletProvider.notifier)
                    .verifierRechargeAvecRetry(rechargeId);
              }
              await ref.read(localStorageProvider)
                  .remove(AppConstants.keyWalletRechargeEnCours);
              if (mounted) {
                _showSnack(
                  confirme
                      ? '✅ Recharge effectuée avec succès !'
                      : success
                          ? '⏳ Paiement reçu — confirmation en cours, '
                            'vérifiez votre solde dans quelques instants.'
                          : '❌ Recharge annulée ou échouée.',
                  isError: !success,
                );
                if (success) {
                  context.go('${walletBasePath(ref.read(authProvider).user?.role)}/wallet');
                }
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (mounted) _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Recharge hors ligne ────────────────────────────────────────────

  Future<void> _choisirPreuve() async {
    final picker = ImagePicker();
    final image  = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _preuve = image);
  }

  Future<void> _soumettreHorsLigne() async {
    final montantStr = _montantHLCtrl.text.trim();
    final montant    = double.tryParse(montantStr.replaceAll(',', '.'));

    if (montant == null || montant < 1) {
      _showSnack('Montant minimum : 1 HTG', isError: true);
      return;
    }
    if (_preuve == null) {
      _showSnack('Veuillez joindre une preuve de paiement', isError: true);
      return;
    }

    setState(() => _loadingHL = true);

    final ok = await ref.read(walletProvider.notifier).soumettreRechargeHorsLigne(
      montant: montant,
      preuve:  _preuve!,
    );

    setState(() => _loadingHL = false);

    if (!mounted) return;
    _showSnack(
      ok
          ? '✅ Demande soumise — en attente de validation'
          : '❌ Erreur lors de la soumission',
      isError: !ok,
    );
    if (ok) {
      context.go('${walletBasePath(ref.read(authProvider).user?.role)}/wallet');
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? AppColors.rouge : AppColors.vertVif,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final depot     = ref.watch(walletProvider).valueOrNull?.depotHorsLigne;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharger le portefeuille'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          indicatorColor: AppColors.jaune,
          tabs: const [
            Tab(text: '💳 En ligne'),
            Tab(text: '🏦 Hors ligne'),
          ],
        ),
      ),
      body: isOnline
          ? TabBarView(
              controller: _tabs,
              children: [
                _OnglLigne(
                  montantCtrl:   _montantCtrl,
                  methode:       _methodeLigne,
                  loading:       _loading,
                  onMethodeChanged: (v) =>
                      setState(() => _methodeLigne = v!),
                  onRecharger:   _initierRecharge,
                ),
                _OngletHorsLigne(
                  montantCtrl:   _montantHLCtrl,
                  preuve:        _preuve,
                  loading:       _loadingHL,
                  depot:         depot,
                  onChoisirPreuve:  _choisirPreuve,
                  onSoumettre:   _soumettreHorsLigne,
                ),
              ],
            )
          : EcranWalletHorsLigne(
              onRetry: () => setState(() {}),
            ),
    );
  }
}

// ── Onglet recharge en ligne ───────────────────────────────────────────

class _OnglLigne extends StatelessWidget {
  final TextEditingController montantCtrl;
  final String methode;
  final bool   loading;
  final ValueChanged<String?> onMethodeChanged;
  final VoidCallback onRecharger;

  const _OnglLigne({
    required this.montantCtrl,
    required this.methode,
    required this.loading,
    required this.onMethodeChanged,
    required this.onRecharger,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Montant à recharger',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.vertFonce,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller:  montantCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText:    'Ex : 500',
            suffixText:  'HTG',
            filled:      true,
            fillColor:   Colors.white,
            border:      OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Méthode de paiement',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.vertFonce,
          ),
        ),
        const SizedBox(height: 8),
        for (final m in [
          ('moncash', '📱 MonCash'),
          ('natcash', '💳 NatCash'),
        ])
          RadioListTile<String>(
            value:      m.$1,
            groupValue: methode,
            title:      Text(m.$2),
            activeColor: AppColors.vertVif,
            onChanged:  onMethodeChanged,
            contentPadding: EdgeInsets.zero,
          ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: loading ? null : onRecharger,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.vertFonce,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('💳 Recharger maintenant',
                  style: TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
}

// ── Onglet recharge hors ligne ─────────────────────────────────────────

class _OngletHorsLigne extends StatelessWidget {
  final TextEditingController montantCtrl;
  final XFile? preuve;
  final bool   loading;
  final WalletDepotHorsLigne? depot;
  final VoidCallback onChoisirPreuve;
  final VoidCallback onSoumettre;

  const _OngletHorsLigne({
    required this.montantCtrl,
    required this.preuve,
    required this.loading,
    this.depot,
    required this.onChoisirPreuve,
    required this.onSoumettre,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (depot?.numeroMoncash != null || depot?.numeroNatcash != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.vertVif.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Numéros de dépôt',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.vertFonce)),
                const SizedBox(height: 8),
                if (depot?.numeroMoncash != null)
                  Text('📱 MonCash : ${depot!.numeroMoncash}',
                      style: const TextStyle(fontSize: 13)),
                if (depot?.numeroNatcash != null)
                  Text('💳 NatCash : ${depot!.numeroNatcash}',
                      style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.jauneClair,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.jaune),
          ),
          child: const Text(
            '📋 Effectuez un virement ou dépôt bancaire, puis soumettez '
            'votre preuve ici. L\'équipe validera sous 24–48h.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Montant déposé',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.vertFonce,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller:  montantCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText:   'Ex : 2 000',
            suffixText: 'HTG',
            filled:     true,
            fillColor:  Colors.white,
            border:     OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Preuve de paiement',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.vertFonce,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onChoisirPreuve,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.vertVif.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: preuve == null
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file,
                            size: 36, color: AppColors.grisTexte),
                        SizedBox(height: 8),
                        Text('Touchez pour choisir une photo',
                          style: TextStyle(color: AppColors.grisTexte)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.vertVif),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            preuve!.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: loading ? null : onSoumettre,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('📤 Soumettre la demande',
                  style: TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
}

// ── WebView Plopplop ───────────────────────────────────────────────────

class _PlopplopWebView extends StatefulWidget {
  final String url;
  final int? rechargeId;
  final void Function(bool success) onRetour;

  const _PlopplopWebView({
    required this.url,
    required this.onRetour,
    this.rechargeId,
  });

  @override
  State<_PlopplopWebView> createState() => _PlopplopWebViewState();
}

class _PlopplopWebViewState extends State<_PlopplopWebView> {
  late final WebViewController _ctrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted:  (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onNavigationRequest: (req) {
          if (req.url.contains('/wallet/recharge/retour/') ||
              req.url.contains('success') ||
              req.url.contains('cancel')) {
            final success = req.url.contains('success');
            Navigator.pop(context);
            widget.onRetour(success);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Paiement'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Annuler la recharge ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuer'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  widget.onRetour(false);
                },
                child: const Text('Annuler',
                    style: TextStyle(color: AppColors.rouge)),
              ),
            ],
          ),
        ),
      ),
    ),
    body: Stack(
      children: [
        WebViewWidget(controller: _ctrl),
        if (_loading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.vertVif),
          ),
      ],
    ),
  );
}
