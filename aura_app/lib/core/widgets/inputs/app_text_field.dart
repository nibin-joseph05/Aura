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
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final bool showVerifiedBadge;
  final Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.responsive,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.showVerifiedBadge = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = responsive.isTablet ? 18.0 : 16.0;
    final radius = responsive.radius(AppDimensions.radiusL);
    final showBadge = showVerifiedBadge && readOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            TextFormField(
              enabled: enabled,
              readOnly: readOnly,
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              cursorColor: Colors.white,
              onChanged: onChanged,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                overflow: TextOverflow.ellipsis,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.white54, fontSize: fontSize),
                prefixIcon: Icon(
                  icon,
                  color: errorText == null ? Colors.white70 : Colors.redAccent,
                ),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.12),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: responsive.w(4),
                  vertical: responsive.h(2.1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: BorderSide(
                    color: showBadge
                        ? Colors.greenAccent.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: const BorderSide(
                    color: Colors.lightBlueAccent,
                    width: 1.6,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.4,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.6,
                  ),
                ),
                errorText: errorText,
                errorStyle: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ),
            if (showBadge)
              Positioned(
                top: -8,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Verified",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
