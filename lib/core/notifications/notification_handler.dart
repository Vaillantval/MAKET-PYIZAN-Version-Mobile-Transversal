import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../features/pos/providers/pos_terminal_status_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/entreprise_provider.dart';

/// Navigue vers le bon écran selon le type de notification
class NotificationHandler {
  static void handle(
    RemoteMessage message,
    BuildContext context,
  ) {
    final data = message.data;
    final screen = data['screen'] as String? ?? '';
    final numero = (data['numero'] ?? data['numero_commande']) as String?;

    // Clé `screen` envoyée par le backend MaketLakay (apps/emails/
    // fcm_notifications.py, wallet, POS)
    switch (screen) {
      // Notifications wallet (cashback crédité, bonus parrainage, retrait
      // payé, recharge validée…) : portefeuille personnel
      case 'wallet':
        context.go('/acheteur/wallet');
        return;

      // Terminal POS validé par un admin — pousser un rafraîchissement
      // immédiat du statut (badge, onglet Profil) plutôt que d'attendre le
      // prochain appel POS pour le découvrir.
      case 'pos_terminal_valide':
        context.go('/pos/vente');
        ProviderScope.containerOf(context, listen: false)
            .read(posTerminalStatusProvider.notifier)
            .verifier();
        return;

      case 'acheteur_commande':
        context.go(numero != null
            ? '/acheteur/commande/$numero'
            : '/acheteur/commandes');
        return;

      case 'producteur_commande':
        _versEspaceEntreprise(context, data, '/producteur/commandes');
        return;
      case 'producteur_collecte':
        _versEspaceEntreprise(context, data, '/producteur/collectes');
        return;
      case 'producteur_stock':
        _versEspaceEntreprise(context, data, '/producteur/catalogue');
        return;

      case 'admin_commande':
        context.go('/admin/commandes');
        return;
      case 'admin_alerte_stock':
        context.go('/admin/stocks');
        return;
      case 'admin_collecte':
        context.go('/admin/collectes');
        return;
    }

    // Ancien format (clé `type`)
    final type = data['type'] as String? ?? '';

    switch (type) {
      case 'nouvelle_commande':
        final role = data['role'] as String? ?? '';
        if (role == 'producteur') {
          _versEspaceEntreprise(context, data, '/producteur/commandes');
        } else {
          context.go('/admin/commandes');
        }
        break;

      case 'commande_confirmee':
      case 'commande_livree':
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
          _versEspaceEntreprise(context, data, '/producteur/collectes');
        }
        break;

      case 'producteur_valide':
        _versEspaceEntreprise(context, data, '/producteur/dashboard');
        break;

      case 'validation_producteur':
        context.go('/admin/producteurs');
        break;

      default:
        // Notification générique → pas de navigation
        break;
    }
  }

  /// Notification « entreprise » : le backend joint `entreprise_id` —
  /// on bascule sur cette entreprise si le compte en est membre. À défaut
  /// (anciennes notifications), on garde l'entreprise active, on entre dans
  /// la seule entreprise du compte, sinon on laisse choisir depuis le Profil.
  static Future<void> _versEspaceEntreprise(
      BuildContext context, Map<String, dynamic> data, String route) async {
    final container   = ProviderScope.containerOf(context, listen: false);
    final entreprises =
        container.read(authProvider).user?.entreprises ?? const [];
    final active      = container.read(entrepriseActiveIdProvider.notifier);

    final idCible = int.tryParse('${data['entreprise_id'] ?? ''}');
    final cible   = entreprises.where((e) => e.id == idCible).firstOrNull;
    if (cible != null) {
      if (container.read(entrepriseActiveIdProvider) != cible.id) {
        await active.activer(cible);
      }
    } else if (container.read(entrepriseActiveProvider) == null) {
      if (entreprises.length != 1) {
        context.go('/acheteur/profil');
        return;
      }
      await active.activer(entreprises.first);
    }
    if (context.mounted) context.go(route);
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
        backgroundColor: AppColors.vertFonce,
      ),
    );
  }
}
