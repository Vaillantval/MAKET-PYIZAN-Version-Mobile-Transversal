import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Logo Makèt Peyizan qui « respire » doucement en continu (léger
/// agrandissement puis retour). Immobile si le téléphone demande moins
/// d'animations.
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
  late final _souffle = Tween<double>(begin: 0.96, end: 1.0)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduit) {
      _ctrl.stop();
      _ctrl.value = 1;
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
      label: 'Makèt Peyizan',
      image: true,
      child: Container(
        width: widget.taille,
        height: widget.taille,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(widget.rayon),
          border: widget.bordure,
        ),
        child: ScaleTransition(
          scale: _souffle,
          child: Image.asset(
            'assets/images/maketpeyizan_logo.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
