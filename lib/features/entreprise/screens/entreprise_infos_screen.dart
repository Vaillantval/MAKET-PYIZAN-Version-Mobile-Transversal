import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/entreprise_provider.dart';
import '../providers/entreprise_service.dart';

final _ficheEntrepriseProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  ref.watch(entrepriseActiveIdProvider);
  return ref.read(entrepriseServiceProvider).profil();
});

/// Fiche de l'entreprise active (GET /api/auth/producteur/profil/).
/// Modifiable par ses propriétaires uniquement (PATCH réservé côté backend).
class EntrepriseInfosScreen extends ConsumerStatefulWidget {
  const EntrepriseInfosScreen({super.key});

  @override
  ConsumerState<EntrepriseInfosScreen> createState() =>
      _EntrepriseInfosScreenState();
}

class _EntrepriseInfosScreenState extends ConsumerState<EntrepriseInfosScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nom         = TextEditingController();
  final _telephone   = TextEditingController();
  final _adresse     = TextEditingController();
  final _description = TextEditingController();
  bool _rempli = false;
  bool _envoi  = false;

  @override
  void dispose() {
    for (final c in [_nom, _telephone, _adresse, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  void _remplir(Map<String, dynamic> f) {
    if (_rempli) return;
    _rempli = true;
    _nom.text         = f['nom'] as String? ?? '';
    _telephone.text   = f['telephone_entreprise'] as String? ?? '';
    _adresse.text     = f['adresse_complete'] as String? ?? '';
    _description.text = f['description'] as String? ?? '';
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _envoi = true);
    try {
      await ref.read(entrepriseServiceProvider).modifierProfil({
        'nom':                  _nom.text.trim(),
        'telephone_entreprise': _telephone.text.trim(),
        'adresse_complete':     _adresse.text.trim(),
        'description':          _description.text.trim(),
      });
      // Le nom affiché dans /me (entreprises) a pu changer
      await ref.read(authProvider.notifier).rafraichirProfil();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Modifications enregistrées'),
        backgroundColor: AppColors.vertVif,
      ));
      Navigator.of(context).pop();
    } on EntrepriseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message), backgroundColor: AppColors.rouge));
      }
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fiche   = ref.watch(_ficheEntrepriseProvider);
    final proprio = ref.watch(entrepriseActiveProvider)?.estProprietaire ?? false;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Mon entreprise')),
      body: fiche.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.vertVif)),
        error: (e, _) => Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(e.toString(), textAlign: TextAlign.center),
        )),
        data: (f) {
          _remplir(f);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Ligne('Code', f['code_producteur']),
                  _Ligne('Type', f['type_label']),
                  _Ligne('Statut', f['statut_label']),
                  _Ligne('Localisation',
                      [f['commune'], f['departement_label']]
                          .where((s) => s != null && '$s'.isNotEmpty)
                          .join(', ')),
                  if ((f['note_admin'] as String? ?? '').isNotEmpty)
                    _Ligne('Note de l\'équipe', f['note_admin']),
                  const SizedBox(height: 16),
                  if (!proprio)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Seuls les propriétaires peuvent modifier la fiche.',
                        style: TextStyle(fontSize: 12, color: AppColors.grisTexte),
                      ),
                    ),
                  TextFormField(
                    controller: _nom,
                    enabled:    proprio,
                    decoration: const InputDecoration(labelText: 'Nom de l\'entreprise'),
                    validator:  (v) => (v ?? '').trim().isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller:   _telephone,
                    enabled:      proprio,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Téléphone professionnel'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _adresse,
                    enabled:    proprio,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _description,
                    enabled:    proprio,
                    maxLines:   4,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 24),
                  if (proprio)
                    ElevatedButton(
                      onPressed: _envoi ? null : _enregistrer,
                      child: _envoi
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                          : const Text('Enregistrer'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  final String  label;
  final dynamic valeur;
  const _Ligne(this.label, this.valeur);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label,
          style: const TextStyle(fontSize: 13, color: AppColors.grisTexte))),
        Expanded(child: Text('${valeur ?? '—'}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    ),
  );
}
