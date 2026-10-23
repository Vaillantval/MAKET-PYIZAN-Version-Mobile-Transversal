import '../../../shared/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/logo_anime.dart';
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
      afficherMessage(
          context, ref.read(authProvider).error ?? 'Erreur de connexion',
          succes: false);
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
                const SizedBox(height: 32),

                // Logo + Titre
                Center(
                  child: Column(
                    children: [
                      LogoAnime(
                          taille: 96,
                          rayon: 28,
                          bordure: Border.all(color: AppColors.grisBord)),
                      const SizedBox(height: 16),
                      const Text.rich(
                        TextSpan(children: [
                          TextSpan(text: 'Makèt ',
                              style: TextStyle(color: AppColors.vertFonce)),
                          TextSpan(text: 'Peyizan',
                              style: TextStyle(color: AppColors.vertVif)),
                        ]),
                        style: TextStyle(
                          fontSize:    30,
                          fontWeight:  FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Sòti nan jaden rive lakay, manje m se medikaman m',
                        style: TextStyle(
                          fontSize: 13,
                          color:    AppColors.grisTexte,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Titre section
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize:   24,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.noir,
                    letterSpacing: -0.4,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/mot-de-passe-oublie'),
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: AppColors.grisTexte),
                    ),
                  ),
                ),
                // Agents (caisse, collecte) créés par l'administration : pas
                // de mot de passe tant que le lien de l'email n'est pas ouvert
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.mark_email_read_outlined,
                          size: 18, color: AppColors.grisTexte),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Première connexion ? Choisissez votre mot de passe '
                          'via le lien reçu par email (ou « Mot de passe '
                          'oublié ? » si vous ne le retrouvez pas).',
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.grisTexte, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

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
                // (en gardant l'écran où revenir après connexion)
                Center(
                  child: TextButton(
                    onPressed: () {
                      final from = GoRouterState.of(context).uri.queryParameters['from'];
                      context.go(Uri(path: '/register',
                          queryParameters: from == null ? null : {'from': from}).toString());
                    },
                    child: const Text(
                      'Pas de compte ? S\'inscrire',
                      style: TextStyle(color: AppColors.vertVif),
                    ),
                  ),
                ),
                // Parcourir la boutique sans compte
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/acheteur/accueil'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.grisTexte),
                    child: const Text('Continuer sans compte'),
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
