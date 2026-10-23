import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/logo_anime.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>    _fadeAnim;
  late Animation<double>    _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // go_router gère la redirection automatiquement
    return Scaffold(
      backgroundColor: AppColors.vertFonce,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                const LogoAnime(taille: 100, rayon: 30),
                const SizedBox(height: 24),
                const Text.rich(
                  TextSpan(children: [
                    TextSpan(text: 'Maket'),
                    TextSpan(text: 'Lakay', style: TextStyle(color: AppColors.jaune)),
                  ]),
                  style: TextStyle(
                    fontSize:   34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color:      AppColors.blanc,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sòti nan jaden, rive lakay ou',
                  style: TextStyle(
                    fontSize: 14,
                    color:    AppColors.blanc.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  color: AppColors.jaune,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
