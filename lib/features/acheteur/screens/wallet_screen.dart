import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/wallet_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Toujours re-fetcher à l'ouverture — jamais de cache faisant autorité
    Future.microtask(() {
      ref.read(walletProvider.notifier).rafraichir();
      ref.read(walletTransactionsProvider.notifier).charger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline      = ref.watch(isOnlineProvider);
    final walletState   = ref.watch(walletProvider);
    final transState    = ref.watch(walletTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Mon Portefeuille'),
        actions: [
          if (isOnline)
            IconButton(
              icon: const Icon(Icons.refresh),
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
              color: AppColors.vertVif,
              onRefresh: () async {
                await ref.read(walletProvider.notifier).rafraichir();
                await ref.read(walletTransactionsProvider.notifier).charger();
              },
              child: CustomScrollView(
                slivers: [
                  // ── Carte de solde ───────────────────────────
                  SliverToBoxAdapter(
                    child: _CarteWallet(walletState: walletState),
                  ),

                  // ── Boutons d'action ─────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon:  Icons.add_circle_outline,
                                  label: 'Recharger',
                                  color: AppColors.vertVif,
                                  onTap: () =>
                                      context.push('/acheteur/wallet/recharge'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ActionButton(
                                  icon:  Icons.account_balance_wallet_outlined,
                                  label: 'Retirer',
                                  color: AppColors.orange,
                                  onTap: () =>
                                      context.push('/acheteur/wallet/retrait'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon:  Icons.card_giftcard,
                                  label: 'Bons cadeaux',
                                  color: AppColors.violet,
                                  onTap: () =>
                                      context.push('/acheteur/wallet/bons'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ActionButton(
                                  icon:  Icons.point_of_sale,
                                  label: 'Payer au comptoir',
                                  color: AppColors.bleu,
                                  onTap: () =>
                                      context.push('/acheteur/wallet/code-paiement'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── En-tête transactions ─────────────────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'Dernières transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.vertFonce,
                        ),
                      ),
                    ),
                  ),

                  // ── Liste transactions ───────────────────────
                  transState.when(
                    loading: () => const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.vertVif),
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
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _TransactionTile(
                            transaction: transactions[i],
                          ),
                          childCount: transactions.length,
                        ),
                      );
                    },
                  ),

                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 80),
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
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.vertFonce, Color(0xFF1E8449)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.vertFonce.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet,
                  color: Colors.white70, size: 18),
              SizedBox(width: 6),
              Text(
                'Solde disponible',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          walletState.when(
            loading: () => const SizedBox(
              height: 38,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            ),
            error: (_, __) => const Text(
              '— HTG',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
            data: (wallet) => Text(
              FormatUtils.htg(wallet.solde),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'Makèt Peyizan Wallet',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bouton d'action ────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
    final color    = isCredit ? AppColors.vertVif : AppColors.rouge;
    final icon     = isCredit
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          transaction.typeDisplay.isNotEmpty
              ? transaction.typeDisplay
              : transaction.type,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          FormatUtils.date(transaction.createdAt),
          style: const TextStyle(fontSize: 12, color: AppColors.grisTexte),
        ),
        trailing: Text(
          '${isCredit ? '+' : ''}${FormatUtils.htg(montant)}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: color,
          ),
        ),
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
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Portefeuille indisponible hors ligne',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.vertFonce,
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
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vertFonce,
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );
}
