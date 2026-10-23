import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'logo_anime.dart';

/// Logo et nom Makèt Peyizan animés en continu (en-tête de l'accueil) :
/// le logo flotte doucement et respire, un reflet lumineux glisse sur le
/// nom. Tout s'arrête si le téléphone demande moins d'animations.
class MarqueAnimee extends StatefulWidget {
  final double tailleLogo;
  const MarqueAnimee({this.tailleLogo = 40, super.key});

  @override
  State<MarqueAnimee> createState() => _MarqueAnimeeState();
}

class _MarqueAnimeeState extends State<MarqueAnimee>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduit) {
      _ctrl.stop();
      _ctrl.value = 0;
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Makèt Peyizan',
        excludeSemantics: true,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final t = _ctrl.value;
            // Flottement : un aller-retour vertical par cycle
            final dy = math.sin(t * 2 * math.pi) * 2.5;
            // Reflet : de -1 (hors champ à gauche) à 2 (hors champ à droite)
            final reflet = -1.0 + 3.0 * t;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, dy),
                  child: LogoAnime(taille: widget.tailleLogo, rayon: 12),
                ),
                const SizedBox(width: 10),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment(reflet - 0.6, 0),
                    end: Alignment(reflet + 0.6, 0),
                    colors: const [
                      AppColors.noir,
                      AppColors.vertMoyen,
                      AppColors.noir,
                    ],
                    stops: const [0.2, 0.5, 0.8],
                  ).createShader(rect),
                  child: const Text('Makèt Peyizan',
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3)),
                ),
              ],
            );
          },
        ),
      );
}
