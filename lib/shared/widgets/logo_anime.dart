import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Logo « ML » dessiné en vecteur, avec la feuille qui se balance
/// doucement en continu, comme dans la brise. Immobile si le téléphone
/// demande moins d'animations.
class LogoAnime extends StatefulWidget {
  final double taille;
  final double rayon;
  final BoxBorder? bordure;
  const LogoAnime({this.taille = 34, this.rayon = 10, this.bordure, super.key});

  @override
  State<LogoAnime> createState() => _LogoAnimeState();
}

class _LogoAnimeState extends State<LogoAnime>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800));
  late final _vent = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduit) {
      _ctrl.stop();
      _ctrl.value = 0.5;
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'MaketLakay',
      image: true,
      child: Container(
        width: widget.taille,
        height: widget.taille,
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(widget.rayon),
          border: widget.bordure,
        ),
        child: RepaintBoundary(
          child: CustomPaint(painter: _PeintreLogo(_vent)),
        ),
      ),
    );
  }
}

/// Tracé repris du logo (image carrée de 1254 px), mis à l'échelle.
class _PeintreLogo extends CustomPainter {
  final Animation<double> vent;
  _PeintreLogo(this.vent) : super(repaint: vent);

  static const _cote = 1254.0;
  static final _vert   = Paint()..color = AppColors.vertFonce;
  static final _orange = Paint()..color = AppColors.jaune;
  static final _lisere = Paint()
    ..color = AppColors.blanc
    ..style = PaintingStyle.stroke
    ..strokeWidth = 30
    ..strokeJoin = StrokeJoin.round;

  static final _m = Path()
    ..moveTo(221, 258)
    ..lineTo(497, 525)
    ..lineTo(749, 277)
    ..lineTo(749, 403)
    ..lineTo(490, 692)
    ..lineTo(351, 555)
    ..lineTo(351, 893)
    ..lineTo(221, 893)
    ..close();

  static final _l = Path()
    ..moveTo(787, 275)
    ..lineTo(898, 275)
    ..lineTo(898, 757)
    ..lineTo(1087, 757)
    ..lineTo(1087, 893)
    ..lineTo(677, 893)
    ..cubicTo(760, 810, 787, 740, 787, 640)
    ..close();

  // Feuille fendue par sa nervure
  static final _feuille = Path()
    ..moveTo(747, 463)
    ..cubicTo(640, 570, 560, 660, 572, 760)
    ..cubicTo(578, 810, 592, 835, 607, 855)
    ..cubicTo(600, 760, 630, 680, 692, 600)
    ..cubicTo(660, 680, 630, 780, 632, 885)
    ..cubicTo(700, 820, 747, 760, 747, 640)
    ..close();

  // Pied de la feuille : point de rotation
  static const _pied = Offset(620, 880);
  static const _amplitude = 3 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final e = size.shortestSide / _cote;
    canvas.save();
    canvas.translate((size.width - _cote * e) / 2, (size.height - _cote * e) / 2);
    canvas.scale(e);

    canvas.save();
    canvas.translate(_pied.dx, _pied.dy);
    // Penchée vers le L, elle s'ouvre ; vers le M, elle se replie un peu
    canvas.rotate((vent.value - 0.5) * 2 * _amplitude);
    final ouverture = 0.95 + 0.05 * vent.value;
    canvas.scale(ouverture, ouverture);
    canvas.translate(-_pied.dx, -_pied.dy);
    canvas.drawPath(_feuille, _vert);
    canvas.restore();

    // Les lettres par-dessus, cernées de blanc : la feuille ne les touche
    // jamais, même penchée
    canvas.drawPath(_m, _lisere);
    canvas.drawPath(_l, _lisere);
    canvas.drawPath(_m, _vert);
    canvas.drawPath(_l, _orange);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintreLogo old) => old.vent != vent;
}
