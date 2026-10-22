import '../ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/api_error.dart';

/// POST /api/auth/change-password/ {current_password, new_password}.
Future<void> afficherChangementMotDePasse(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _ChangerMotDePasseSheet(),
  );
}

class _ChangerMotDePasseSheet extends ConsumerStatefulWidget {
  const _ChangerMotDePasseSheet();

  @override
  ConsumerState<_ChangerMotDePasseSheet> createState() =>
      _ChangerMotDePasseSheetState();
}

class _ChangerMotDePasseSheetState extends ConsumerState<_ChangerMotDePasseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _actuel  = TextEditingController();
  final _nouveau = TextEditingController();
  bool    _envoi  = false;
  String? _erreur;

  @override
  void dispose() {
    _actuel.dispose();
    _nouveau.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _envoi = true; _erreur = null; });
    try {
      await ref.read(apiClientProvider).post(
        AppEndpoints.changePassword,
        data: {
          'current_password': _actuel.text,
          'new_password':     _nouveau.text,
        },
      );
      if (!mounted) return;
      afficherMessage(context, 'Mot de passe modifié');
      Navigator.pop(context);
    } catch (e) {
      setState(() => _erreur =
          messageErreurApi(e, 'Impossible de modifier le mot de passe.'));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Changer le mot de passe', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.vertFonce)),
            const SizedBox(height: 16),
            TextFormField(
              controller:  _actuel,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe actuel'),
              validator: (v) => (v ?? '').isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller:  _nouveau,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe'),
              validator: (v) =>
                  (v?.length ?? 0) < 8 ? 'Min. 8 caractères' : null,
            ),
            if (_erreur != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_erreur!,
                  style: const TextStyle(color: AppColors.rouge)),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _envoi ? null : _valider,
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
  }
}
