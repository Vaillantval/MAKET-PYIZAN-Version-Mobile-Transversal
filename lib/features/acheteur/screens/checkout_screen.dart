import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/commande_provider.dart';
import '../providers/adresse_provider.dart';
import '../providers/panier_provider.dart';
import '../../../shared/widgets/htg_text.dart';

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

  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _commander() async {
    setState(() => _isLoading = true);

    final result = await ref.read(commandesProvider.notifier).passer(
      methodePaiement: _methodePaiement,
      modeLivraison:   _modeLivraison,
      adresseId:       _adresseId,
      notes:           _notes,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result?['success'] == true) {
      final data = result!['data'] as Map<String, dynamic>;

      // MonCash → ouvrir WebView
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['error']?.toString() ?? 'Erreur'),
          backgroundColor: AppColors.rouge,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adressesState = ref.watch(adressesProvider);
    final panierState   = ref.watch(panierProvider);

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
                    ('cash',      '💵 Espèces'),
                    ('moncash',   '📱 MonCash'),
                    ('hors_ligne','🏦 Virement / Dépôt'),
                  ])
                    RadioListTile<String>(
                      value:      m.$1,
                      groupValue: _methodePaiement,
                      title:      Text(m.$2),
                      activeColor: AppColors.vertVif,
                      onChanged: (v) =>
                          setState(() => _methodePaiement = v!),
                      contentPadding: EdgeInsets.zero,
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
                  : Text(
                      _methodePaiement == 'moncash'
                          ? '📱 Payer avec MonCash'
                          : '✅ Confirmer la commande',
                      style: const TextStyle(fontSize: 16),
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
