import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/entreprise_provider.dart';
import '../../../shared/ui/ui.dart';
import '../providers/entreprise_service.dart';
import '../widgets/espace_entreprise.dart';

final membresProvider =
    FutureProvider.autoDispose.family<List<Membre>, int>((ref, entrepriseId) {
  return ref.read(entrepriseServiceProvider).membres(entrepriseId);
});

/// Membres de l'entreprise active. Tout membre les voit ; seuls les
/// propriétaires ajoutent, changent un rôle ou retirent quelqu'un. Chacun
/// peut quitter l'entreprise (sauf son dernier propriétaire).
class MembresScreen extends ConsumerWidget {
  const MembresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entreprise = ref.watch(entrepriseActiveProvider);
    if (entreprise == null) return const SizedBox.shrink();
    final membres = ref.watch(membresProvider(entreprise.id));
    final moi     = ref.watch(authProvider).user?.id;
    final proprio = entreprise.estProprietaire;

    return Scaffold(
      appBar: AppBar(title: const Text('Membres')),
      floatingActionButton: proprio
          ? FloatingActionButton.extended(
              icon:  const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Ajouter'),
              onPressed: () => _ajouter(context, ref, entreprise.id),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(membresProvider(entreprise.id)),
        child: membres.when(
          loading: () => const Center(
            child: CircularProgressIndicator()),
          error: (e, _) => ListView(children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(e.toString(), textAlign: TextAlign.center),
            ),
          ]),
          data: (liste) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              const Surface(
                couleur: AppColors.surface2,
                bordure: false,
                padding: EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.grisTexte),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Propriétaire : gère l\'entreprise, ses membres et son '
                        'portefeuille. Gestionnaire : gère produits, commandes '
                        'et collectes.',
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.grisTexte, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              Surtitre('${liste.length} membre(s)'),
              GroupeLignes([
                for (final m in liste)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
                    child: Row(
                      children: [
                        AvatarInitiales(m.nom, taille: 42),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.userId == moi ? '${m.nom} (vous)' : m.nom,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14.5)),
                              Text(m.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12.5, color: AppColors.grisTexte)),
                              const SizedBox(height: 4),
                              PuceStatut(m.roleLabel,
                                  couleur: m.estProprietaire
                                      ? AppColors.violet
                                      : AppColors.bleu),
                            ],
                          ),
                        ),
                        if (proprio || m.userId == moi)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded,
                                color: AppColors.grisTexte),
                            onSelected: (action) => _action(
                                context, ref, entreprise.id, m, action),
                            itemBuilder: (_) => [
                              if (proprio && !m.estProprietaire)
                                const PopupMenuItem(
                                  value: 'proprietaire',
                                  child: Text('Nommer propriétaire')),
                              if (proprio && m.estProprietaire)
                                const PopupMenuItem(
                                  value: 'gestionnaire',
                                  child: Text('Passer gestionnaire')),
                              PopupMenuItem(
                                value: 'retirer',
                                child: Text(
                                  m.userId == moi
                                      ? 'Quitter l\'entreprise'
                                      : 'Retirer de l\'entreprise',
                                  style: const TextStyle(color: AppColors.rouge),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _action(BuildContext context, WidgetRef ref, int entrepriseId,
      Membre m, String action) async {
    final service = ref.read(entrepriseServiceProvider);
    final moi     = ref.read(authProvider).user?.id;
    try {
      if (action == 'retirer') {
        final ok = await _confirmer(
          context,
          m.userId == moi
              ? 'Quitter cette entreprise ? Vous n\'y aurez plus accès.'
              : 'Retirer ${m.nom} de l\'entreprise ?',
        );
        if (!ok) return;
        await service.retirerMembre(entrepriseId, m.id);
        if (m.userId == moi) {
          // Plus membre : retour à l'espace acheteur, profil à jour
          await ref.read(authProvider.notifier).rafraichirProfil();
          if (context.mounted) await revenirEspaceAcheteur(context, ref);
          return;
        }
      } else {
        await service.changerRole(entrepriseId, m.id, action);
        // Mon propre rôle a pu changer : le recharger depuis /me
        if (m.userId == moi) {
          await ref.read(authProvider.notifier).rafraichirProfil();
        }
      }
      ref.invalidate(membresProvider(entrepriseId));
    } on EntrepriseException catch (e) {
      if (context.mounted) {
        afficherMessage(context, e.message, succes: false);
      }
    }
  }

  Future<bool> _confirmer(BuildContext context, String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.rouge),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer')),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _ajouter(BuildContext context, WidgetRef ref, int entrepriseId) async {
    final ajoute = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AjoutMembreSheet(entrepriseId: entrepriseId),
    );
    if (ajoute == true) ref.invalidate(membresProvider(entrepriseId));
  }
}

class _AjoutMembreSheet extends ConsumerStatefulWidget {
  final int entrepriseId;
  const _AjoutMembreSheet({required this.entrepriseId});

  @override
  ConsumerState<_AjoutMembreSheet> createState() => _AjoutMembreSheetState();
}

class _AjoutMembreSheetState extends ConsumerState<_AjoutMembreSheet> {
  final _email = TextEditingController();
  String  _role   = 'gestionnaire';
  bool    _envoi  = false;
  String? _erreur;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _erreur = 'Email invalide');
      return;
    }
    setState(() { _envoi = true; _erreur = null; });
    try {
      await ref.read(entrepriseServiceProvider)
          .ajouterMembre(widget.entrepriseId, email, _role);
      if (mounted) Navigator.pop(context, true);
    } on EntrepriseException catch (e) {
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Ajouter un membre', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'La personne doit déjà avoir un compte MaketLakay.',
            style: TextStyle(fontSize: 12, color: AppColors.grisTexte),
          ),
          const SizedBox(height: 16),
          TextField(
            controller:   _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText:  'Email du compte',
              prefixIcon: const Icon(Icons.email_outlined),
              errorText:  _erreur,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'gestionnaire', label: Text('Gestionnaire')),
              ButtonSegment(value: 'proprietaire', label: Text('Propriétaire')),
            ],
            selected: {_role},
            onSelectionChanged: (s) => setState(() => _role = s.first),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _envoi ? null : _valider,
            child: _envoi
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                : const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
