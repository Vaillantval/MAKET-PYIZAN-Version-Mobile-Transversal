import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/role_utils.dart';
import '../../../models/wallet.dart';
import '../../../providers/entreprise_provider.dart';
import '../providers/wallet_provider.dart';
import '../../../shared/ui/ui.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Toujours re-fetcher à l'ouverture — jamais de cache faisant autorité
    Future.microtask(() async {
      await _reprendreRechargeEnCours();
      ref.read(walletProvider.notifier).rafraichir();
      ref.read(walletTransactionsProvider.notifier).charger();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(walletTransactionsProvider.notifier).chargerPlus();
    }
  }

  /// Si l'app a été tuée pendant la redirection MonCash/NatCash (avant
  /// que le callback de retour du WebView ne s'exécute), on reprend
  /// ici la vérification de la recharge laissée en attente.
  Future<void> _reprendreRechargeEnCours() async {
    final storage    = ref.read(localStorageProvider);
    final rechargeId = storage.getInt(AppConstants.keyWalletRechargeEnCours);
    if (rechargeId == null) return;

    final confirme = await ref
        .read(walletProvider.notifier)
        .verifierRechargeAvecRetry(rechargeId);
    await storage.remove(AppConstants.keyWalletRechargeEnCours);

    if (!mounted) return;
    if (confirme) {
      afficherMessage(context, 'Votre recharge a bien été confirmée');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline      = ref.watch(isOnlineProvider);
    final walletState   = ref.watch(walletProvider);
    final transState    = ref.watch(walletTransactionsProvider);
    final base          = walletBasePath(context);
    // Portefeuille d'entreprise : seuls le solde, l'historique et les
    // retraits s'y rapportent (recharges, bons, paiement au comptoir et
    // cashback restent sur le portefeuille personnel côté backend).
    final enEntreprise  = estEspaceEntreprise(context);
    final entreprise    = enEntreprise ? ref.watch(entrepriseActiveProvider) : null;
    final wallet         = walletState.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(entreprise != null ? entreprise.nom : 'Portefeuille'),
        actions: [
          if (isOnline)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Rafraîchir',
              onPressed: () {
                ref.read(walletProvider.notifier).rafraichir();
                ref.read(walletTransactionsProvider.notifier).charger();
              },
            ),
        ],
      ),
      body: isOnline
          ? RefreshIndicator(
              color: AppColors.vertFonce,
              onRefresh: () async {
                await ref.read(walletProvider.notifier).rafraichir();
                await ref.read(walletTransactionsProvider.notifier).charger();
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // ── Carte de solde ───────────────────────────
                  SliverToBoxAdapter(
                    child: _CarteWallet(walletState: walletState),
                  ),

                  // ── Boutons d'action ─────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Row(
                        mainAxisAlignment: enEntreprise
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.spaceBetween,
                        children: [
                          for (final action in [
                          if (!enEntreprise)
                            _ActionButton(
                              icon:  Icons.add_rounded,
                              label: 'Recharger',
                              principal: true,
                              onTap: () => context.push('$base/wallet/recharge'),
                            ),
                          _ActionButton(
                            icon:  Icons.arrow_outward_rounded,
                            label: 'Retirer',
                            onTap: () => context.push('$base/wallet/retrait'),
                          ),
                          if (!enEntreprise) ...[
                            _ActionButton(
                              icon:  Icons.qr_code_2_rounded,
                              label: 'Payer',
                              onTap: () =>
                                  context.push('$base/wallet/code-paiement'),
                            ),
                            _ActionButton(
                              icon:  Icons.card_giftcard_outlined,
                              label: 'Bons',
                              onTap: () => context.push('$base/wallet/bons'),
                            ),
                          ],
                          ]) Flexible(child: action),
                        ],
                      ),
                    ),
                  ),

                  // ── Cashback ──────────────────────────────────
                  if (!enEntreprise && wallet?.cashback?.actif == true)
                    SliverToBoxAdapter(
                      child: _CarteCashback(cashback: wallet!.cashback!),
                    ),

                  // ── Parrainage ────────────────────────────────
                  if (wallet?.parrainage != null)
                    SliverToBoxAdapter(
                      child: _CarteParrainage(parrainage: wallet!.parrainage!),
                    ),

                  // ── En-tête transactions ─────────────────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TitreSection('Historique'),
                    ),
                  ),

                  // ── Liste transactions ───────────────────────
                  transState.when(
                    loading: () => const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => SliverToBoxAdapter(
                      child: _ErreurWidget(message: e.toString()),
                    ),
                    data: (transactions) {
                      if (transactions.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: _EtatVide(),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: GroupeLignes([
                            for (final t in transactions)
                              _TransactionTile(transaction: t),
                          ]),
                        ),
                      );
                    },
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: ref.read(walletTransactionsProvider.notifier).chargementPlus
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),

                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 24),
                  ),
                ],
              ),
            )
          : EcranWalletHorsLigne(
              onRetry: () {
                ref.read(walletProvider.notifier).rafraichir();
                ref.read(walletTransactionsProvider.notifier).charger();
              },
            ),
    );
  }
}

// ── Carte solde ────────────────────────────────────────────────────────

class _CarteWallet extends StatelessWidget {
  final AsyncValue<dynamic> walletState;
  const _CarteWallet({required this.walletState});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.noir,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40, top: -50,
            child: Container(
              width: 170, height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.vertFonce.withValues(alpha: 0.55),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solde disponible',
                  style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
                ),
                const SizedBox(height: 8),
                walletState.when(
                  loading: () => const SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => const Text(
                    '— HTG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  data: (wallet) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    // Le solde défile quand il change (push « argent
                    // reçu », recharge confirmée)
                    child: CompteurAnime(
                      valeur: wallet.solde,
                      format: FormatUtils.htg,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Row(
                  children: [
                    Text(
                      'MAKET PEYIZAN',
                      style: TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 11,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.contactless_outlined,
                        color: Color(0x99FFFFFF), size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cashback ────────────────────────────────────────────────────────────

class _CarteCashback extends StatelessWidget {
  final WalletCashback cashback;
  const _CarteCashback({required this.cashback});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: Surface(
      couleur: AppColors.vertTeinte,
      bordure: false,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const TuileIcone(Icons.savings_outlined,
              couleur: AppColors.vertVif, taille: 38, plein: true),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cashback.plafond > 0
                  ? 'Cashback de ${cashback.taux.toStringAsFixed(0)} % sur vos achats '
                    '(plafond ${FormatUtils.htg(cashback.plafond)})'
                  : 'Cashback de ${cashback.taux.toStringAsFixed(0)} % sur vos achats',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Parrainage ──────────────────────────────────────────────────────────

class _CarteParrainage extends StatelessWidget {
  final WalletParrainage parrainage;
  const _CarteParrainage({required this.parrainage});

  String get _lien => 'https://maketpeyizan.ht/inscription/?parrain=${parrainage.code}';

  void _partager() {
    Share.share(
      'Rejoins Makèt Peyizan avec mon code de parrainage ${parrainage.code} '
      'et profite d\'un bonus sur ton portefeuille : $_lien',
      subject: 'Invitation Makèt Peyizan',
    );
  }

  void _copier(BuildContext context) {
    Clipboard.setData(ClipboardData(text: parrainage.code));
    afficherMessage(context, 'Code copié');
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
    child: Surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Parrainez vos proches',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          parrainage.tauxBonus > 0
              ? 'Gagnez un bonus de ${parrainage.tauxBonus.toStringAsFixed(0)} % sur chaque filleul.'
              : 'Partagez votre code avec vos proches.',
          style: const TextStyle(fontSize: 12, color: AppColors.grisTexte),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.grisClair,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(parrainage.code,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: 'Copier le code',
              onPressed: () => _copier(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _partager,
          icon: const Icon(Icons.ios_share_rounded, size: 18),
          label: const Text('Partager mon lien'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 46),
          ),
        ),
      ],
    ),
    ),
  );
}

// ── Bouton d'action ────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     principal;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.principal = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 80,
    child: Column(
      children: [
        BoutonRond(icon, onTap: onTap, plein: principal, taille: 54),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ── Tuile transaction ──────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final dynamic transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final montant  = (transaction.montant as double);
    final isCredit = montant >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          TuileIcone(
            isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
            couleur: isCredit ? AppColors.vertVif : AppColors.grisTexte,
            taille: 38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.typeDisplay.isNotEmpty
                      ? transaction.typeDisplay
                      : transaction.type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  FormatUtils.date(transaction.createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.grisTexte),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : ''}${FormatUtils.htg(montant)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isCredit ? AppColors.vertVif : AppColors.noir,
            ),
          ),
        ],
      ),
    );
  }
}

// ── État vide ──────────────────────────────────────────────────────────

class _EtatVide extends StatelessWidget {
  const _EtatVide();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        Icon(Icons.receipt_long_outlined,
            size: 54, color: AppColors.grisTexte),
        SizedBox(height: 12),
        Text(
          'Aucune transaction pour le moment.',
          style: TextStyle(color: AppColors.grisTexte, fontSize: 14),
        ),
      ],
    ),
  );
}

// ── Erreur ─────────────────────────────────────────────────────────────

class _ErreurWidget extends StatelessWidget {
  final String message;
  const _ErreurWidget({required this.message});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Text(
      'Erreur : $message',
      style: const TextStyle(color: AppColors.rouge, fontSize: 13),
      textAlign: TextAlign.center,
    ),
  );
}

// ── Écran hors ligne ───────────────────────────────────────────────────

class EcranWalletHorsLigne extends StatelessWidget {
  final VoidCallback onRetry;
  const EcranWalletHorsLigne({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.blanc,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: AppColors.grisTexte,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Portefeuille indisponible hors ligne',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Le portefeuille est disponible uniquement lorsque vous êtes connecté à internet. '
            'Vérifiez votre connexion et réessayez.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grisTexte,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    ),
  );
}
