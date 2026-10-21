import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../../features/acheteur/providers/wallet_provider.dart';
import '../../features/pos/providers/pos_session_provider.dart';
import '../../features/pos/providers/pos_terminal_status_provider.dart';
import '../../features/pos/providers/pos_vente_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/entreprise_provider.dart';

/// Navigue vers le bon écran selon les données d'un push (clé `screen`,
/// toutes les valeurs sont des chaînes) : toucher d'une notification en
/// arrière-plan, au lancement de l'app, ou d'une notification locale.
class NotificationHandler {
  static void handle(
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    final container = ProviderScope.containerOf(context, listen: false);
    final screen = data['screen'] as String? ?? '';
    final numero = (data['numero'] ?? data['numero_commande']) as String?;

    // Clé `screen` envoyée par le backend MaketLakay (apps/emails/
    // fcm_notifications.py, wallet, POS)
    switch (screen) {
      // Portefeuille (cashback, parrainage, retrait payé, recharge validée,
      // paiement ou remboursement au comptoir) : solde à jour
      case 'wallet':
        container.read(walletProvider.notifier).rafraichir();
        container.read(walletTransactionsProvider.notifier).charger();
        context.go('/acheteur/wallet');
        return;

      // Terminal POS validé : débloquer la caisse (ouvrir sa session)
      case 'pos_terminal_valide':
        container.read(posTerminalStatusProvider.notifier).verifier();
        context.go('/pos/vente');
        return;

      // Terminal refusé / désactivé / réactivé : la caisse affiche l'écran
      // correspondant (PosTerminalBloque)
      case 'pos_terminal':
        container.read(posTerminalStatusProvider.notifier)
            .depuisPush(data['statut'] as String?);
        context.go('/pos/vente');
        return;

      // Session clôturée par l'administration
      case 'pos_session':
        container.read(posSessionProvider.notifier).sessionFermeeParServeur();
        container.read(posHistoriqueProvider.notifier).charger();
        context.go('/pos/historique');
        return;

      // Supervision POS (demande de terminal, écart de caisse) : pas
      // d'écran dédié dans l'app, ouvrir le tableau de bord web
      case 'admin_pos':
        launchUrl(Uri.parse(AppConstants.urlSupervisionPos),
            mode: LaunchMode.externalApplication);
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
}
