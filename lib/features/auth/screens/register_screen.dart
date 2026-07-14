import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

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
  String _role         = 'acheteur';
  bool   _obscure      = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _telCtrl.dispose();
    _parrainageCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).register(
      username:   _usernameCtrl.text.trim(),
      email:      _emailCtrl.text.trim(),
      password:   _passwordCtrl.text,
      role:       _role,
      firstName:  _firstNameCtrl.text.trim(),
      lastName:   _lastNameCtrl.text.trim(),
      telephone:  _telCtrl.text.trim(),
      codeParrainage: _parrainageCtrl.text.trim().isEmpty
          ? null : _parrainageCtrl.text.trim(),
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(authProvider).error ?? 'Erreur d\'inscription'
          ),
          backgroundColor: AppColors.rouge,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: AppColors.vertFonce,
        foregroundColor: AppColors.blanc,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
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
                // Sélecteur de rôle
                const Text(
                  'Je suis...',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _RoleChip(
                      label:     '🛒 Acheteur',
                      value:     'acheteur',
                      selected:  _role == 'acheteur',
                      onTap:     () => setState(() => _role = 'acheteur'),
                    ),
                    const SizedBox(width: 12),
                    _RoleChip(
                      label:     '🌾 Producteur',
                      value:     'producteur',
                      selected:  _role == 'producteur',
                      onTap:     () => setState(() => _role = 'producteur'),
                    ),
                  ],
                ),

                if (_role == 'producteur')
                  Container(
                    margin:  const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:        AppColors.jauneClair,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '⚠️ Votre compte producteur sera en attente de validation par notre équipe.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),

                const SizedBox(height: 24),

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
                const SizedBox(height: 16),

                TextFormField(
                  controller: _parrainageCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText:  'Code de parrainage (optionnel)',
                    prefixIcon: Icon(Icons.card_giftcard_outlined),
                  ),
                ),
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
                    onPressed: () => context.go('/login'),
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

class _RoleChip extends StatelessWidget {
  final String  label;
  final String  value;
  final bool    selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:        selected ? AppColors.vertFonce : AppColors.blanc,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(
            color: selected ? AppColors.vertFonce : const Color(0xFFDDDDDD),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:      selected ? AppColors.blanc : AppColors.noir,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
