import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Vignette carrée uniforme pour une méthode de paiement.
///
/// Toutes les méthodes occupent exactement la même boîte (taille x taille),
/// que la source soit une image officielle (cash, MonCash, NatCash, wallet)
/// ou une icône de repli (ex: virement/dépôt hors ligne) — ce qui garantit
/// un alignement propre dans les listes de sélection.
class LogoPaiement extends StatelessWidget {
  final String methode; // cash | moncash | natcash | wallet | hors_ligne
  final double taille;
  const LogoPaiement(this.methode, {this.taille = 28, super.key});

  static const _assets = {
    'cash':    'assets/images/cash.jpg',
    'moncash': 'assets/images/MC_button.png',
    'natcash': 'assets/images/natcash.png',
    'wallet':  'assets/images/wallet.png',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _assets[methode];
    return SizedBox(
      width:  taille,
      height: taille,
      child: asset != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(asset, fit: BoxFit.contain),
            )
          : Icon(
              Icons.account_balance_outlined,
              size: taille * 0.85,
              color: AppColors.vertFonce,
            ),
    );
  }
}
