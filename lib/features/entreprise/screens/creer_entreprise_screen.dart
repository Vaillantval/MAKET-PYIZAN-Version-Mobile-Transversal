import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../providers/entreprise_service.dart';
import '../widgets/entreprise_form_fields.dart';
import '../widgets/espace_entreprise.dart';

/// Création d'une entreprise depuis l'espace acheteur. Le compte en devient
/// propriétaire ; l'entreprise reste en attente jusqu'à validation admin.
class CreerEntrepriseScreen extends ConsumerStatefulWidget {
  const CreerEntrepriseScreen({super.key});

  @override
  ConsumerState<CreerEntrepriseScreen> createState() =>
      _CreerEntrepriseScreenState();
}

class _CreerEntrepriseScreenState extends ConsumerState<CreerEntrepriseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _form    = EntrepriseFormController();
  bool _envoi    = false;

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    if (!_formKey.currentState!.validate()) return;
    final erreurGeo = _form.valider();
    if (erreurGeo != null) {
      _snack(erreurGeo, AppColors.rouge);
      return;
    }

    setState(() => _envoi = true);
    try {
      final data = await ref.read(entrepriseServiceProvider).creer(_form.toJson());
      // Recharger le profil : la nouvelle appartenance apparaît dans /me
      await ref.read(authProvider.notifier).rafraichirProfil();
      if (!mounted) return;
      final entreprises = ref.read(authProvider).user?.entreprises ?? const [];
      final creee = entreprises.where((e) => e.id == data['id']).firstOrNull;
      _snack('Entreprise créée — en attente de validation par notre équipe.',
          AppColors.vertVif);
      if (creee != null) {
        await entrerDansEntreprise(context, ref, creee);
      } else {
        Navigator.of(context).pop();
      }
    } on EntrepriseException catch (e) {
      _snack(e.message, AppColors.rouge);
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  void _snack(String message, Color couleur) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: couleur),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Créer une entreprise')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:        AppColors.jauneClair,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Vous en serez propriétaire. Votre entreprise pourra '
                    'vendre dès sa validation par notre équipe ; vous '
                    'pourrez ensuite y ajouter d\'autres membres.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
                EntrepriseFormFields(controller: _form),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _envoi ? null : _creer,
                  child: _envoi
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Créer l\'entreprise'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
