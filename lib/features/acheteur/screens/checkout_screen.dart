import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/commande_provider.dart';
import '../providers/adresse_provider.dart';
import '../providers/panier_provider.dart';
import '../providers/wallet_provider.dart';
import '../../../shared/widgets/htg_text.dart';
import '../../../shared/widgets/logo_paiement.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _methodePaiement  = 'cash';
  String _modeLivraison    = 'domicile';
  int?   _adresseId;
  String _notes            = '';
  bool   _isLoading        = false;
  bool   _walletHybride    = false; // utiliser le solde en complément d'une autre méthode

  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _commander() async {
    // Le solde affiché n'est jamais faisant autorité — le backend tranche.
    if (_methodePaiement == 'wallet' &&
        !ref.read(isOnlineProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Le portefeuille est disponible uniquement en ligne.'),
        backgroundColor: AppColors.rouge,
      ));
      return;
    }

    setState(() => _isLoading = true);

    final result = await ref.read(commandesProvider.notifier).passer(
      methodePaiement: _methodePaiement,
      modeLivraison:   _modeLivraison,
      adresseId:       _adresseId,
      notes:           _notes,
    );

    if (!mounted) return;

    if (result?['success'] != true) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['error']?.toString() ?? 'Erreur'),
          backgroundColor: AppColors.rouge,
        ),
      );
      return;
    }

    final data   = result!['data'] as Map<String, dynamic>;
    final numero = data['numero_commande']?.toString();

    // ── Paiement wallet intégral ──────────────────────────────────
    if (_methodePaiement == 'wallet' && numero != null) {
      final payRes = await ref.read(walletProvider.notifier).payerCommande(numero);
      setState(() => _isLoading = false);
      if (!mounted) return;

      if (payRes['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Commande payée avec votre portefeuille !'),
          backgroundColor: AppColors.vertVif,
        ));
        context.go('/acheteur/commandes');
      } else {
        _gererEchecPaiementWallet(payRes['error']?.toString(), numero);
      }
      return;
    }

    // ── Paiement hybride : solde wallet + méthode principale ──────
    if (_walletHybride && numero != null) {
      final payRes = await ref.read(walletProvider.notifier).payerPartiel(numero);
      if (mounted && payRes['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Le paiement partiel via le portefeuille a échoué '
            '(${payRes['error']?.toString() ?? 'erreur inconnue'}). '
            'Le montant total reste à régler via ${_libelleMethode(_methodePaiement)}.',
          ),
          backgroundColor: AppColors.orange,
        ));
      }
    }

    setState(() => _isLoading = false);
    if (!mounted) return;

    // MonCash → ouvrir WebView (pour le solde restant si paiement hybride)
    if (_methodePaiement == 'moncash' &&
        data['redirect_url'] != null) {
      context.push(
        '/acheteur/paiement/moncash',
        extra: data['redirect_url'] as String,
      );
      return;
    }

    // Succès → aller aux commandes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data['message']?.toString() ??
            'Commande passée avec succès !'),
        backgroundColor: AppColors.vertVif,
      ),
    );
    context.go('/acheteur/commandes');
  }

  void _gererEchecPaiementWallet(String? error, String numero) {
    final soldeInsuffisant = (error ?? '').toUpperCase().contains('SOLDE_INSUFFISANT') ||
        (error ?? '').toLowerCase().contains('insuffisant');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        soldeInsuffisant
            ? 'Solde insuffisant pour régler cette commande (votre solde a peut-être changé). '
              'Votre commande a été créée — choisissez un autre moyen de paiement pour la régler.'
            : error ?? 'Erreur lors du paiement par portefeuille.',
      ),
      backgroundColor: AppColors.rouge,
    ));
    context.push('/acheteur/commande/$numero');
  }

  String _libelleMethode(String m) {
    switch (m) {
      case 'moncash':    return 'MonCash';
      case 'hors_ligne': return 'virement / dépôt';
      default:           return 'espèces';
    }
  }

  @override
  Widget build(BuildContext context) {
    final adressesState = ref.watch(adressesProvider);
    final panierState   = ref.watch(panierProvider);
    final walletState   = ref.watch(walletProvider);
    final isOnline       = ref.watch(isOnlineProvider);

    final total           = panierState.whenOrNull(data: (p) => p.total) ?? 0.0;
    final soldeWallet      = walletState.whenOrNull(data: (w) => w.solde) ?? 0.0;
    final walletActif      = walletState.whenOrNull(data: (w) => w.isActive) ?? false;
    final walletDisponible = isOnline && walletActif;
    final walletCouvreTout = walletDisponible && total > 0 && soldeWallet >= total;
    final walletPartiel    = walletDisponible && total > 0 &&
        soldeWallet > 0 && soldeWallet < total;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmer la commande')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Méthode de paiement ──────────────────────────
            _Section(
              titre: '💳 Méthode de paiement',
              child: Column(
                children: [
                  for (final m in [
                    ('cash',      'Espèces'),
                    ('moncash',   'MonCash'),
                    ('hors_ligne','Virement / Dépôt'),
                  ])
                    RadioListTile<String>(
                      value:      m.$1,
                      groupValue: _methodePaiement,
                      title: Row(
                        children: [
                          LogoPaiement(m.$1),
                          const SizedBox(width: 10),
                          Text(m.$2),
                        ],
                      ),
                      activeColor: AppColors.vertVif,
                      onChanged: (v) => setState(() {
                        _methodePaiement = v!;
                        _walletHybride   = false;
                      }),
                      contentPadding: EdgeInsets.zero,
                    ),

                  // ── Portefeuille (online + actif uniquement) ──
                  if (walletDisponible)
                    RadioListTile<String>(
                      value:      'wallet',
                      groupValue: _methodePaiement,
                      title: Row(
                        children: [
                          const LogoPaiement('wallet'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Portefeuille — solde : ${FormatUtils.htg(soldeWallet)}',
                              style: TextStyle(
                                color: walletCouvreTout ? null : AppColors.grisTexte,
                              ),
                            ),
                          ),
                        ],
                      ),
                      activeColor: AppColors.vertVif,
                      onChanged: walletCouvreTout
                          ? (v) => setState(() {
                                _methodePaiement = v!;
                                _walletHybride   = false;
                              })
                          : null,
                      contentPadding: EdgeInsets.zero,
                    ),
                  if (walletDisponible && soldeWallet == 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: Row(
                        children: [
                          const Text(
                            'Portefeuille vide.',
                            style: TextStyle(fontSize: 12, color: AppColors.grisTexte),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push('/acheteur/wallet/recharge'),
                            child: const Text('Recharger',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                  // ── Paiement hybride : solde partiel + méthode principale ──
                  if (walletPartiel && _methodePaiement != 'wallet')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: CheckboxListTile(
                        value: _walletHybride,
                        onChanged: (v) =>
                            setState(() => _walletHybride = v ?? false),
                        activeColor: AppColors.vertVif,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Utiliser mon solde (${FormatUtils.htg(soldeWallet)}) et payer '
                          'le reste (${FormatUtils.htg(total - soldeWallet)}) '
                          'en ${_libelleMethode(_methodePaiement)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Mode de livraison ────────────────────────────
            _Section(
              titre: '🚚 Mode de livraison',
              child: Column(
                children: [
                  for (final m in [
                    ('domicile', '🏠 Livraison à domicile'),
                    ('retrait',  '🌾 Retrait chez le producteur'),
                    ('collecte', '📦 Point de collecte'),
                  ])
                    RadioListTile<String>(
                      value:      m.$1,
                      groupValue: _modeLivraison,
                      title:      Text(m.$2),
                      activeColor: AppColors.vertVif,
                      onChanged: (v) =>
                          setState(() => _modeLivraison = v!),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Adresse de livraison ─────────────────────────
            if (_modeLivraison == 'domicile')
              _Section(
                titre: '📍 Adresse de livraison',
                child: adressesState.when(
                  loading: () => const CircularProgressIndicator(),
                  error:   (_, __) => const Text('Erreur chargement'),
                  data: (adresses) {
                    if (adresses.isEmpty) {
                      return Column(
                        children: [
                          const Text('Aucune adresse enregistrée.'),
                          TextButton(
                            onPressed: () =>
                                context.push('/acheteur/adresses'),
                            child: const Text('Ajouter une adresse'),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: adresses.map((a) => RadioListTile<int>(
                        value:      a.id,
                        groupValue: _adresseId ?? adresses.first.id,
                        title:      Text('${a.rue}, ${a.commune}'),
                        subtitle:   Text(a.departement),
                        activeColor: AppColors.vertVif,
                        onChanged: (v) =>
                            setState(() => _adresseId = v),
                        contentPadding: EdgeInsets.zero,
                      )).toList(),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // ── Notes ────────────────────────────────────────
            _Section(
              titre: '📝 Notes (optionnel)',
              child: TextField(
                controller: _notesCtrl,
                maxLines:   3,
                decoration: const InputDecoration(
                  hintText: 'Ex: Livrer avant midi, appeler avant...',
                ),
                onChanged: (v) => _notes = v,
              ),
            ),
            const SizedBox(height: 16),

            // ── Récapitulatif ─────────────────────────────────
            _Section(
              titre: '🧾 Récapitulatif',
              child: panierState.whenOrNull(
                data: (p) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${p.nbArticles} article(s)'),
                        HtgText(p.total),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                        HtgText(p.total, fontSize: 20),
                      ],
                    ),
                  ],
                ),
              ) ?? const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // ── Bouton commander ──────────────────────────────
            ElevatedButton(
              onPressed: _isLoading ? null : _commander,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertFonce,
                minimumSize:     const Size(double.infinity, 54),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_methodePaiement == 'wallet' ||
                            _methodePaiement == 'moncash') ...[
                          LogoPaiement(_methodePaiement, taille: 22),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          _methodePaiement == 'wallet'
                              ? 'Payer avec mon Portefeuille'
                              : _methodePaiement == 'moncash'
                                  ? 'Payer avec MonCash'
                                  : 'Confirmer la commande',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

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
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: AppColors.vertFonce,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
