import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

Future<String?> showPaiementActionSheet(
  BuildContext context, {
  required String reference,
}) async {
  return showModalBottomSheet<String>(
    context:       context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paiement $reference',
            style: const TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w800,
              color:      AppColors.vertFonce,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.check_circle,
                color: AppColors.vertVif),
            title: const Text('Confirmer'),
            onTap: () => Navigator.pop(context, 'confirmer'),
          ),
          ListTile(
            leading: const Icon(Icons.cancel,
                color: AppColors.rouge),
            title: const Text('Rejeter'),
            onTap: () => Navigator.pop(context, 'rejeter'),
          ),
        ],
      ),
    ),
  );
}
