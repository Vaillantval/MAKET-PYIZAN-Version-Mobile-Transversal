/// Composants d'interface communs à toute l'application.
///
/// Deux registres partagent ces briques :
/// - tableaux de bord (admin, entreprise, POS) : cartes teintées, tuiles
///   d'icône, pastilles de filtre, anneaux et barres ;
/// - espace acheteur : surfaces blanches, groupes de réglages, boutons
///   ronds, libellés discrets en petites capitales.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ── Surfaces ──────────────────────────────────────────────────────────

/// Carte blanche à bordure fine (aucune ombre).
class Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color couleur;
  final double rayon;
  final bool bordure;

  const Surface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.couleur = AppColors.blanc,
    this.rayon = 18,
    this.bordure = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: couleur,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayon),
          side: bordure
              ? const BorderSide(color: AppColors.grisBord)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      );
}

/// Icône posée dans un carré arrondi. [plein] : fond de la couleur et icône
/// blanche ; sinon fond teinté et icône colorée.
class TuileIcone extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final double taille;
  final bool plein;

  const TuileIcone(
    this.icone, {
    this.couleur = AppColors.vertFonce,
    this.taille = 40,
    this.plein = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: taille,
        height: taille,
        decoration: BoxDecoration(
          color: plein ? couleur : AppColors.teinte(couleur),
          borderRadius: BorderRadius.circular(taille * 0.3),
        ),
        child: Icon(icone,
            size: taille * 0.5, color: plein ? AppColors.blanc : couleur),
      );
}

/// Indicateur de tableau de bord sur fond pastel : libellé, grande valeur,
/// précision, et une tuile d'icône pleine à droite.
class CarteIndicateur extends StatelessWidget {
  final String libelle;
  final String valeur;
  final String? precision;
  final IconData icone;
  final Color couleur;
  final VoidCallback? onTap;
  final Widget? bas;

  const CarteIndicateur({
    required this.libelle,
    required this.valeur,
    required this.icone,
    this.precision,
    this.couleur = AppColors.vertVif,
    this.onTap,
    this.bas,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Surface(
        couleur: AppColors.teinte(couleur),
        bordure: false,
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(libelle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.grisTexte,
                          fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 6),
                TuileIcone(icone, couleur: couleur, taille: 34, plein: true),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(valeur,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.noir,
                          letterSpacing: -0.6)),
                ),
                if (precision != null)
                  Text(precision!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.grisTexte)),
                if (bas != null) ...[const SizedBox(height: 8), bas!],
              ],
            ),
          ],
        ),
      );
}

/// Grille d'indicateurs à deux colonnes (hauteur fixe par carte).
class GrilleIndicateurs extends StatelessWidget {
  final List<Widget> cartes;
  final double hauteur;
  const GrilleIndicateurs(this.cartes, {this.hauteur = 118, super.key});

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: cartes.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: hauteur,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (_, i) => cartes[i],
      );
}

// ── Titres ────────────────────────────────────────────────────────────

/// Titre de section avec action facultative (« Voir tout »).
class TitreSection extends StatelessWidget {
  final String titre;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const TitreSection(
    this.titre, {
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(0, 22, 0, 10),
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Row(
          children: [
            Expanded(
              child: Text(titre,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.noir,
                      letterSpacing: -0.2)),
            ),
            if (action != null)
              GestureDetector(
                onTap: onAction,
                child: Text(action!,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grisTexte)),
              ),
          ],
        ),
      );
}

/// Petit libellé en capitales espacées (« COMPTE », « RÉGLAGES »).
class Surtitre extends StatelessWidget {
  final String texte;
  final EdgeInsetsGeometry padding;
  const Surtitre(this.texte,
      {this.padding = const EdgeInsets.fromLTRB(4, 20, 4, 8), super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Text(texte.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.grisLeger,
                letterSpacing: 1.1)),
      );
}

/// En-tête d'écran principal : grand titre, sous-titre, actions à droite.
class EnTeteEcran extends StatelessWidget {
  final String titre;
  final String? surtitre;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  const EnTeteEcran(
    this.titre, {
    this.surtitre,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(20, 12, 16, 8),
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (surtitre != null)
                    Text(surtitre!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.grisTexte)),
                  Text(titre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.noir,
                          letterSpacing: -0.8)),
                ],
              ),
            ),
            for (final a in actions) ...[const SizedBox(width: 8), a],
          ],
        ),
      );
}

// ── Boutons ───────────────────────────────────────────────────────────

/// Bouton icône rond (fond blanc bordé, ou plein noir), avec pastille de
/// compteur facultative.
class BoutonRond extends StatelessWidget {
  final IconData icone;
  final VoidCallback? onTap;
  final bool plein;
  final int badge;
  final String? tooltip;
  final double taille;

  const BoutonRond(
    this.icone, {
    this.onTap,
    this.plein = false,
    this.badge = 0,
    this.tooltip,
    this.taille = 42,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bouton = Material(
      color: plein ? AppColors.noir : AppColors.blanc,
      shape: CircleBorder(
        side: plein
            ? BorderSide.none
            : const BorderSide(color: AppColors.grisBord),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: taille,
          height: taille,
          child: Icon(icone,
              size: 20, color: plein ? AppColors.blanc : AppColors.noir),
        ),
      ),
    );
    final avecBadge = badge > 0
        ? Badge(
            label: Text('$badge'),
            backgroundColor: AppColors.jaune,
            offset: const Offset(-2, 2),
            child: bouton,
          )
        : bouton;
    return tooltip == null
        ? avecBadge
        : Tooltip(message: tooltip!, child: avecBadge);
  }
}

// ── Filtres ───────────────────────────────────────────────────────────

/// Rangée de pastilles de filtre défilante (sélection unique).
class PastillesFiltre<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T valeur;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry padding;

  const PastillesFiltre({
    required this.options,
    required this.valeur,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    super.key,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: padding,
          itemCount: options.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final (v, libelle) = options[i];
            final actif = v == valeur;
            return Material(
              color: actif ? AppColors.noir : AppColors.blanc,
              shape: StadiumBorder(
                side: actif
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.grisBord),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(v),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(libelle,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                actif ? FontWeight.w600 : FontWeight.w500,
                            color: actif
                                ? AppColors.blanc
                                : AppColors.grisTexte)),
                  ),
                ),
              ),
            );
          },
        ),
      );
}

// ── Statuts ───────────────────────────────────────────────────────────

/// Petite étiquette de statut (fond teinté, texte coloré).
class PuceStatut extends StatelessWidget {
  final String libelle;
  final Color couleur;
  final IconData? icone;

  const PuceStatut(this.libelle,
      {this.couleur = AppColors.grisTexte, this.icone, super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.teinte(couleur),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 12, color: couleur),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(libelle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: couleur)),
            ),
          ],
        ),
      );
}

/// Couleur, libellé et icône d'un statut métier (commandes, entreprises,
/// collectes, paiements…).
class StyleStatut {
  final String libelle;
  final Color couleur;
  final IconData icone;
  const StyleStatut(this.libelle, this.couleur, this.icone);

  static StyleStatut de(String? statut, {String? libelle}) {
    final s = statut ?? '';
    final (l, c, i) = switch (s) {
      'en_attente' || 'en_attente_paiement' || 'a_verifier' || 'soumis' =>
        ('En attente', AppColors.orange, Icons.schedule_rounded),
      'confirmee' || 'confirme' || 'valide' || 'validee' =>
        ('Confirmée', AppColors.bleu, Icons.check_circle_outline_rounded),
      'en_preparation' || 'preparation' =>
        ('En préparation', AppColors.violet, Icons.autorenew_rounded),
      'prete' || 'pret' => ('Prête', AppColors.violet, Icons.inventory_2_outlined),
      'en_cours' || 'expediee' || 'en_livraison' =>
        ('En cours', AppColors.bleu, Icons.local_shipping_outlined),
      'livree' || 'terminee' || 'paye' || 'payee' || 'complete' =>
        ('Terminée', AppColors.vertVif, Icons.check_circle_outline_rounded),
      'actif' || 'active' => ('Active', AppColors.vertVif, Icons.check_circle_outline_rounded),
      'planifiee' => ('Planifiée', AppColors.bleu, Icons.event_outlined),
      'annulee' || 'annule' || 'rejete' || 'rejetee' || 'echec' =>
        ('Annulée', AppColors.rouge, Icons.cancel_outlined),
      'suspendu' || 'suspendue' => ('Suspendue', AppColors.rouge, Icons.block_rounded),
      'litige' => ('Litige', AppColors.rouge, Icons.report_gmailerrorred_rounded),
      'rembourse' || 'remboursee' => ('Remboursée', AppColors.grisTexte, Icons.undo_rounded),
      _ => (s.isEmpty ? '—' : s.replaceAll('_', ' '), AppColors.grisTexte,
          Icons.circle_outlined),
    };
    return StyleStatut(
        (libelle?.isNotEmpty ?? false) ? libelle! : l, c, i);
  }

  PuceStatut puce() => PuceStatut(libelle, couleur: couleur);
}

// ── Graphiques ────────────────────────────────────────────────────────

/// Anneau de progression avec pourcentage au centre.
class AnneauProgression extends StatelessWidget {
  final double valeur; // 0..1
  final Color couleur;
  final double taille;
  final double epaisseur;
  final String? texte;

  const AnneauProgression({
    required this.valeur,
    this.couleur = AppColors.vertVif,
    this.taille = 64,
    this.epaisseur = 7,
    this.texte,
    super.key,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: taille,
        height: taille,
        child: CustomPaint(
          painter: _Donut([
            (valeur.clamp(0, 1).toDouble(), couleur),
          ], epaisseur, fond: AppColors.blanc.withValues(alpha: 0.7)),
          child: Center(
            child: Text(texte ?? '${(valeur.clamp(0, 1) * 100).round()}%',
                style: TextStyle(
                    fontSize: taille * 0.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.noir)),
          ),
        ),
      );
}

/// Segment de répartition (libellé, valeur, couleur).
typedef Segment = (String libelle, num valeur, Color couleur);

/// Anneau de répartition avec légende.
class Repartition extends StatelessWidget {
  final List<Segment> segments;
  final String? centre;
  final String? sousCentre;
  final double taille;

  const Repartition(this.segments,
      {this.centre, this.sousCentre, this.taille = 120, super.key});

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<num>(0, (a, s) => a + s.$2);
    final parts = total == 0
        ? <(double, Color)>[]
        : [for (final s in segments) (s.$2 / total, s.$3)];
    return Row(
      children: [
        SizedBox(
          width: taille,
          height: taille,
          child: CustomPaint(
            painter: _Donut(parts, 14, fond: AppColors.surface2, espace: 0.025),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(centre ?? '$total',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.noir,
                          letterSpacing: -0.4)),
                  if (sousCentre != null)
                    Text(sousCentre!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grisTexte)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in segments)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: s.$3, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(s.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5, color: AppColors.grisTexte)),
                      ),
                      Text(
                          total == 0
                              ? '${s.$2}'
                              : '${s.$2} · ${(s.$2 / total * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.noir)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Donut extends CustomPainter {
  final List<(double, Color)> parts;
  final double epaisseur;
  final Color fond;
  final double espace;
  _Donut(this.parts, this.epaisseur, {required this.fond, this.espace = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(epaisseur / 2, epaisseur / 2,
        size.width - epaisseur, size.height - epaisseur);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = epaisseur
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, p..color = fond);
    var debut = -math.pi / 2;
    final nonVides = parts.where((e) => e.$1 > 0).length;
    // Bouts arrondis seulement pour un anneau de progression simple
    p.strokeCap = nonVides > 1 ? StrokeCap.butt : StrokeCap.round;
    for (final (part, couleur) in parts) {
      if (part <= 0) continue;
      final balayage = part * math.pi * 2;
      final ecart = nonVides > 1 ? espace * math.pi * 2 : 0.0;
      canvas.drawArc(rect, debut + ecart / 2,
          math.max(0.001, balayage - ecart), false, p..color = couleur);
      debut += balayage;
    }
  }

  @override
  bool shouldRepaint(_Donut old) => old.parts != parts;
}

/// Barre de progression arrondie.
class BarreProgression extends StatelessWidget {
  final double valeur;
  final Color couleur;
  final double hauteur;
  final Color fond;
  const BarreProgression(this.valeur,
      {this.couleur = AppColors.vertVif,
      this.hauteur = 6,
      this.fond = AppColors.surface2,
      super.key});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(hauteur),
        child: LinearProgressIndicator(
          value: valeur.clamp(0, 1).toDouble(),
          minHeight: hauteur,
          color: couleur,
          backgroundColor: fond,
        ),
      );
}

/// Barres horizontales comparatives (libellé, valeur, couleur).
class BarresComparees extends StatelessWidget {
  final List<Segment> lignes;
  final String Function(num)? format;
  const BarresComparees(this.lignes, {this.format, super.key});

  @override
  Widget build(BuildContext context) {
    final max = lignes.fold<num>(0, (a, s) => s.$2 > a ? s.$2 : a);
    return Column(
      children: [
        for (final l in lignes)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l.$1,
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.grisTexte)),
                    ),
                    Text(format?.call(l.$2) ?? '${l.$2}',
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.noir)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: max == 0 ? 0 : (l.$2 / max).toDouble(),
                    minHeight: 8,
                    color: l.$3,
                    backgroundColor: AppColors.surface2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Listes & réglages ─────────────────────────────────────────────────

/// Groupe de lignes dans une carte blanche, séparées par un filet.
class GroupeLignes extends StatelessWidget {
  final List<Widget> lignes;
  const GroupeLignes(this.lignes, {super.key});

  @override
  Widget build(BuildContext context) => Surface(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < lignes.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, indent: 52, color: AppColors.grisBord),
              lignes[i],
            ],
          ],
        ),
      );
}

/// Ligne de réglage : icône fine, titre, valeur ou chevron.
class LigneReglage extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String? sousTitre;
  final String? valeur;
  final VoidCallback? onTap;
  final Color? couleur;
  final Widget? trailing;
  /// Couleur d'une tuile d'icône (au lieu de l'icône seule).
  final Color? tuile;

  const LigneReglage({
    required this.icone,
    required this.titre,
    this.sousTitre,
    this.valeur,
    this.onTap,
    this.couleur,
    this.trailing,
    this.tuile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = couleur ?? AppColors.noir;
    final vertical = tuile != null ? 11.0 : 14.0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: vertical),
        child: Row(
          children: [
            tuile != null
                ? TuileIcone(icone, couleur: tuile!, taille: 34)
                : Icon(icone, size: 21, color: c),
            SizedBox(width: tuile != null ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre,
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: c)),
                  if (sousTitre != null)
                    Text(sousTitre!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grisTexte)),
                ],
              ),
            ),
            if (valeur != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(valeur!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.grisTexte)),
              ),
            trailing ??
                (onTap != null
                    ? const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.chevron_right_rounded,
                            size: 20, color: AppColors.grisLeger),
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

/// Avatar rond à initiales.
class AvatarInitiales extends StatelessWidget {
  final String nom;
  final double taille;
  final Color fond;
  final Color texte;

  const AvatarInitiales(this.nom,
      {this.taille = 48,
      this.fond = AppColors.surface2,
      this.texte = AppColors.noir,
      super.key});

  static String initiales(String nom) {
    final mots =
        nom.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
    if (mots.isEmpty) return '?';
    return (mots.first[0] + (mots.length > 1 ? mots.last[0] : ''))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: taille,
        height: taille,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
        child: Text(initiales(nom),
            style: TextStyle(
                fontSize: taille * 0.36,
                fontWeight: FontWeight.w700,
                color: texte)),
      );
}

/// Ligne « icône · libellé · valeur » pour les fiches de détail.
class LigneInfo extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final String valeur;
  const LigneInfo(this.icone, this.libelle, this.valeur, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, size: 18, color: AppColors.grisTexte),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: Text(libelle,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.grisTexte)),
            ),
            Expanded(
              child: Text(valeur,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.noir)),
            ),
          ],
        ),
      );
}

/// Bandeau d'alerte cliquable (actions requises).
class BandeauAlerte extends StatelessWidget {
  final IconData icone;
  final String texte;
  final Color couleur;
  final VoidCallback? onTap;

  const BandeauAlerte({
    required this.icone,
    required this.texte,
    this.couleur = AppColors.orange,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Surface(
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Row(
            children: [
              TuileIcone(icone, couleur: couleur, taille: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Text(texte,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.noir)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.grisLeger),
            ],
          ),
        ),
      );
}

// ── Retours utilisateur ───────────────────────────────────────────────

/// Message bref en bas d'écran, avec icône de succès ou d'erreur.
void afficherMessage(BuildContext context, String message,
    {bool succes = true}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(
              succes
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              size: 20,
              color: succes ? AppColors.vertMoyen : const Color(0xFFFF8A80)),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    ));
}
