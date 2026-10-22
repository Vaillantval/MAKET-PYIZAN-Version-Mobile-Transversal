import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../providers/annonces_provider.dart';

/// Carrousel des annonces de l'accueil (slides du site). Défile tout seul
/// toutes les 5 s, sauf pendant que l'utilisateur fait glisser. Sans
/// annonce (chargement, erreur, aucune active), affiche [secours].
class CarrouselAnnonces extends ConsumerStatefulWidget {
  final Widget secours;
  const CarrouselAnnonces({required this.secours, super.key});

  @override
  ConsumerState<CarrouselAnnonces> createState() => _CarrouselAnnoncesState();
}

class _CarrouselAnnoncesState extends ConsumerState<CarrouselAnnonces> {
  static const _intervalle = Duration(seconds: 5);
  final _pages = PageController();
  Timer? _minuterie;
  int _page = 0;
  int _nb = 0;

  void _relancer() {
    _minuterie?.cancel();
    final reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_nb < 2 || reduit) return;
    _minuterie = Timer.periodic(_intervalle, (_) {
      if (!_pages.hasClients) return;
      final suivante = (_page + 1) % _nb;
      // Retour au début sans traverser toutes les annonces
      suivante == 0
          ? _pages.jumpToPage(0)
          : _pages.animateToPage(suivante,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _minuterie?.cancel();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final annonces = ref.watch(annoncesProvider).valueOrNull ?? const [];
    if (annonces.isEmpty) return widget.secours;

    if (annonces.length != _nb) {
      _nb = annonces.length;
      _page = _page.clamp(0, _nb - 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _relancer();
      });
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: NotificationListener<ScrollStartNotification>(
            // Glissé à la main : la minuterie repart de zéro
            onNotification: (n) {
              if (n.dragDetails != null) _relancer();
              return false;
            },
            child: PageView.builder(
              controller: _pages,
              itemCount: annonces.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _CarteAnnonce(
                  annonce: annonces[i],
                  onTap: () => ouvrirLienAnnonce(context, ref, annonces[i].lien),
                ),
              ),
            ),
          ),
        ),
        if (annonces.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < annonces.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.noir : AppColors.grisBord,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CarteAnnonce extends StatelessWidget {
  final Annonce annonce;
  final VoidCallback onTap;
  const _CarteAnnonce({required this.annonce, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final avecBouton =
        annonce.lien.isNotEmpty && annonce.texteBouton.isNotEmpty;
    final fond = Container(color: AppColors.vertFonce);

    return Material(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: annonce.lien.isEmpty ? null : onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: ImageUtils.imageUrl(annonce.image),
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surface2),
              errorWidget: (_, __, ___) => fond,
            ),
            // Dégradé pour la lisibilité du texte
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xB3000000)],
                  stops: [0.25, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (annonce.titre.isNotEmpty)
                    Text(annonce.titre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 19,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppColors.blanc)),
                  if (annonce.sousTitre.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(annonce.sousTitre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.3,
                            color: Color(0xE6FFFFFF))),
                  ],
                  if (avecBouton) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                      decoration: BoxDecoration(
                        color: AppColors.blanc,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(annonce.texteBouton,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            radius: 11,
                            backgroundColor: AppColors.noir,
                            child: Icon(Icons.arrow_forward_rounded,
                                size: 13, color: AppColors.blanc),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
