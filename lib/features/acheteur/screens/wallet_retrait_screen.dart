import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/wallet_provider.dart';
import '../../../shared/widgets/logo_paiement.dart';
import 'wallet_screen.dart' show EcranWalletHorsLigne;

class WalletRetraitScreen extends ConsumerStatefulWidget {
  const WalletRetraitScreen({super.key});

  @override
  ConsumerState<WalletRetraitScreen> createState() =>
      _WalletRetraitScreenState();
}

class _WalletRetraitScreenState
    extends ConsumerState<WalletRetraitScreen> {
  final _montantCtrl    = TextEditingController();
  final _telephoneCtrl  = TextEditingController();
  final _scrollController = ScrollController();
  String _canal         = 'moncash';
  bool   _loading       = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() =>
        ref.read(walletRetraitsProvider.notifier).charger());
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    _telephoneCtrl.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(walletRetraitsProvider.notifier).chargerPlus();
    }
  }

  Future<void> _demanderRetrait() async {
    final montantStr  = _montantCtrl.text.trim();
    final telephone   = _telephoneCtrl.text.trim();
    final montant     = double.tryParse(montantStr.replaceAll(',', '.'));

    if (montant == null || montant < 1) {
      _showSnack('Montant minimum : 1 HTG', isError: true);
      return;
    }
    if (telephone.isEmpty) {
      _showSnack('Veuillez saisir un numéro de téléphone', isError: true);
      return;
    }

    // Vérifier le solde disponible
    final solde = ref.read(walletProvider.notifier).solde;
    if (montant > solde) {
      _showSnack('Solde insuffisant (${FormatUtils.htg(solde)} disponible)',
          isError: true);
      return;
    }

    setState(() => _loading = true);

    final ok = await ref.read(walletProvider.notifier).demanderRetrait(
      montant:         montant,
      canal:           _canal,
      numeroTelephone: telephone,
    );

    setState(() => _loading = false);

    if (!mounted) return;
    _showSnack(
      ok
          ? '✅ Demande de retrait soumise avec succès'
          : '❌ Erreur lors de la demande de retrait',
      isError: !ok,
    );
    if (ok) {
      _montantCtrl.clear();
      _telephoneCtrl.clear();
      ref.read(walletRetraitsProvider.notifier).charger();
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.rouge : AppColors.vertVif,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isOnline    = ref.watch(isOnlineProvider);
    final retraitsState = ref.watch(walletRetraitsProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Retrait de fonds')),
      body: isOnline
          ? SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Solde disponible ──────────────────────────
                  Consumer(
                    builder: (_, ref, __) {
                      final wallet = ref.watch(walletProvider);
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.vertMenthe,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet,
                                color: AppColors.vertFonce),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Solde disponible',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.vertFonce)),
                                wallet.when(
                                  loading: () => const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.vertFonce)),
                                  error: (_, __) => const Text('—'),
                                  data: (w) => Text(
                                    FormatUtils.htg(w.solde),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.vertFonce,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Formulaire retrait ─────────────────────────
                  _Section(
                    titre: '💸 Montant à retirer',
                    child: TextField(
                      controller: _montantCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Ex : 500',
                        suffixText: 'HTG',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _Section(
                    titre: '📱 Canal de réception',
                    child: Column(
                      children: [
                        for (final c in [
                          ('moncash', 'MonCash'),
                          ('natcash', 'NatCash'),
                        ])
                          RadioListTile<String>(
                            value:      c.$1,
                            groupValue: _canal,
                            title: Row(
                              children: [
                                LogoPaiement(c.$1),
                                const SizedBox(width: 10),
                                Text(c.$2),
                              ],
                            ),
                            activeColor: AppColors.vertVif,
                            onChanged: (v) =>
                                setState(() => _canal = v!),
                            contentPadding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _Section(
                    titre: '📞 Numéro de téléphone',
                    child: TextField(
                      controller: _telephoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Ex : 509-3X-XX-XXXX',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _loading ? null : _demanderRetrait,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('💸 Demander un retrait',
                            style: TextStyle(fontSize: 16)),
                  ),

                  // ── Historique des retraits ────────────────────
                  const SizedBox(height: 28),
                  const Text(
                    'Historique des retraits',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.vertFonce,
                    ),
                  ),
                  const SizedBox(height: 12),
                  retraitsState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.vertVif)),
                    error: (_, __) => const Text('Erreur chargement'),
                    data: (retraits) => retraits.isEmpty
                        ? const Text(
                            'Aucun retrait effectué.',
                            style: TextStyle(
                                color: AppColors.grisTexte, fontSize: 13),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: retraits.length,
                            itemBuilder: (_, i) =>
                                _RetraitTile(retrait: retraits[i]),
                          ),
                  ),
                  if (ref.read(walletRetraitsProvider.notifier).chargementPlus)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.vertVif, strokeWidth: 2),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            )
          : EcranWalletHorsLigne(onRetry: () => setState(() {})),
    );
  }
}

// ── Tuile retrait ──────────────────────────────────────────────────────

class _RetraitTile extends StatelessWidget {
  final dynamic retrait;
  const _RetraitTile({required this.retrait});

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'approuve': return AppColors.vertVif;
      case 'rejete':   return AppColors.rouge;
      default:         return AppColors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleur = _couleurStatut(retrait.statut as String);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: couleur.withValues(alpha: 0.12),
          child: Icon(Icons.arrow_upward_rounded,
              color: couleur, size: 20),
        ),
        title: Text(
          '${retrait.canalDisplay.isNotEmpty ? retrait.canalDisplay : retrait.canal} — ${retrait.numeroTelephone}',
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          FormatUtils.date(retrait.createdAt as String),
          style: const TextStyle(
              fontSize: 12, color: AppColors.grisTexte),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              FormatUtils.htg(retrait.montant),
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                retrait.statutDisplay.isNotEmpty
                    ? retrait.statutDisplay
                    : retrait.statut,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: couleur),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section helper ─────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String titre;
  final Widget child;
  const _Section({required this.titre, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.vertFonce,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}
