import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AdminListTile extends StatelessWidget {
  final String       title;
  final String?      subtitle;
  final Widget?      trailing;
  final Widget?      leading;
  final VoidCallback? onTap;

  const AdminListTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color:     Colors.black.withOpacity(0.05),
          blurRadius: 6,
        ),
      ],
    ),
    child: ListTile(
      leading:  leading,
      title:    Text(title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color:      AppColors.vertFonce,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color:    AppColors.grisTexte,
              ),
            )
          : null,
      trailing: trailing,
      onTap:    onTap,
      shape:    RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
