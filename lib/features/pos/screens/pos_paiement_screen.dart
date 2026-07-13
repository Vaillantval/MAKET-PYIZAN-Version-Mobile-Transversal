import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/printing/pos_printer_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/pos_sale.dart';
import '../../../providers/auth_provider.dart';
import '../providers/pos_device_provider.dart';
import '../providers/pos_exceptions.dart';
import '../providers/pos_panier_provider.dart';
import '../providers/pos_vente_provider.dart';
import '../providers/pos_wallet_provider.dart';
import 'pos_vente_screen.dart' show HtgLabel;

class PosPaiementScreen extends ConsumerStatefulWidget {
  const PosPaiementScreen({super.key});

  @override
  ConsumerState<PosPaiementScreen> createState() => _PosPaiementScreenState();
}

class _PosPaiementScreenState extends ConsumerState<PosPaiementScreen> {
  String _methode = 'cash'; // cash | moncash | natcash | wallet

  // Cash pur
  final _recuCashCtrl = TextEditingController();

  // MonCash / NatCash déclaratif
  final _referenceCtrl = TextEditingController();

  // Wallet
  String _codeSaisi = '';
  bool _verifying = false;
  PosClientWallet? _clientWallet;
  String? _erreurWallet;
  String _methodeComplement = 'cash';
  final _recuComplementCtrl = TextEditingController();

  bool _loading = false;
  PosSale? _venteConfirmee;
  String? _clientNomVente;
  double? _montantRecuVente;

  @override
  void dispose() {
    _recuCashCtrl.dispose();
    _referenceCtrl.dispose();
    _recuComplementCtrl.dispose();
    super.dispose();
  }

  double get _total => ref.read(posPanierProvider.notifier).total;

  // ── Soumission commune ──────────────────────────────────────────────

  Future<void> _soumettre({
    required String methodePaiement,
    double montantWallet = 0,
    String? codePaiement,
    String? referenceTransaction,
    double? montantRecuPourTicket,
  }) async {
    setState(() => _loading = true);

    final panier = ref.read(posPanierProvider);
    final total  = _total;
    final clientNomSnapshot = _clientWallet?.nom;

    try {
      final sale = await ref.read(posHistoriqueProvider.notifier).vendre(
        items: panier,
        montantTotal: total,
        methodePaiement: methodePaiement,
        montantWallet: montantWallet,
        codePaiement: codePaiement,
        referenceTransaction: referenceTransaction,
      );
      ref.read(posPanierProvider.notifier).vider();
      if (!mounted) return;
      setState(() {
        _venteConfirmee     = sale;
        _clientNomVente     = clientNomSnapshot;
        _montantRecuVente   = montantRecuPourTicket;
        _loading            = false;
      });
    } on PosVenteException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (e.code == 'CODE_INVALIDE') {
        setState(() {
          _erreurWallet  = e.message;
          _clientWallet  = null;
          _codeSaisi     = '';
        });
      } else if (e.code == 'SOLDE_INSUFFISANT') {
        setState(() => _erreurWallet = e.message);
        if (_codeSaisi.length == 6) await _verifierCode(silencieux: true);
      } else if (e.code == 'OFFLINE') {
        _proposerBasculeCash(e.message);
      } else {
        setState(() => _erreurWallet = e.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
        backgroundColor: AppColors.rouge,
      ));
    }
  }

  void _proposerBasculeCash(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connexion perdue'),
        content: Text(
          '$message\n\nVoulez-vous basculer sur un paiement en espèces '
          'pour le montant total ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertFonce),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _methode      = 'cash';
                _clientWallet = null;
                _erreurWallet = null;
                _codeSaisi    = '';
              });
            },
            child: const Text('Basculer en espèces'),
          ),
        ],
      ),
    );
  }

  // ── Wallet : code ────────────────────────────────────────────────────

  void _onDigitTap(String d) {
    if (_codeSaisi.length >= 6) return;
    setState(() {
      _codeSaisi += d;
      _erreurWallet = null;
    });
    if (_codeSaisi.length == 6) _verifierCode();
  }

  void _onBackspace() {
    if (_codeSaisi.isEmpty) return;
    setState(() => _codeSaisi = _codeSaisi.substring(0, _codeSaisi.length - 1));
  }

  Future<void> _verifierCode({bool silencieux = false}) async {
    setState(() {
      _verifying = true;
      if (!silencieux) _erreurWallet = null;
    });
    try {
      final client = await ref.read(posWalletProvider).verifierCode(_codeSaisi);
      if (!mounted) return;
      setState(() {
        _clientWallet = client;
        _verifying    = false;
        _erreurWallet = null;
      });
    } on PosVenteException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying    = false;
        _erreurWallet = e.message;
        _clientWallet = null;
        _codeSaisi    = '';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verifying    = false;
        _erreurWallet = 'Erreur réseau — impossible de vérifier le code.';
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_venteConfirmee != null) {
      return _EcranConfirmation(
        sale: _venteConfirmee!,
        clientNom: _clientNomVente,
        montantRecu: _montantRecuVente,
        onNouvelleVente: () => context.go('/pos/vente'),
      );
    }

    final isOnline = ref.watch(isOnlineProvider);
    final total = _total;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Paiement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total à payer',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(FormatUtils.htg(total),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.vertFonce)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Sélecteur de méthode ─────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MethodeChip(
                  label: '💵 Cash',
                  selected: _methode == 'cash',
                  onTap: () => setState(() => _methode = 'cash'),
                ),
                _MethodeChip(
                  label: '📱 MonCash',
                  selected: _methode == 'moncash',
                  onTap: () => setState(() => _methode = 'moncash'),
                ),
                _MethodeChip(
                  label: '💳 NatCash',
                  selected: _methode == 'natcash',
                  onTap: () => setState(() => _methode = 'natcash'),
                ),
                _MethodeChip(
                  label: '👛 Wallet',
                  selected: _methode == 'wallet',
                  disabled: !isOnline,
                  onTap: () => setState(() => _methode = 'wallet'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_methode == 'cash')
              _SectionCash(
                total: total,
                recuCtrl: _recuCashCtrl,
                loading: _loading,
                onConfirmer: () => _soumettre(
                  methodePaiement: 'cash',
                  montantRecuPourTicket:
                      double.tryParse(_recuCashCtrl.text.trim().replaceAll(',', '.')),
                ),
              )
            else if (_methode == 'moncash' || _methode == 'natcash')
              _SectionDeclaratif(
                methode: _methode,
                total: total,
                referenceCtrl: _referenceCtrl,
                loading: _loading,
                onConfirmer: () => _soumettre(
                  methodePaiement: _methode,
                  referenceTransaction: _referenceCtrl.text.trim(),
                ),
              )
            else
              _SectionWallet(
                isOnline: isOnline,
                total: total,
                codeSaisi: _codeSaisi,
                verifying: _verifying,
                client: _clientWallet,
                erreur: _erreurWallet,
                loading: _loading,
                methodeComplement: _methodeComplement,
                recuComplementCtrl: _recuComplementCtrl,
                onDigit: _onDigitTap,
                onBackspace: _onBackspace,
                onChangerMethodeComplement: (m) => setState(() => _methodeComplement = m),
                onAutreMoyen: () => setState(() {
                  _methode      = 'cash';
                  _clientWallet = null;
                  _codeSaisi    = '';
                  _erreurWallet = null;
                }),
                onConfirmerIntegral: () => _soumettre(
                  methodePaiement: 'wallet',
                  montantWallet: total,
                  codePaiement: _codeSaisi,
                ),
                onConfirmerHybride: () => _soumettre(
                  methodePaiement: _methodeComplement,
                  montantWallet: _clientWallet!.solde,
                  codePaiement: _codeSaisi,
                  referenceTransaction:
                      _methodeComplement != 'cash' ? _referenceCtrl.text.trim() : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Chip méthode ──────────────────────────────────────────────────────

class _MethodeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;
  const _MethodeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: disabled ? null : (_) => onTap(),
    selectedColor: AppColors.vertVif,
    disabledColor: Colors.white,
    labelStyle: TextStyle(
      color: disabled
          ? AppColors.grisTexte
          : (selected ? Colors.white : AppColors.noir),
      fontWeight: FontWeight.w600,
    ),
  );
}

// ── Section CASH ──────────────────────────────────────────────────────

class _SectionCash extends StatefulWidget {
  final double total;
  final TextEditingController recuCtrl;
  final bool loading;
  final VoidCallback onConfirmer;
  const _SectionCash({
    required this.total,
    required this.recuCtrl,
    required this.loading,
    required this.onConfirmer,
  });

  @override
  State<_SectionCash> createState() => _SectionCashState();
}

class _SectionCashState extends State<_SectionCash> {
  @override
  Widget build(BuildContext context) {
    final recu = double.tryParse(widget.recuCtrl.text.trim().replaceAll(',', '.'));
    final monnaie = recu != null ? recu - widget.total : null;

    return _Carte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paiement en espèces', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          TextField(
            controller: widget.recuCtrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Montant reçu',
              suffixText: 'HTG',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          if (monnaie != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Monnaie à rendre', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  FormatUtils.htg(monnaie < 0 ? 0 : monnaie),
                  style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16,
                    color: monnaie < 0 ? AppColors.rouge : AppColors.vertFonce,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          _BoutonConfirmer(
            loading: widget.loading,
            enabled: recu != null && recu >= widget.total,
            onPressed: widget.onConfirmer,
          ),
        ],
      ),
    );
  }
}

// ── Section MonCash / NatCash déclaratif ────────────────────────────────

class _SectionDeclaratif extends StatelessWidget {
  final String methode;
  final double total;
  final TextEditingController referenceCtrl;
  final bool loading;
  final VoidCallback onConfirmer;
  const _SectionDeclaratif({
    required this.methode,
    required this.total,
    required this.referenceCtrl,
    required this.loading,
    required this.onConfirmer,
  });

  @override
  Widget build(BuildContext context) => _Carte(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paiement ${methode == 'moncash' ? 'MonCash' : 'NatCash'}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 8),
        const Text(
          'Le client règle directement sur son téléphone. Confirmez '
          'une fois le paiement reçu et vérifié.',
          style: TextStyle(fontSize: 13, color: AppColors.grisTexte),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: referenceCtrl,
          decoration: InputDecoration(
            labelText: 'Référence de transaction (optionnel)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 16),
        _BoutonConfirmer(
          loading: loading,
          enabled: true,
          label: 'Confirmer le paiement reçu',
          onPressed: onConfirmer,
        ),
      ],
    ),
  );
}

// ── Section Wallet ───────────────────────────────────────────────────

class _SectionWallet extends StatelessWidget {
  final bool isOnline;
  final double total;
  final String codeSaisi;
  final bool verifying;
  final PosClientWallet? client;
  final String? erreur;
  final bool loading;
  final String methodeComplement;
  final TextEditingController recuComplementCtrl;
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final void Function(String) onChangerMethodeComplement;
  final VoidCallback onAutreMoyen;
  final VoidCallback onConfirmerIntegral;
  final VoidCallback onConfirmerHybride;

  const _SectionWallet({
    required this.isOnline,
    required this.total,
    required this.codeSaisi,
    required this.verifying,
    required this.client,
    required this.erreur,
    required this.loading,
    required this.methodeComplement,
    required this.recuComplementCtrl,
    required this.onDigit,
    required this.onBackspace,
    required this.onChangerMethodeComplement,
    required this.onAutreMoyen,
    required this.onConfirmerIntegral,
    required this.onConfirmerHybride,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOnline) {
      return const _Carte(
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.orange),
            SizedBox(height: 10),
            Text(
              'Le paiement par portefeuille nécessite une connexion internet.',
              style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (client == null) {
      return _Carte(
        child: Column(
          children: [
            const Text('Code de paiement du client',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) => _CaseCode(
                digit: i < codeSaisi.length ? codeSaisi[i] : null,
              )),
            ),
            const SizedBox(height: 12),
            if (verifying)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(color: AppColors.vertVif),
              ),
            if (erreur != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(erreur!,
                    style: const TextStyle(color: AppColors.rouge, fontSize: 13),
                    textAlign: TextAlign.center),
              ),
            const SizedBox(height: 8),
            _PaveNumerique(onDigit: onDigit, onBackspace: onBackspace),
          ],
        ),
      );
    }

    final solde = client!.solde;
    final couvreTout = solde >= total;
    final reste = couvreTout ? 0.0 : (total - solde);

    return _Carte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_circle, color: AppColors.vertFonce),
              const SizedBox(width: 8),
              Expanded(
                child: Text(client!.nom,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              Text('Solde : ${FormatUtils.htg(solde)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.vertFonce)),
            ],
          ),
          const SizedBox(height: 16),

          if (solde <= 0) ...[
            const Text(
              'Solde insuffisant pour un paiement wallet.',
              style: TextStyle(color: AppColors.rouge, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onAutreMoyen, child: const Text('Choisir un autre moyen de paiement')),
          ] else if (couvreTout) ...[
            _BoutonConfirmer(
              loading: loading,
              enabled: true,
              label: 'Payer ${FormatUtils.htg(total)} par wallet',
              onPressed: onConfirmerIntegral,
            ),
          ] else ...[
            Text(
              'Paiement hybride : Wallet ${FormatUtils.htg(solde)} + '
              'reste ${FormatUtils.htg(reste)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Cash'),
                  selected: methodeComplement == 'cash',
                  onSelected: (_) => onChangerMethodeComplement('cash'),
                ),
                ChoiceChip(
                  label: const Text('MonCash'),
                  selected: methodeComplement == 'moncash',
                  onSelected: (_) => onChangerMethodeComplement('moncash'),
                ),
                ChoiceChip(
                  label: const Text('NatCash'),
                  selected: methodeComplement == 'natcash',
                  onSelected: (_) => onChangerMethodeComplement('natcash'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (methodeComplement == 'cash')
              _RenduMonnaieComplement(reste: reste, controller: recuComplementCtrl)
            else
              Text(
                'Le client règle $reste HTG via '
                '${methodeComplement == 'moncash' ? 'MonCash' : 'NatCash'} sur son '
                'téléphone. Confirmez une fois reçu.',
                style: const TextStyle(fontSize: 13, color: AppColors.grisTexte),
              ),
            const SizedBox(height: 16),
            _BoutonConfirmerHybride(
              loading: loading,
              methodeComplement: methodeComplement,
              reste: reste,
              recuComplementCtrl: recuComplementCtrl,
              onConfirmer: onConfirmerHybride,
            ),
          ],
        ],
      ),
    );
  }
}

class _RenduMonnaieComplement extends StatefulWidget {
  final double reste;
  final TextEditingController controller;
  const _RenduMonnaieComplement({required this.reste, required this.controller});

  @override
  State<_RenduMonnaieComplement> createState() => _RenduMonnaieComplementState();
}

class _RenduMonnaieComplementState extends State<_RenduMonnaieComplement> {
  @override
  Widget build(BuildContext context) {
    final recu = double.tryParse(widget.controller.text.trim().replaceAll(',', '.'));
    final monnaie = recu != null ? recu - widget.reste : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Montant reçu (complément cash)',
            suffixText: 'HTG',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (monnaie != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monnaie à rendre', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                FormatUtils.htg(monnaie < 0 ? 0 : monnaie),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: monnaie < 0 ? AppColors.rouge : AppColors.vertFonce,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BoutonConfirmerHybride extends StatelessWidget {
  final bool loading;
  final String methodeComplement;
  final double reste;
  final TextEditingController recuComplementCtrl;
  final VoidCallback onConfirmer;

  const _BoutonConfirmerHybride({
    required this.loading,
    required this.methodeComplement,
    required this.reste,
    required this.recuComplementCtrl,
    required this.onConfirmer,
  });

  @override
  Widget build(BuildContext context) {
    bool enabled = true;
    if (methodeComplement == 'cash') {
      final recu = double.tryParse(recuComplementCtrl.text.trim().replaceAll(',', '.'));
      enabled = recu != null && recu >= reste;
    }
    return _BoutonConfirmer(loading: loading, enabled: enabled, onPressed: onConfirmer);
  }
}

// ── Petits widgets partagés ──────────────────────────────────────────

class _Carte extends StatelessWidget {
  final Widget child;
  const _Carte({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
    ),
    child: child,
  );
}

class _BoutonConfirmer extends StatelessWidget {
  final bool loading;
  final bool enabled;
  final String label;
  final VoidCallback onPressed;
  const _BoutonConfirmer({
    required this.loading,
    required this.enabled,
    required this.onPressed,
    this.label = 'Confirmer',
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: (!enabled || loading) ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.vertFonce,
      minimumSize: const Size(double.infinity, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: loading
        ? const SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Text(label, style: const TextStyle(fontSize: 16)),
  );
}

class _CaseCode extends StatelessWidget {
  final String? digit;
  const _CaseCode({this.digit});

  @override
  Widget build(BuildContext context) => Container(
    width: 40, height: 48,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.grisClair,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: digit != null ? AppColors.vertFonce : Colors.transparent, width: 2),
    ),
    child: Text(
      digit ?? '',
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
    ),
  );
}

class _PaveNumerique extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  const _PaveNumerique({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    final touches = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.8,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: touches.map((t) {
        if (t.isEmpty) return const SizedBox.shrink();
        return Material(
          color: AppColors.grisClair,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: t == '⌫' ? onBackspace : () => onDigit(t),
            child: Center(
              child: t == '⌫'
                  ? const Icon(Icons.backspace_outlined, size: 20)
                  : Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Écran de confirmation post-vente ─────────────────────────────────

class _EcranConfirmation extends ConsumerStatefulWidget {
  final PosSale sale;
  final String? clientNom;
  final double? montantRecu;
  final VoidCallback onNouvelleVente;
  const _EcranConfirmation({
    required this.sale,
    this.clientNom,
    this.montantRecu,
    required this.onNouvelleVente,
  });

  @override
  ConsumerState<_EcranConfirmation> createState() => _EcranConfirmationState();
}

class _EcranConfirmationState extends ConsumerState<_EcranConfirmation> {
  bool _impressionEnCours = false;
  bool _autoImprimeTente  = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_tenterImpressionAuto);
  }

  Future<void> _tenterImpressionAuto() async {
    if (_autoImprimeTente) return;
    _autoImprimeTente = true;
    final auto  = ref.read(localStorageProvider).getBool(AppConstants.keyPosImpressionAuto);
    final dispo = ref.read(posPrinterProvider).disponible;
    if (auto && dispo) await _imprimer();
  }

  Future<void> _imprimer() async {
    if (!mounted) return;
    setState(() => _impressionEnCours = true);

    final user       = ref.read(authProvider).user;
    final deviceUid  = ref.read(posDeviceUidProvider);
    final nomComplet = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    final resultat = await ref.read(posPrinterProvider.notifier).imprimerRecu(
      widget.sale,
      nomOperateur: nomComplet.isNotEmpty ? nomComplet : (user?.username ?? 'Opérateur'),
      nomCaisse: deviceUid ?? 'POS',
      nomClient: widget.clientNom,
      montantRecu: widget.montantRecu,
    );

    if (!mounted) return;
    setState(() => _impressionEnCours = false);

    if (resultat.indisponible) return; // no-op silencieux

    if (!resultat.succes) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(resultat.erreur ?? 'Erreur d\'impression du reçu.'),
        backgroundColor: AppColors.rouge,
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: _imprimer,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;
    final hasWallet = sale.montantWallet > 0;
    final complement = sale.montantTotal - sale.montantWallet;
    final imprimanteDisponible = ref.watch(posPrinterProvider).disponible;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Vente confirmée'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 72, color: AppColors.vertVif),
            const SizedBox(height: 16),
            Text(
              sale.numeroVente != null ? 'Vente n° ${sale.numeroVente}' : 'Vente enregistrée',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.vertFonce),
              textAlign: TextAlign.center,
            ),
            if (sale.syncStatus == 'enAttente')
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'En attente de synchronisation',
                  style: TextStyle(color: AppColors.orange, fontSize: 13),
                ),
              ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                      HtgLabel(sale.montantTotal),
                    ],
                  ),
                  if (hasWallet) ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Portefeuille', style: TextStyle(color: AppColors.grisTexte)),
                        Text(FormatUtils.htg(sale.montantWallet)),
                      ],
                    ),
                    if (complement > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(sale.methodePaiement.toUpperCase(),
                                style: const TextStyle(color: AppColors.grisTexte)),
                            Text(FormatUtils.htg(complement)),
                          ],
                        ),
                      ),
                  ] else ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Méthode', style: TextStyle(color: AppColors.grisTexte)),
                        Text(sale.methodePaiement.toUpperCase()),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onNouvelleVente,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Nouvelle vente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertFonce,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (imprimanteDisponible) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _impressionEnCours ? null : _imprimer,
                icon: _impressionEnCours
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vertFonce),
                      )
                    : const Icon(Icons.print_outlined),
                label: const Text('Imprimer le reçu'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 54)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
