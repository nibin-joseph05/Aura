import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../ui/responsive/responsive.dart';

class FloatingActionBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FloatingActionBtn({
    super.key,
    required this.onPressed,
    this.label,
    this.icon = Icons.add_rounded,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final bgColor = backgroundColor ?? AppColors.accent;
    final fgColor = foregroundColor ?? Colors.white;

    if (label != null) {
      return FloatingActionButton.extended(
        heroTag: 'fab_${label.hashCode}',
        onPressed: onPressed,
        backgroundColor: bgColor,
        icon: Icon(icon, color: fgColor, size: responsive.icon(22)),
        label: Text(
          label!,
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.w600,
            fontSize: responsive.text(14),
          ),
        ),
      );
    }

    return FloatingActionButton(
      heroTag: 'fab_${icon.hashCode}',
      onPressed: onPressed,
      backgroundColor: bgColor,
      child: Icon(icon, color: fgColor, size: responsive.icon(26)),
    );
  }
}
