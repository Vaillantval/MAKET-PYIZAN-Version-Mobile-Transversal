import 'package:flutter/material.dart';

import '../../core/sons/sons_app.dart';
import '../ui/ui.dart';

/// Réglage « Sons de l'application » (Profil, caisse, administration).
/// Les vibrations restent actives ; les notifications push gardent leurs
/// sons, réglables dans Android.
class LigneSons extends StatelessWidget {
  const LigneSons({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: SonsApp.actifs,
        builder: (_, actifs, __) => LigneReglage(
          icone: actifs ? Icons.volume_up_outlined : Icons.volume_off_outlined,
          titre: "Sons de l'application",
          sousTitre: 'Muets en mode silencieux ou vibreur',
          onTap: () => SonsApp.activer(!actifs),
          trailing: Switch(
            value: actifs,
            onChanged: SonsApp.activer,
          ),
        ),
      );
}
