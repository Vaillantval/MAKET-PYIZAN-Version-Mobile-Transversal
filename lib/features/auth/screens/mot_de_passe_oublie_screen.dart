import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/api_error.dart';

/// Mot de passe oublié, en deux étapes :
/// 1. POST /api/auth/password-reset/ {email} → email avec un code à 6 chiffres
///    (réponse identique que le compte existe ou non) ;
/// 2. POST /api/auth/password-reset/confirm/ {email, code, new_password}.
/// Le backend révoque ensuite toutes les sessions : on revient à la connexion.
class MotDePasseOublieScreen extends ConsumerStatefulWidget {
  const MotDePasseOublieScreen({super.key});

  @override
  ConsumerState<MotDePasseOublieScreen> createState() =>
      _MotDePasseOublieScreenState();
}

class _MotDePasseOublieScreenState extends ConsumerState<MotDePasseOublieScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _email     = TextEditingController();
  final _code      = TextEditingController();
  final _mdp       = TextEditingController();
  bool    _codeEnvoye = false;
  bool    _envoi      = false;
  bool    _obscure    = true;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _mdp.dispose();
    super.dispose();
  }

  Future<void> _demanderCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _envoi = true);
    try {
      final res = await ref.read(apiClientProvider).post(
        AppEndpoints.passwordReset,
        data: {'email': _email.text.trim()},
      );
      final data = res.data as Map<String, dynamic>;
      setState(() {
        _codeEnvoye = true;
        _info = (data['data'] as Map?)?['message'] as String? ??
            'Si un compte correspond à cette adresse, un code vient d\'être envoyé.';
      });
    } catch (e) {
      _erreur(messageErreurApi(e, 'Vérifiez votre connexion internet.'));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  Future<void> _confirmer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _envoi = true);
    try {
      await ref.read(apiClientProvider).post(
        AppEndpoints.passwordResetConfirm,
        data: {
          'email':        _email.text.trim(),
          'code':         _code.text.trim(),
          'new_password': _mdp.text,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Mot de passe modifié. Connectez-vous avec le nouveau.'),
        backgroundColor: AppColors.vertVif,
      ));
      context.go('/login');
    } catch (e) {
      _erreur(messageErreurApi(e, 'Code invalide ou expiré.'));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  void _erreur(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.rouge),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _codeEnvoye
                      ? (_info ?? '')
                      : 'Indiquez l\'email de votre compte : nous vous '
                        'enverrons un code pour choisir un nouveau mot de passe.',
                  style: const TextStyle(fontSize: 14, color: AppColors.grisTexte),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller:   _email,
                  enabled:      !_codeEnvoye,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText:  'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      (v ?? '').contains('@') ? null : 'Email invalide',
                ),
                if (_codeEnvoye) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller:   _code,
                    keyboardType: TextInputType.number,
                    maxLength:    6,
                    decoration: const InputDecoration(
                      labelText:  'Code reçu par email',
                      prefixIcon: Icon(Icons.pin_outlined),
                      counterText: '',
                    ),
                    validator: (v) =>
                        (v ?? '').trim().length == 6 ? null : 'Code à 6 chiffres',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller:  _mdp,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText:  'Nouveau mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        (v?.length ?? 0) < 8 ? 'Min. 8 caractères' : null,
                  ),
                ],
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _envoi
                      ? null
                      : (_codeEnvoye ? _confirmer : _demanderCode),
                  child: _envoi
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                      : Text(_codeEnvoye
                          ? 'Changer le mot de passe'
                          : 'Recevoir un code'),
                ),
                if (_codeEnvoye)
                  TextButton(
                    onPressed: _envoi ? null : _demanderCode,
                    child: const Text('Renvoyer le code',
                      style: TextStyle(color: AppColors.vertVif)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
