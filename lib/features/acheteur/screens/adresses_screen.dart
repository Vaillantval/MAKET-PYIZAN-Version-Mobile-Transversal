import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/adresse.dart';
import '../providers/adresse_provider.dart';
import '../../../shared/widgets/geo_selector.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/ui/ui.dart';

class AdressesScreen extends ConsumerWidget {
  const AdressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes adresses')),
      body: state.when(
        loading: () => const LoadingWidget(message: 'Chargement...'),
        error: (e, _) => ErreurChargement(e),
        data: (adresses) {
          if (adresses.isEmpty) {
            return EmptyState(
              icone: Icons.place_outlined,
              titre: 'Aucune adresse',
              description: 'Ajoutez votre première adresse.',
              boutonLabel: 'Ajouter une adresse',
              onBouton: () => _afficherModalCreation(context, ref),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: adresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final addr = adresses[i];
              return Surface(
                padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
                child: Row(
                  children: [
                    TuileIcone(
                      addr.isDefault ? Icons.home_rounded : Icons.place_outlined,
                      couleur: addr.isDefault ? AppColors.vertFonce : AppColors.grisTexte,
                      taille: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(addr.rue,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('${addr.commune}, ${addr.departementLabel}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.grisTexte,
                            ),
                          ),
                          if (addr.isDefault) ...[
                            const SizedBox(height: 6),
                            const PuceStatut('Par défaut', couleur: AppColors.vertVif),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: AppColors.grisTexte),
                      onSelected: (v) {
                        if (v == 'defaut') {
                          ref.read(adressesProvider.notifier).setDefault(addr.id);
                        } else {
                          _confirmerSuppression(context, ref, addr.id);
                        }
                      },
                      itemBuilder: (_) => [
                        if (!addr.isDefault)
                          const PopupMenuItem(
                              value: 'defaut', child: Text('Définir par défaut')),
                        const PopupMenuItem(
                          value: 'supprimer',
                          child: Text('Supprimer',
                              style: TextStyle(color: AppColors.rouge)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _afficherModalCreation(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adresse'),
      ),
    );
  }

  void _confirmerSuppression(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (dc) => AlertDialog(
        title: const Text('Supprimer cette adresse ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dc),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dc);
              ref.read(adressesProvider.notifier).supprimer(id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.rouge),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _afficherModalCreation(
    BuildContext context,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ModalCreationAdresse(ref: ref),
    );
  }
}

class _ModalCreationAdresse extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _ModalCreationAdresse({required this.ref});

  @override
  ConsumerState<_ModalCreationAdresse> createState() =>
      _ModalCreationAdresseState();
}

class _ModalCreationAdresseState
    extends ConsumerState<_ModalCreationAdresse> {
  static const _libelles = ['Domicile', 'Bureau', 'Autre'];

  String _libelle = 'Domicile';
  String _dept    = '';
  String _commune = '';
  String _section = '';
  final _rueCtrl     = TextEditingController();
  final _nomCtrl     = TextEditingController();
  final _telCtrl     = TextEditingController();
  final _detailsCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Destinataire prérempli avec le compte connecté
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nomCtrl.text = '${user.firstName} ${user.lastName}'.trim();
      _telCtrl.text = user.telephone;
      // Département donné à l'inscription, présélectionné (modifiable)
      _deptProfil = _slugDepartement(user.departement);
      _dept = _deptProfil;
    }
  }

  /// Département du profil au format du serveur (« Sud-Est » → « sud_est »).
  String _deptProfil = '';

  static String _slugDepartement(String v) => v
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r"[\s'\-]+"), '_');

  @override
  void dispose() {
    _rueCtrl.dispose();
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    if (_dept.isEmpty || _commune.isEmpty ||
        _rueCtrl.text.trim().isEmpty || _nomCtrl.text.trim().isEmpty) {
      afficherMessage(context,
          'Renseignez le destinataire, le département, la commune et la rue.',
          succes: false);
      return;
    }

    setState(() => _isLoading = true);
    final premiere = (widget.ref.read(adressesProvider).valueOrNull ?? const []).isEmpty;
    final erreur = await widget.ref.read(adressesProvider.notifier).creer({
      'libelle':           _libelle,
      'nom_complet':       _nomCtrl.text.trim(),
      'telephone':         _telCtrl.text.trim(),
      'rue':               _rueCtrl.text.trim(),
      'commune':           _commune,
      'departement':       _dept,
      'section_communale': _section,
      'details':           _detailsCtrl.text.trim(),
      // La première adresse devient l'adresse par défaut
      if (premiere) 'is_default': true,
    });
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (erreur == null) {
      // Autre département que celui du profil : il remplace celui de
      // l'inscription
      if (_dept != _deptProfil) {
        widget.ref.read(authProvider.notifier).mettreAJourDepartement(_dept);
      }
      afficherMessage(context, 'Adresse ajoutée');
      Navigator.pop(context);
    } else {
      afficherMessage(context, erreur, succes: false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajouter une adresse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Libellé
            Wrap(
              spacing: 8,
              children: [
                for (final l in _libelles)
                  ChoiceChip(
                    label: Text(l),
                    selected: _libelle == l,
                    onSelected: (_) => setState(() => _libelle = l),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Destinataire
            TextField(
              controller: _nomCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom du destinataire',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone (facultatif)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Sélecteur géographique
            GeoSelector(
              initialDept: _deptProfil.isEmpty ? null : _deptProfil,
              onChanged: (dept, commune, section) {
                setState(() {
                  _dept = dept;
                  _commune = commune;
                  _section = section;
                });
              },
            ),
            const SizedBox(height: 16),

            // Rue
            TextField(
              controller: _rueCtrl,
              decoration: const InputDecoration(
                labelText: 'Rue / Lieu-dit',
                prefixIcon: Icon(Icons.signpost_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Instructions de livraison (facultatif)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 20),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isLoading ? null : _creer,
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Ajouter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
