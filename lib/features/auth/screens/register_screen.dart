import '../../../shared/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/geo_selector.dart';
import '../../entreprise/widgets/entreprise_form_fields.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _usernameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _telCtrl       = TextEditingController();
  final _parrainageCtrl = TextEditingController();
  // Acheteur
  final _nomOrgCtrl = TextEditingController();
  // Entreprise (optionnelle) : tout compte peut acheter ; vendre passe par
  // une entreprise, créée ici ou plus tard depuis le Profil.
  final _entreprise = EntrepriseFormController();

  bool    _vend         = false;
  bool    _obscure      = true;
  String? _geoDept;
  String? _typeAcheteur;

  static const _typesAcheteur = [
    ('particulier', 'Particulier'),
    ('grossiste',   'Grossiste'),
    ('detaillant',  'Détaillant'),
    ('cooperative', 'Coopérative'),
    ('institution', 'Institution'),
    ('restaurant',  'Restaurant'),
  ];

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _telCtrl.dispose();
    _parrainageCtrl.dispose();
    _nomOrgCtrl.dispose();
    _entreprise.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Le backend refuse de toute façon une entreprise sans géo, mais on
    // évite l'aller-retour réseau en le signalant tout de suite.
    final erreurGeo = _vend ? _entreprise.valider() : null;
    if (erreurGeo != null) {
      afficherMessage(context, erreurGeo, succes: false);
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
      username:   _usernameCtrl.text.trim(),
      email:      _emailCtrl.text.trim(),
      password:   _passwordCtrl.text,
      firstName:  _firstNameCtrl.text.trim(),
      lastName:   _lastNameCtrl.text.trim(),
      telephone:  _telCtrl.text.trim(),
      codeParrainage: _parrainageCtrl.text.trim().isEmpty
          ? null : _parrainageCtrl.text.trim(),
      entreprise:  _vend ? _entreprise.toJson() : null,
      departement: (_geoDept ?? '').isNotEmpty ? _geoDept : null,
      typeAcheteur: _typeAcheteur,
      nomOrganisation: _nomOrgCtrl.text.trim().isNotEmpty
          ? _nomOrgCtrl.text.trim() : null,
    );
    if (!success && mounted) {
      afficherMessage(
          context, ref.read(authProvider).error ?? 'Erreur d\'inscription',
          succes: false);
    }
  }

  /// Profil acheteur (tous optionnels) : géo (département seul) + type.
  /// Réutilise GeoSelector (déjà câblé sur l'écran Adresses) plutôt que
  /// d'en recréer un.
  Widget _buildChampsAcheteur() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localisation (optionnel)',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GeoSelector(
          key: const ValueKey('geo-acheteur'),
          showCommuneEtSection: false,
          onChanged: (dept, commune, section) => setState(() => _geoDept = dept),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _typeAcheteur,
          items: _typesAcheteur.map((t) => DropdownMenuItem(
            value: t.$1,
            child: Text(t.$2),
          )).toList(),
          onChanged: (v) => setState(() => _typeAcheteur = v),
          decoration: const InputDecoration(
            labelText:  'Type d\'acheteur (optionnel)',
            prefixIcon: Icon(Icons.storefront_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nomOrgCtrl,
          decoration: const InputDecoration(
            labelText:  'Nom de l\'organisation (optionnel)',
            prefixIcon: Icon(Icons.apartment_outlined),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Inscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _versConnexion(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Champs
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText:  'Nom d\'utilisateur',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText:  'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v?.contains('@') == false
                      ? 'Email invalide' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller:   _telCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText:  'Téléphone (+509...)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller:  _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText:  'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) < 8
                      ? 'Min. 8 caractères' : null,
                ),
                const SizedBox(height: 20),

                _buildChampsAcheteur(),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _parrainageCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText:  'Code de parrainage (optionnel)',
                    prefixIcon: Icon(Icons.card_giftcard_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Vendre : créer son entreprise dès l'inscription
                Material(
                  color: AppColors.blanc,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: SwitchListTile(
                    value:     _vend,
                    onChanged: (v) => setState(() => _vend = v),
                    activeThumbColor: AppColors.vertFonce,
                    title: const Text('Je vends aussi mes produits',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text(
                      'Créer mon entreprise (producteur, fournisseur ou '
                      'entreprise) — validée par notre équipe.'),
                  ),
                ),
                if (_vend) ...[
                  const SizedBox(height: 16),
                  EntrepriseFormFields(controller: _entreprise),
                ],
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  child: isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2,
                          ),
                        )
                      : const Text('S\'inscrire'),
                ),

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => _versConnexion(context),
                    child: const Text(
                      'Déjà un compte ? Se connecter',
                      style: TextStyle(color: AppColors.vertVif),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Retour à la connexion en gardant l'écran où revenir ensuite.
void _versConnexion(BuildContext context) {
  final from = GoRouterState.of(context).uri.queryParameters['from'];
  context.go(Uri(path: '/login',
      queryParameters: from == null ? null : {'from': from}).toString());
}
