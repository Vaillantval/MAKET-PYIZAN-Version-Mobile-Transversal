import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';

/// Écran d'accueil du premier lancement (cf. maquettes) : trois pages sur
/// fond vert forêt, puis « Commencer » (boutique en visiteur) ou
/// « J'ai déjà un compte ». N'est montré qu'une fois par installation.
class BienvenueScreen extends ConsumerStatefulWidget {
  const BienvenueScreen({super.key});

  @override
  ConsumerState<BienvenueScreen> createState() => _BienvenueScreenState();
}

class _Page {
  final Widget visuel;
  final String titre;
  final String accent;
  final String texte;
  const _Page(this.visuel, this.titre, this.accent, this.texte);
}

class _BienvenueScreenState extends ConsumerState<BienvenueScreen> {
  final _pages = const [
    _Page(_VisuelLogo(), 'Sòti nan jaden,', 'rive lakay ou.',
        'Les produits frais des paysans haïtiens, livrés jusqu\'à votre porte.'),
    _Page(_VisuelIcone(Icons.storefront_rounded), 'Achetez direct', 'aux producteurs.',
        'Légumes, fruits, café, céréales : au juste prix, sans intermédiaire.'),
    _Page(_VisuelIcone(Icons.account_balance_wallet_rounded), 'Payez comme', 'vous voulez.',
        'MonCash, NatCash, espèces ou votre portefeuille Makèt Peyizan.'),
  ];

  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _terminer(String route) async {
    await ref.read(localStorageProvider).setBool(AppConstants.keyBienvenueVue, true);
    if (mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final derniere = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.noir,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
              child: Row(
                children: [
                  const Text('Makèt Peyizan',
                      style: TextStyle(
                          color: AppColors.blanc,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3)),
                  const Spacer(),
                  if (!derniere)
                    TextButton(
                      onPressed: () => _terminer('/acheteur/accueil'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.blanc,
                        backgroundColor: AppColors.blanc.withValues(alpha: 0.12),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Passer'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _PageBienvenue(_pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.vertMoyen
                          : AppColors.blanc.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: derniere
                        ? () => _terminer('/acheteur/accueil')
                        : () => _ctrl.nextPage(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vertMenthe,
                      foregroundColor: AppColors.noir,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(derniere ? 'Commencer' : 'Suivant'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => _terminer('/login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blanc,
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: AppColors.blanc.withValues(alpha: 0.5)),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: const Text("J'ai déjà un compte"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageBienvenue extends StatelessWidget {
  final _Page page;
  const _PageBienvenue(this.page);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Center(child: page.visuel)),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: '${page.titre}\n'),
                TextSpan(
                    text: page.accent,
                    style: const TextStyle(color: AppColors.vertMoyen)),
              ]),
              style: const TextStyle(
                color: AppColors.blanc,
                fontSize: 32,
                height: 1.15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 12),
            Text(page.texte,
                style: TextStyle(
                    color: AppColors.blanc.withValues(alpha: 0.72),
                    fontSize: 15,
                    height: 1.4)),
            const SizedBox(height: 24),
          ],
        ),
      );
}

/// Halo vert diffus derrière le visuel (comme les maquettes).
class _Halo extends StatelessWidget {
  final Widget child;
  const _Halo({required this.child});

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.vertMoyen.withValues(alpha: 0.45),
                AppColors.vertMoyen.withValues(alpha: 0),
              ]),
            ),
          ),
          child,
        ],
      );
}

class _VisuelLogo extends StatelessWidget {
  const _VisuelLogo();

  @override
  Widget build(BuildContext context) => _Halo(
        child: Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(10),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.blanc,
            borderRadius: BorderRadius.circular(44),
          ),
          child: Image.asset('assets/images/maketpeyizan_logo.png',
              fit: BoxFit.contain),
        ),
      );
}

class _VisuelIcone extends StatelessWidget {
  final IconData icone;
  const _VisuelIcone(this.icone);

  @override
  Widget build(BuildContext context) => _Halo(
        child: Container(
          width: 170,
          height: 170,
          decoration: const BoxDecoration(
            color: AppColors.vertMenthe,
            shape: BoxShape.circle,
          ),
          child: Icon(icone, size: 76, color: AppColors.vertFonce),
        ),
      );
}
