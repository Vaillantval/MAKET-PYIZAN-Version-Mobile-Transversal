import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../ui/ui.dart';

/// Vrai si un compte est connecté. Sinon (visiteur qui parcourt la
/// boutique), propose de se connecter ou de créer un compte, puis de
/// revenir sur [retour] (l'écran courant par défaut).
bool exigerConnexion(BuildContext context, WidgetRef ref,
    {String? retour, String motif = 'pour ajouter au panier et commander'}) {
  if (ref.read(authProvider).status == AuthStatus.authenticated) return true;
  final from = retour ?? GoRouterState.of(context).uri.toString();
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: TuileIcone(Icons.person_outline_rounded,
                  couleur: AppColors.vertFonce, taille: 56),
            ),
            const SizedBox(height: 14),
            const Text('Connectez-vous',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Un compte Makèt Peyizan est nécessaire $motif.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.grisTexte, height: 1.4)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go(Uri(path: '/login', queryParameters: {'from': from})
                    .toString());
              },
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go(Uri(path: '/register', queryParameters: {'from': from})
                    .toString());
              },
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
              child: const Text('Créer un compte'),
            ),
          ],
        ),
      ),
    ),
  );
  return false;
}
