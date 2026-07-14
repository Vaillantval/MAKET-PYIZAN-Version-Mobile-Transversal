import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../utils/role_utils.dart';

/// Navigue vers le bon écran selon le type de notification
class NotificationHandler {
  static void handle(
    RemoteMessage message,
    BuildContext context,
  ) {
    final data = message.data;

    // Notifications wallet (cashback crédité, bonus parrainage, retrait
    // payé, recharge validée…) pointent toutes vers l'écran portefeuille.
    if (data['screen'] == 'wallet') {
      final role = ProviderScope.containerOf(context, listen: false)
          .read(authProvider).user?.role;
      context.go('${walletBasePath(role)}/wallet');
      return;
    }

    final type = data['type'] as String? ?? '';

    switch (type) {
      case 'nouvelle_commande':
        final role = data['role'] as String? ?? '';
        if (role == 'producteur') {
          context.go('/producteur/commandes');
        } else {
          context.go('/admin/commandes');
        }
        break;

      case 'commande_confirmee':
      case 'commande_livree':
        final numero = data['numero_commande'] as String?;
        if (numero != null) {
          context.go('/acheteur/commande/$numero');
        }
        break;

      case 'paiement_a_verifier':
        context.go('/admin/paiements');
        break;

      case 'alerte_stock':
        context.go('/admin/stocks');
        break;

      case 'nouvelle_collecte':
        final role = data['role'] as String? ?? '';
        if (role == 'collecteur') {
          context.go('/collecteur/collectes');
        } else {
          context.go('/producteur/collectes');
        }
        break;

      case 'producteur_valide':
        context.go('/producteur/dashboard');
        break;

      case 'validation_producteur':
        context.go('/admin/producteurs');
        break;

      default:
        // Notification générique → pas de navigation
        break;
    }
  }

  /// Afficher une bannière in-app
  static void showInAppBanner(
    RemoteMessage message,
    BuildContext context,
  ) {
    final notification = message.notification;
    if (notification == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title ?? '',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (notification.body != null)
              Text(
                notification.body!,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        action: SnackBarAction(
          label: 'Voir',
          onPressed: () => handle(message, context),
        ),
        duration:        const Duration(seconds: 5),
        backgroundColor: const Color(0xFF1A6B2F),
      ),
    );
  }
}
