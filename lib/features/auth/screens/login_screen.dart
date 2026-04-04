import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(authProvider).error ?? 'Erreur de connexion'
          ),
          backgroundColor: AppColors.rouge,
        ),
      );
    }
    // La redirection est gérée par go_router
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo + Titre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width:  80,
                        height: 80,
                        decoration: BoxDecoration(
                          color:        AppColors.vertFonce,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          size:  48,
                          color: AppColors.jaune,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Makèt Peyizan',
                        style: TextStyle(
                          fontFamily:  'PlayfairDisplay',
                          fontSize:    28,
                          fontWeight:  FontWeight.w900,
                          color:       AppColors.vertFonce,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Titre section
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize:   22,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.noir,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(
                    fontSize: 14,
                    color:    AppColors.grisTexte,
                  ),
                ),
                const SizedBox(height: 28),

                // Email
                TextFormField(
                  controller:  _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText:   'Email',
                    prefixIcon:  Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v?.isEmpty == true
                      ? 'Email requis' : null,
                ),
                const SizedBox(height: 16),

                // Mot de passe
                TextFormField(
                  controller:  _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText:   'Mot de passe',
                    prefixIcon:  const Icon(Icons.lock_outline),
                    suffixIcon:  IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v?.isEmpty == true
                      ? 'Mot de passe requis' : null,
                ),
                const SizedBox(height: 28),

                // Bouton connexion
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width:  20,
                          child:  CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Se connecter'),
                ),
                const SizedBox(height: 16),

                // Lien inscription
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text(
                      'Pas de compte ? S\'inscrire',
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
