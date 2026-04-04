import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

Future<String?> showStatutSelector(
  BuildContext context, {
  required List<(String, String)> options,
  String? titre,
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
          if (titre != null) ...[
            Text(titre,
              style: const TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w800,
                color:      AppColors.vertFonce,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...options.map((o) => ListTile(
            title: Text(o.$2),
            onTap: () => Navigator.pop(context, o.$1),
          )),
        ],
      ),
    ),
  );
}
