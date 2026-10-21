import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/ui.dart';

/// Gabarit des écrans de liste de l'admin.
///
/// Écran d'onglet : grand titre en tête. Écran ouvert depuis « Plus »
/// ([retour] renseigné) : barre d'application avec flèche de retour.
class AdminScaffold extends StatelessWidget {
  final String titre;
  final String? sousTitre;
  final String? retour;
  final Widget? filtres;
  final Widget corps;
  final List<Widget> actions;

  const AdminScaffold({
    required this.titre,
    required this.corps,
    this.sousTitre,
    this.retour,
    this.filtres,
    this.actions = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final entete = retour == null
        ? EnTeteEcran(titre, surtitre: sousTitre, actions: actions)
        : null;
    return Scaffold(
      appBar: retour == null
          ? null
          : AppBar(
              title: Text(titre),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(retour!),
              ),
              actions: actions,
            ),
      body: SafeArea(
        top: retour == null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entete != null) entete,
            if (filtres != null) ...[
              const SizedBox(height: 6),
              filtres!,
              const SizedBox(height: 6),
            ],
            Expanded(child: corps),
          ],
        ),
      ),
    );
  }
}
