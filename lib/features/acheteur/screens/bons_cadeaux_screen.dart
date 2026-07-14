import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/wallet_provider.dart';
import 'wallet_screen.dart' show EcranWalletHorsLigne;

class BonsCadeauxScreen extends ConsumerStatefulWidget {
  const BonsCadeauxScreen({super.key});

  @override
  ConsumerState<BonsCadeauxScreen> createState() => _BonsCadeauxScreenState();
}

class _BonsCadeauxScreenState
    extends ConsumerState<BonsCadeauxScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(bonsAchetesProvider.notifier).charger();
      ref.read(bonsRecusProvider.notifier).charger();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Bons cadeaux'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          indicatorColor: AppColors.jaune,
          tabs: const [
            Tab(text: '🎁 Mes bons'),
            Tab(text: '📥 Bons reçus'),
          ],
        ),
      ),
      floatingActionButton: isOnline
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'encaisser',
                  onPressed: () => _dialogEncaisser(context),
                  backgroundColor: AppColors.vertVif,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Encaisser un bon'),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: 'offrir',
                  onPressed: () => _dialogOffrir(context),
                  backgroundColor: AppColors.violet,
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Offrir un bon'),
                ),
              ],
            )
          : null,
      body: isOnline
          ? TabBarView(
              controller: _tabs,
              children: [
                _OngletBonsAchetes(),
                _OngletBonsRecus(),
              ],
            )
          : EcranWalletHorsLigne(onRetry: () => setState(() {})),
    );
  }

  // ── Dialogue encaisser ─────────────────────────────────────────────

  void _dialogEncaisser(BuildContext context) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encaisser un bon'),
        content: TextField(
          controller: codeCtrl,
          decoration: const InputDecoration(
            hintText: 'Ex : BON-XXXX-YYYY',
            labelText: 'Code du bon',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertVif),
            onPressed: () async {
              final code = codeCtrl.text.trim();
              if (code.isEmpty) return;
              Navigator.pop(ctx);
              final ok = await ref
                  .read(walletProvider.notifier)
                  .encaisserBon(code);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? '✅ Bon encaissé — solde mis à jour !'
                    : '❌ Code invalide ou déjà utilisé'),
                backgroundColor: ok ? AppColors.vertVif : AppColors.rouge,
              ));
              if (ok) {
                ref.read(bonsRecusProvider.notifier).charger();
              }
            },
            child: const Text('Encaisser'),
          ),
        ],
      ),
    );
  }

  // ── Dialogue offrir ────────────────────────────────────────────────

  void _dialogOffrir(BuildContext context) {
    final montantCtrl = TextEditingController();
    final emailCtrl   = TextEditingController();
    bool loading      = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState2) => AlertDialog(
          title: const Text('Offrir un bon cadeau'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: montantCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Ex : 500',
                  labelText: 'Montant (HTG)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'destinataire@email.com',
                  labelText: 'Email du destinataire (optionnel)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet),
              onPressed: loading
                  ? null
                  : () async {
                      final montant = double.tryParse(
                          montantCtrl.text.trim().replaceAll(',', '.'));
                      if (montant == null || montant < 1) return;
                      setState2(() => loading = true);
                      final ok = await ref
                          .read(walletProvider.notifier)
                          .acheterBon(
                            montant: montant,
                            emailDestinataire:
                                emailCtrl.text.trim().isNotEmpty
                                    ? emailCtrl.text.trim()
                                    : null,
                          );
                      if (!ctx2.mounted) return;
                      Navigator.pop(ctx2);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? '✅ Bon cadeau créé et envoyé !'
                            : '❌ Erreur lors de la création du bon'),
                        backgroundColor:
                            ok ? AppColors.vertVif : AppColors.rouge,
                      ));
                      if (ok) {
                        ref.read(bonsAchetesProvider.notifier).charger();
                      }
                    },
              child: loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('🎁 Offrir'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Onglet bons achetés ────────────────────────────────────────────────

class _OngletBonsAchetes extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(bonsAchetesProvider);
    final notifier = ref.read(bonsAchetesProvider.notifier);
    return state.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.vertVif)),
      error: (e, _) => Center(
          child: Text('Erreur : $e',
              style: const TextStyle(color: AppColors.rouge))),
      data: (bons) => bons.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.card_giftcard_outlined,
                      size: 54, color: AppColors.grisTexte),
                  SizedBox(height: 12),
                  Text('Aucun bon acheté.',
                      style: TextStyle(color: AppColors.grisTexte)),
                ],
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                  notifier.chargerPlus();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: bons.length + (notifier.hasPlus ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i >= bons.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: notifier.chargementPlus
                            ? const CircularProgressIndicator(
                                color: AppColors.vertVif, strokeWidth: 2)
                            : const SizedBox.shrink(),
                      ),
                    );
                  }
                  return _BonTile(bon: bons[i]);
                },
              ),
            ),
    );
  }
}

// ── Onglet bons reçus ─────────────────────────────────────────────────

class _OngletBonsRecus extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(bonsRecusProvider);
    final notifier = ref.read(bonsRecusProvider.notifier);
    return state.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.vertVif)),
      error: (e, _) => Center(
          child: Text('Erreur : $e',
              style: const TextStyle(color: AppColors.rouge))),
      data: (bons) => bons.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 54, color: AppColors.grisTexte),
                  SizedBox(height: 12),
                  Text('Aucun bon reçu.',
                      style: TextStyle(color: AppColors.grisTexte)),
                ],
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                  notifier.chargerPlus();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: bons.length + (notifier.hasPlus ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i >= bons.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: notifier.chargementPlus
                            ? const CircularProgressIndicator(
                                color: AppColors.vertVif, strokeWidth: 2)
                            : const SizedBox.shrink(),
                      ),
                    );
                  }
                  return _BonTile(bon: bons[i], showEncaisser: true);
                },
              ),
            ),
    );
  }
}

// ── Tuile bon ─────────────────────────────────────────────────────────

class _BonTile extends StatefulWidget {
  final dynamic bon;
  final bool    showEncaisser;
  const _BonTile({required this.bon, this.showEncaisser = false});

  @override
  State<_BonTile> createState() => _BonTileState();
}

class _BonTileState extends State<_BonTile> {
  bool _codeVisible = false;

  Color _couleurStatut(String s) {
    switch (s) {
      case 'utilise': return AppColors.grisTexte;
      case 'expire':  return AppColors.rouge;
      default:        return AppColors.vertVif;
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleur = _couleurStatut(widget.bon.statut as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          // En-tête : montant + statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                FormatUtils.htg(widget.bon.montant),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.vertFonce,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.bon.statutDisplay.isNotEmpty
                      ? widget.bon.statutDisplay
                      : widget.bon.statut,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: couleur,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Code (masquable)
          Row(
            children: [
              Expanded(
                child: Text(
                  _codeVisible
                      ? widget.bon.code as String
                      : '••••••••••••',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    color: _codeVisible
                        ? AppColors.noir
                        : AppColors.grisTexte,
                  ),
                ),
              ),
              // Bouton afficher/masquer
              IconButton(
                icon: Icon(
                  _codeVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.grisTexte,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _codeVisible = !_codeVisible),
              ),
              // Bouton copier
              IconButton(
                icon: const Icon(Icons.copy, size: 20,
                    color: AppColors.vertVif),
                tooltip: 'Copier le code',
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.bon.code as String));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code copié dans le presse-papiers'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),

          // Date
          Text(
            'Créé le ${FormatUtils.date(widget.bon.createdAt as String)}',
            style: const TextStyle(
                fontSize: 11, color: AppColors.grisTexte),
          ),

          // Email destinataire si présent
          if ((widget.bon.emailDestinataire as String?) != null &&
              (widget.bon.emailDestinataire as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Pour : ${widget.bon.emailDestinataire}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.grisTexte),
              ),
            ),

          // Offert par
          if ((widget.bon.offertPar as String?) != null &&
              (widget.bon.offertPar as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Offert par : ${widget.bon.offertPar}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.grisTexte),
              ),
            ),
        ],
      ),
    );
  }
}
