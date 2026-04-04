import 'package:flutter/material.dart';
import '../../core/utils/format_utils.dart';
import '../../core/constants/app_colors.dart';

class HtgText extends StatelessWidget {
  final dynamic  montant;
  final double   fontSize;
  final FontWeight fontWeight;
  final Color    color;
  final String?  suffix;

  const HtgText(
    this.montant, {
    this.fontSize   = 16,
    this.fontWeight = FontWeight.w700,
    this.color      = AppColors.vertFonce,
    this.suffix,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Text(
    '${FormatUtils.htg(montant)}${suffix ?? ''}',
    style: TextStyle(
      fontSize:   fontSize,
      fontWeight: fontWeight,
      color:      color,
    ),
  );
}
