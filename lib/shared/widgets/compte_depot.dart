import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../ui/ui.dart';
import 'logo_paiement.dart';

/// Compte de virement / dépôt configuré par l'administration (banque,
/// MonCash, NatCash…), tel que renvoyé par /api/payments/instructions/ ou
/// `depot_hors_ligne.moyens` du portefeuille. Le numéro se copie d'un toucher.
class CompteDepotCarte extends StatelessWidget {
  final Map<String, dynamic> compte;
  const CompteDepotCarte(this.compte, {super.key});

  @override
  Widget build(BuildContext context) {
    final type    = '${compte['type'] ?? ''}';
    final logo    = compte['logo'] as String?;
    final numero  = '${compte['numero_compte'] ?? ''}';
    final details = [
      if ('${compte['nom_titulaire'] ?? ''}'.isNotEmpty) 'Titulaire : ${compte['nom_titulaire']}',
      if ('${compte['devise'] ?? ''}'.isNotEmpty) 'Devise : ${compte['devise']}',
    ].join(' · ');
    final instructions = '${compte['instructions'] ?? ''}';

    final Widget visuel = logo != null && logo.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(logo, width: 34, height: 34, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => LogoPaiement(type, taille: 34)),
          )
        : LogoPaiement(type == 'banque' || type == 'autre' ? 'hors_ligne' : type, taille: 34);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grisBord),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          visuel,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${compte['nom'] ?? compte['type_label'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (numero.isNotEmpty)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: numero));
                      afficherMessage(context, 'Numéro copié');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(numero,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4)),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy_rounded, size: 15, color: AppColors.grisTexte),
                        ],
                      ),
                    ),
                  ),
                if (details.isNotEmpty)
                  Text(details,
                      style: const TextStyle(fontSize: 12, color: AppColors.grisTexte)),
                if (instructions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(instructions,
                      style: const TextStyle(fontSize: 12.5, height: 1.35)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
