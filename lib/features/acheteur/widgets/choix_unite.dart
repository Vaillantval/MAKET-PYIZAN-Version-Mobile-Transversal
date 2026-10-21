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

/// Choix de l'unité de vente (affiché seulement s'il y en a plusieurs).
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
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final o in options)
            _Option(
              option: o,
              actif: identical(o, valeur),
              disponible: o.maxPour(stockBase) > 0,
              onTap: () => onChanged(o),
            ),
        ],
      );
}

class _Option extends StatelessWidget {
  final OptionUnite option;
  final bool actif;
  final bool disponible;
  final VoidCallback onTap;
  const _Option({
    required this.option,
    required this.actif,
    required this.disponible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: actif ? AppColors.noir : AppColors.blanc,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: actif
              ? BorderSide.none
              : const BorderSide(color: AppColors.grisBord),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disponible ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(option.libelle,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: actif
                          ? AppColors.blanc
                          : disponible
                              ? AppColors.noir
                              : AppColors.grisLeger,
                    )),
                Text(FormatUtils.htg(option.prix),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: actif ? const Color(0xB3FFFFFF) : AppColors.grisTexte,
                    )),
              ],
            ),
          ),
        ),
      );
}
