import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

// Animations qui accompagnent les sons de l'app (SonsApp). Courtes, et
// réduites au minimum quand le téléphone demande moins d'animations.

bool _animationsReduites(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

// ── Rebond ────────────────────────────────────────────────────────────

/// Fait rebondir [child] chaque fois que [valeur] change (badge du
/// panier, quantité en caisse…).
class Rebond extends StatefulWidget {
  final Object? valeur;
  final Widget child;
  final double amplitude;
  const Rebond({
    required this.valeur,
    required this.child,
    this.amplitude = 0.35,
    super.key,
  });

  @override
  State<Rebond> createState() => _RebondState();
}

class _RebondState extends State<Rebond> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));

  @override
  void didUpdateWidget(Rebond ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.valeur != widget.valeur && !_animationsReduites(context)) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: 1 + widget.amplitude * math.sin(_ctrl.value * math.pi),
          child: child,
        ),
        child: widget.child,
      );
}

// ── Compteur ──────────────────────────────────────────────────────────

/// Montant qui défile de l'ancienne à la nouvelle valeur (solde du
/// portefeuille, montant encaissé).
class CompteurAnime extends StatefulWidget {
  final double valeur;
  final String Function(double) format;
  final TextStyle? style;
  /// Valeur de départ au premier affichage (par défaut : aucune animation).
  final double? depart;
  const CompteurAnime({
    required this.valeur,
    required this.format,
    this.style,
    this.depart,
    super.key,
  });

  @override
  State<CompteurAnime> createState() => _CompteurAnimeState();
}

class _CompteurAnimeState extends State<CompteurAnime> {
  late double _de = widget.depart ?? widget.valeur;

  @override
  void didUpdateWidget(CompteurAnime ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.valeur != widget.valeur) _de = ancien.valeur;
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: _de, end: widget.valeur),
        duration: _animationsReduites(context)
            ? Duration.zero
            : const Duration(milliseconds: 750),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => Text(widget.format(v), style: widget.style),
      );
}

// ── Tremblement ───────────────────────────────────────────────────────

/// Fait trembler [child] à l'appel de `secouer()` (erreur de saisie,
/// paiement refusé). S'utilise avec une `GlobalKey<TremblementState>`.
class Tremblement extends StatefulWidget {
  final Widget child;
  const Tremblement({required this.child, super.key});

  @override
  State<Tremblement> createState() => TremblementState();
}

class TremblementState extends State<Tremblement>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));

  void secouer() {
    if (!mounted || _animationsReduites(context)) return;
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          // Oscillation amortie : 3 allers-retours
          offset: Offset(
              9 * (1 - _ctrl.value) * math.sin(_ctrl.value * math.pi * 6), 0),
          child: child,
        ),
        child: widget.child,
      );
}

// ── Coche ─────────────────────────────────────────────────────────────

/// Cercle puis coche qui se dessinent (commande passée, vente encaissée).
class CocheAnimee extends StatefulWidget {
  final double taille;
  final Color couleur;
  const CocheAnimee({
    this.taille = 88,
    this.couleur = AppColors.vertFonce,
    super.key,
  });

  @override
  State<CocheAnimee> createState() => _CocheAnimeeState();
}

class _CocheAnimeeState extends State<CocheAnimee>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 750));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _animationsReduites(context) ? _ctrl.value = 1 : _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: widget.taille,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _PeintreCoche(_ctrl.value, widget.couleur),
          ),
        ),
      );
}

class _PeintreCoche extends CustomPainter {
  final double t;
  final Color couleur;
  _PeintreCoche(this.t, this.couleur);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final centre = Offset(r, r);
    // 0 → 0,6 : disque teinté et cercle ; 0,55 → 1 : coche
    final cercle = Curves.easeOut.transform((t / 0.6).clamp(0, 1));
    final coche  = Curves.easeOut.transform(((t - 0.55) / 0.45).clamp(0, 1));

    canvas.drawCircle(centre, r * cercle,
        Paint()..color = couleur.withValues(alpha: 0.12));
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: r - 3),
      -math.pi / 2,
      2 * math.pi * cercle,
      false,
      Paint()
        ..color = couleur
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    if (coche <= 0) return;
    final chemin = Path()
      ..moveTo(size.width * 0.30, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.66)
      ..lineTo(size.width * 0.71, size.height * 0.37);
    final metrique = chemin.computeMetrics().first;
    canvas.drawPath(
      metrique.extractPath(0, metrique.length * coche),
      Paint()
        ..color = couleur
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PeintreCoche ancien) => ancien.t != t;
}

/// Écran de réussite bref (coche animée) qui se ferme tout seul.
Future<void> afficherReussite(BuildContext context,
    {required String titre, String? detail}) {
  final nav = Navigator.of(context, rootNavigator: true);
  var ouvert = true;
  Future.delayed(const Duration(milliseconds: 1500), () {
    if (ouvert && nav.mounted) nav.pop();
  });
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: titre,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, _, __) => Center(
      child: Material(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CocheAnimee(),
              const SizedBox(height: 16),
              Text(titre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              if (detail != null) ...[
                const SizedBox(height: 4),
                Text(detail,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.grisTexte)),
              ],
            ],
          ),
        ),
      ),
    ),
    transitionBuilder: (_, a, __, child) => FadeTransition(
      opacity: a,
      child: ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0).animate(a), child: child),
    ),
  ).whenComplete(() => ouvert = false);
}

// ── Vol vers le panier ────────────────────────────────────────────────

/// Marque l'icône du panier de la barre de navigation comme cible de
/// [volerVersPanier].
class CiblePanier extends StatefulWidget {
  final Widget child;
  const CiblePanier({required this.child, super.key});

  static _CiblePanierState? _actuelle;

  @override
  State<CiblePanier> createState() => _CiblePanierState();
}

class _CiblePanierState extends State<CiblePanier> {
  @override
  void initState() {
    super.initState();
    CiblePanier._actuelle = this;
  }

  @override
  void dispose() {
    if (CiblePanier._actuelle == this) CiblePanier._actuelle = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Une pastille part de [depart] (le bouton touché) et vole jusqu'à
/// l'icône du panier ; [aLArrivee] est appelé quand elle l'atteint.
void volerVersPanier(BuildContext depart, {VoidCallback? aLArrivee}) {
  final cible  = CiblePanier._actuelle;
  final boite  = depart.findRenderObject() as RenderBox?;
  final boiteC = cible?.context.findRenderObject() as RenderBox?;
  final overlay = Overlay.maybeOf(depart, rootOverlay: true);
  if (boite == null || boiteC == null || overlay == null ||
      !boiteC.attached || _animationsReduites(depart)) {
    aLArrivee?.call();
    return;
  }
  final de = boite.localToGlobal(boite.size.center(Offset.zero));
  final a  = boiteC.localToGlobal(boiteC.size.center(Offset.zero));

  late OverlayEntry entree;
  entree = OverlayEntry(
    builder: (_) => TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeInCubic,
      onEnd: () {
        entree.remove();
        aLArrivee?.call();
      },
      builder: (_, t, __) {
        // Trajectoire en arc : monte d'abord, puis plonge vers l'icône
        final x = de.dx + (a.dx - de.dx) * t;
        final y = de.dy + (a.dy - de.dy) * t - 90 * math.sin(t * math.pi);
        final taille = 30 * (1 - 0.6 * t);
        return Positioned(
          left: x - taille / 2,
          top:  y - taille / 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: 1 - 0.4 * t,
              child: Container(
                width: taille, height: taille,
                decoration: const BoxDecoration(
                  color: AppColors.vertFonce, shape: BoxShape.circle),
                child: taille > 20
                    ? const Icon(Icons.add_rounded,
                        size: 16, color: AppColors.blanc)
                    : null,
              ),
            ),
          ),
        );
      },
    ),
  );
  overlay.insert(entree);
}

// ── Sortie d'une ligne ────────────────────────────────────────────────

/// Ligne qui glisse vers la gauche et se replie avant d'être retirée :
/// `builder` reçoit `sortir(apres)`, qui joue l'animation puis appelle
/// `apres` (le retrait réel). Donner à chaque ligne une clé stable.
class SortieAnimee extends StatefulWidget {
  final Widget Function(BuildContext, void Function(VoidCallback apres) sortir)
      builder;
  const SortieAnimee({required this.builder, super.key});

  @override
  State<SortieAnimee> createState() => _SortieAnimeeState();
}

class _SortieAnimeeState extends State<SortieAnimee>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));

  Future<void> _sortir(VoidCallback apres) async {
    if (_ctrl.isAnimating) return;
    if (!_animationsReduites(context)) await _ctrl.forward();
    apres();
    if (mounted) _ctrl.value = 0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glisse = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    return SizeTransition(
      sizeFactor: ReverseAnimation(
          CurvedAnimation(parent: _ctrl, curve: const Interval(0.45, 1))),
      child: FadeTransition(
        opacity: ReverseAnimation(glisse),
        child: SlideTransition(
          position: Tween(begin: Offset.zero, end: const Offset(-0.6, 0))
              .animate(glisse),
          child: widget.builder(context, _sortir),
        ),
      ),
    );
  }
}

// ── Carte qui se retourne ─────────────────────────────────────────────

/// Retourne la carte quand son contenu change de clé (session ouverte ↔
/// fermée).
class CarteRetournable extends StatelessWidget {
  final Widget child;
  const CarteRetournable({required this.child, super.key});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: _animationsReduites(context)
            ? Duration.zero
            : const Duration(milliseconds: 520),
        transitionBuilder: (enfant, animation) {
          final entrant = enfant.key == child.key;
          return AnimatedBuilder(
            animation: animation,
            child: enfant,
            builder: (_, c) {
              // Chaque face n'est visible que sur sa moitié de l'animation
              // (valeur 1 → 0,5 pour l'ancienne, 0,5 → 1 pour la
              // nouvelle) : l'ancienne tourne jusqu'à la tranche, la
              // nouvelle repart de la tranche opposée.
              final v = animation.value;
              final angle = (1 - v) * math.pi * (entrant ? -1 : 1);
              return Opacity(
                opacity: v >= 0.5 ? 1 : 0,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateY(v >= 0.5 ? angle : 0),
                  child: c,
                ),
              );
            },
          );
        },
        layoutBuilder: (actuel, anciens) => Stack(
          alignment: Alignment.topCenter,
          children: [...anciens, if (actuel != null) actuel],
        ),
        child: child,
      );
}
