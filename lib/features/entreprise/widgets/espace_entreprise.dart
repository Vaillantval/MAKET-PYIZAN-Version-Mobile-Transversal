import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/entreprise.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/entreprise_provider.dart';
import '../../../shared/ui/ui.dart';

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
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choisissez une entreprise',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            TuileIcone(_iconeType(e.type), couleur: AppColors.vertFonce, taille: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14.5)),
                  Text(
                    [e.typeLabel, e.roleLabel].where((s) => s.isNotEmpty).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.grisTexte),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatutEntrepriseBadge(statut: e.statut),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grisLeger),
          ],
        ),
      ),
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
      'en_attente' => ('En attente', AppColors.orange),
      'suspendu'   => ('Suspendue',  AppColors.rouge),
      _            => ('Inactive',   AppColors.grisTexte),
    };
    return PuceStatut(label, couleur: couleur);
  }
}

/// Bloc « Mes entreprises » de l'espace acheteur : accès à l'espace de
/// chaque entreprise du compte, et création d'une nouvelle entreprise.
class MesEntreprisesCard extends ConsumerWidget {
  const MesEntreprisesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entreprises = ref.watch(authProvider).user?.entreprises ?? const [];

    return GroupeLignes([
      if (entreprises.isEmpty)
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Text(
            'Vous vendez des produits ? Créez votre entreprise pour '
            'publier votre catalogue et recevoir des commandes.',
            style: TextStyle(fontSize: 13, color: AppColors.grisTexte, height: 1.4),
          ),
        ),
      for (final e in entreprises)
        EntrepriseTile(
          entreprise: e,
          onTap: () => entrerDansEntreprise(context, ref, e),
        ),
      LigneReglage(
        icone: Icons.add_business_outlined,
        titre: 'Créer une entreprise',
        onTap: () => context.push('/acheteur/entreprise/creer'),
      ),
    ]);
  }
}
