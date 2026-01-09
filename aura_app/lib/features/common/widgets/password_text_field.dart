import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/ui/responsive/responsive.dart';

class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final Responsive responsive;
  final String hint;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? errorText;
  final Function(String)? onChanged;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.responsive,
    required this.hint,
    required this.obscureText,
    required this.onToggleVisibility,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = responsive.isTablet ? 18.0 : 16.0;
    final radius = responsive.radius(AppDimensions.radiusL);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          cursorColor: Colors.white,
          onChanged: onChanged,
          style: TextStyle(color: Colors.white, fontSize: fontSize),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white54, fontSize: fontSize),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: errorText == null ? Colors.white70 : Colors.redAccent,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: onToggleVisibility,
            ),
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
                color: Colors.white.withValues(alpha: 0.25),
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
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: responsive.h(0.5)),
          Padding(
            padding: EdgeInsets.only(left: responsive.w(4)),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
