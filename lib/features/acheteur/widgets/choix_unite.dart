import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/produit.dart';

/// Une unité dans laquelle un produit se vend : l'unité de base
/// (prix_unitaire, facteur 1) ou une entrée de prix_supplementaires.
class OptionUnite {
  final int?   id;       // null : unité de base, id inconnu
  final String code;
  final String libelle;
  final double prix;
  final double facteur;  // unités de base par unité
  const OptionUnite({
    required this.id,
    required this.code,
    required this.libelle,
    required this.prix,
    required this.facteur,
  });

  /// Quantité maximale commandable pour un stock exprimé en unités de base.
  int maxPour(int stockBase) => facteur <= 0 ? 0 : (stockBase / facteur).floor();

  static List<OptionUnite> pour(Produit p) {
    final base = OptionUnite(
      id:      p.uniteVenteId,
      code:    p.uniteVente,
      libelle: p.uniteVenteLabel,
      prix:    double.tryParse(p.prixUnitaire) ?? 0,
      facteur: 1,
    );
    return [
      base,
      for (final s in p.prixSupplementaires)
        if (s['unite_id'] != null && s['unite_id'] != p.uniteVenteId)
          OptionUnite(
            id:      s['unite_id'] as int,
            code:    (s['unite_code'] ?? '').toString(),
            libelle: (s['unite_nom'] ?? s['unite_code'] ?? '').toString(),
            prix:    double.tryParse('${s['prix']}') ?? 0,
            facteur: double.tryParse('${s['facteur_conversion']}') ?? 1,
          ),
    ];
  }
}

/// Choix de l'unité de vente : une carte par unité (pastille de sélection,
/// libellé, équivalence en unité de base, prix et disponibilité). Affiché
/// seulement si le produit se vend dans plusieurs unités.
class ChoixUnite extends StatelessWidget {
  final List<OptionUnite> options;
  final OptionUnite valeur;
  final int stockBase;
  final ValueChanged<OptionUnite> onChanged;

  const ChoixUnite({
    required this.options,
    required this.valeur,
    required this.stockBase,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final base = options.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final o in options) ...[
          _Option(
            option: o,
            equivalence: identical(o, base)
                ? 'Unité de base'
                : '1 ${o.libelle} = ${_nombre(o.facteur)} ${base.libelle}',
            stock: o.maxPour(stockBase),
            actif: identical(o, valeur),
            onTap: () => onChanged(o),
          ),
          if (!identical(o, options.last)) const SizedBox(height: 8),
        ],
      ],
    );
  }

  static String _nombre(double v) => v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(3)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceAll('.', ',');
}

class _Option extends StatelessWidget {
  final OptionUnite option;
  final String? equivalence;
  final int stock;
  final bool actif;
  final VoidCallback? onTap;
  const _Option({
    required this.option,
    required this.equivalence,
    required this.stock,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disponible = stock > 0;
    final encre = disponible ? AppColors.noir : AppColors.grisLeger;
    return Semantics(
      selected: actif,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: actif ? AppColors.vertMenthe : AppColors.blanc,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: actif ? AppColors.vertFonce : AppColors.grisBord,
            width: actif ? 1.6 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disponible ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              children: [
                // Pastille de sélection
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: actif ? AppColors.vertFonce : AppColors.blanc,
                    border: Border.all(
                      color: actif ? AppColors.vertFonce : AppColors.grisLeger,
                      width: 1.6,
                    ),
                  ),
                  child: actif
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: AppColors.blanc)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.libelle,
                          style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: encre)),
                      if (equivalence != null) ...[
                        const SizedBox(height: 2),
                        Text(equivalence!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.grisTexte)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(FormatUtils.htg(option.prix),
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: encre)),
                    const SizedBox(height: 2),
                    Text(disponible ? '$stock dispo.' : 'Épuisé',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: disponible
                                ? AppColors.vertVif
                                : AppColors.rouge)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
