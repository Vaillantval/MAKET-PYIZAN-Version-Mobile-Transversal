import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/wallet_code_paiement.dart';
import '../providers/wallet_provider.dart';

/// Écran "Payer au comptoir" — affiche un code à 6 chiffres à présenter
/// à l'opérateur POS, avec compte à rebours et régénération. ONLINE
/// UNIQUEMENT (le code est généré et vérifié côté serveur).
class WalletCodePaiementScreen extends ConsumerStatefulWidget {
  const WalletCodePaiementScreen({super.key});

  @override
  ConsumerState<WalletCodePaiementScreen> createState() =>
      _WalletCodePaiementScreenState();
}

class _WalletCodePaiementScreenState
    extends ConsumerState<WalletCodePaiementScreen> {
  WalletCodePaiement? _code;
  bool   _loading = false;
  String? _erreur;
  int    _secondesRestantes = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.microtask(_genererCode);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _genererCode() async {
    _timer?.cancel();
    setState(() {
      _loading = true;
      _erreur  = null;
    });
    try {
      final code = await ref.read(walletProvider.notifier).genererCodePaiement();
      if (!mounted) return;
      setState(() {
        _code = code;
        _secondesRestantes = code.expireDans;
        _loading = false;
      });
      _demarrerCompteARebours();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur  = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _demarrerCompteARebours() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondesRestantes <= 1) {
        setState(() => _secondesRestantes = 0);
        t.cancel();
        return;
      }
      setState(() => _secondesRestantes--);
    });
  }

  String get _mmss {
    final m = _secondesRestantes ~/ 60;
    final s = _secondesRestantes % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Payer au comptoir')),
      body: !isOnline
          ? _EtatHorsLigne(onRetry: _genererCode)
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: _loading
                    ? const CircularProgressIndicator(color: AppColors.vertVif)
                    : _erreur != null
                        ? _EtatErreur(message: _erreur!, onRetry: _genererCode)
                        : _code == null
                            ? const SizedBox.shrink()
                            : _ContenuCode(
                                code: _code!,
                                expire: _secondesRestantes == 0,
                                mmss: _mmss,
                                onRegenerer: _genererCode,
                              ),
              ),
            ),
    );
  }
}

class _ContenuCode extends StatelessWidget {
  final WalletCodePaiement code;
  final bool expire;
  final String mmss;
  final VoidCallback onRegenerer;

  const _ContenuCode({
    required this.code,
    required this.expire,
    required this.mmss,
    required this.onRegenerer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Présentez ce code à l\'opérateur',
          style: TextStyle(fontSize: 15, color: AppColors.grisTexte),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
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
          child: Opacity(
            opacity: expire ? 0.35 : 1,
            child: Text(
              _espacer(code.code),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Icon(
          expire ? Icons.timer_off_outlined : Icons.timer_outlined,
          color: expire ? AppColors.rouge : AppColors.vertFonce,
        ),
        const SizedBox(height: 6),
        Text(
          expire ? 'Code expiré' : 'Expire dans $mmss',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: expire ? AppColors.rouge : AppColors.vertFonce,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet, size: 18, color: AppColors.vertFonce),
              const SizedBox(width: 8),
              Text(
                'Solde : ${FormatUtils.htg(code.solde)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: onRegenerer,
          icon: const Icon(Icons.refresh),
          label: const Text('Régénérer le code'),
          style: ElevatedButton.styleFrom(
            backgroundColor: expire ? AppColors.vertFonce : Colors.white,
            foregroundColor: expire ? Colors.white : AppColors.vertFonce,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: AppColors.vertFonce),
          ),
        ),
      ],
    );
  }

  String _espacer(String code) => code.split('').join(' ');
}

class _EtatHorsLigne extends StatelessWidget {
  final VoidCallback onRetry;
  const _EtatHorsLigne({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 56, color: AppColors.orange),
          const SizedBox(height: 20),
          const Text(
            'Génération du code indisponible hors ligne',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.vertFonce),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Le paiement au comptoir nécessite une connexion internet.',
            style: TextStyle(fontSize: 13, color: AppColors.grisTexte),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertFonce),
          ),
        ],
      ),
    ),
  );
}

class _EtatErreur extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _EtatErreur({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.error_outline, size: 48, color: AppColors.rouge),
      const SizedBox(height: 12),
      Text(message, style: const TextStyle(color: AppColors.rouge), textAlign: TextAlign.center),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertFonce),
        child: const Text('Réessayer'),
      ),
    ],
  );
}
