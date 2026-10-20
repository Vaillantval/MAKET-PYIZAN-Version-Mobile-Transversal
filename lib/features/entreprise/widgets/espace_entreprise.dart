import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/entreprise.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/entreprise_provider.dart';

/// Entrer dans l'espace d'une entreprise : directement s'il n'y en a
/// qu'une, sinon après choix dans une feuille ; vers la création si le
/// compte n'est membre d'aucune.
Future<void> ouvrirEspaceEntreprise(BuildContext context, WidgetRef ref) async {
  final entreprises = ref.read(authProvider).user?.entreprises ?? const [];
  if (entreprises.isEmpty) {
    context.push('/acheteur/entreprise/creer');
    return;
  }
  final choix = entreprises.length == 1
      ? entreprises.first
      : await choisirEntreprise(context, entreprises);
  if (choix == null || !context.mounted) return;
  await entrerDansEntreprise(context, ref, choix);
}

Future<void> entrerDansEntreprise(
    BuildContext context, WidgetRef ref, EntrepriseMembre entreprise) async {
  await ref.read(entrepriseActiveIdProvider.notifier).activer(entreprise);
  if (context.mounted) context.go('/producteur/dashboard');
}

/// Revenir à l'espace acheteur (portefeuille et achats personnels).
Future<void> revenirEspaceAcheteur(BuildContext context, WidgetRef ref) async {
  await ref.read(entrepriseActiveIdProvider.notifier).quitter();
  if (context.mounted) context.go('/acheteur/accueil');
}

Future<EntrepriseMembre?> choisirEntreprise(
    BuildContext context, List<EntrepriseMembre> entreprises) {
  return showModalBottomSheet<EntrepriseMembre>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Choisissez une entreprise',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.vertFonce,
              ),
            ),
          ),
          for (final e in entreprises)
            EntrepriseTile(entreprise: e, onTap: () => Navigator.pop(ctx, e)),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

/// Ligne d'une entreprise : nom, type, rôle du compte et statut.
class EntrepriseTile extends StatelessWidget {
  final EntrepriseMembre entreprise;
  final VoidCallback onTap;
  const EntrepriseTile({required this.entreprise, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final e = entreprise;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.vertMenthe,
        child: Icon(_iconeType(e.type), color: AppColors.vertFonce),
      ),
      title: Text(e.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        [e.typeLabel, e.roleLabel].where((s) => s.isNotEmpty).join(' · '),
      ),
      trailing: StatutEntrepriseBadge(statut: e.statut),
      onTap: onTap,
    );
  }

  static IconData _iconeType(String type) {
    switch (type) {
      case 'fournisseur': return Icons.local_shipping_outlined;
      case 'entreprise':  return Icons.storefront_outlined;
      default:            return Icons.agriculture_outlined;
    }
  }
}

class StatutEntrepriseBadge extends StatelessWidget {
  final String statut;
  const StatutEntrepriseBadge({required this.statut, super.key});

  @override
  Widget build(BuildContext context) {
    final (label, couleur) = switch (statut) {
      'actif'      => ('Active',     AppColors.vertVif),
      'en_attente' => ('En attente', AppColors.statutAttente),
      'suspendu'   => ('Suspendue',  AppColors.rouge),
      _            => ('Inactive',   AppColors.grisTexte),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700, color: couleur)),
    );
  }
}

/// Bloc « Mes entreprises » de l'espace acheteur : accès à l'espace de
/// chaque entreprise du compte, et création d'une nouvelle entreprise.
class MesEntreprisesCard extends ConsumerWidget {
  const MesEntreprisesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entreprises = ref.watch(authProvider).user?.entreprises ?? const [];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Mes entreprises',
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.vertFonce,
              ),
            ),
          ),
          if (entreprises.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Vous vendez des produits ? Créez votre entreprise pour '
                'publier votre catalogue et recevoir des commandes.',
                style: TextStyle(fontSize: 13, color: AppColors.grisTexte),
              ),
            ),
          for (final e in entreprises)
            EntrepriseTile(
              entreprise: e,
              onTap: () => entrerDansEntreprise(context, ref, e),
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add_business_outlined,
                color: AppColors.vertVif),
            title: const Text('Créer une entreprise'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => context.push('/acheteur/entreprise/creer'),
          ),
        ],
      ),
    );
  }
}
