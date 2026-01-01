import 'package:flutter/material.dart';
import '../../theme/app_dimensions.dart';
import '../../ui/responsive/responsive.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final Responsive responsive;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.controller,
    required this.responsive,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = responsive.isTablet ? 18.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          responsive.radius(AppDimensions.radiusL),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white54, fontSize: fontSize),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: responsive.w(4),
            vertical: responsive.h(2),
          ),
        ),
      ),
    );
  }
}
