import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Bottom sheet pour les actions sur une commande producteur
class CommandeActionSheet extends StatelessWidget {
  final String numeroCommande;
  final String statut;
  final Future<void> Function(String action, {String motif}) onAction;

  const CommandeActionSheet({
    required this.numeroCommande,
    required this.statut,
    required this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color:        Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Actions — $numeroCommande',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize:   16,
              color:      AppColors.vertFonce,
            ),
          ),
          const Divider(height: 24),
          if (statut == 'en_attente') ...[
            _ActionTile(
              icon:  Icons.check_circle_outline,
              label: 'Confirmer',
              color: AppColors.vertVif,
              onTap: () {
                Navigator.pop(context);
                onAction('confirmer');
              },
            ),
            _ActionTile(
              icon:  Icons.cancel_outlined,
              label: 'Refuser',
              color: AppColors.rouge,
              onTap: () {
                Navigator.pop(context);
                onAction('annuler', motif: '');
              },
            ),
          ],
          if (statut == 'confirmee')
            _ActionTile(
              icon:  Icons.local_shipping_outlined,
              label: 'Marquer en préparation',
              color: AppColors.orange,
              onTap: () {
                Navigator.pop(context);
                onAction('preparer');
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading:  Icon(icon, color: color),
    title:    Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    onTap:    onTap,
  );
}
