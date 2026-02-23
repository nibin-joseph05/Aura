import 'package:flutter/material.dart';
import '../../theme/app_dimensions.dart';
import '../../ui/responsive/responsive.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int index;
  final Function(String) onChanged;
  final Responsive responsive;
  final bool hasError;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.index,
    required this.onChanged,
    required this.responsive,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final boxSize = responsive.isTablet ? 60.0 : 50.0;
    final boxHeight = responsive.isTablet ? 70.0 : 60.0;
    final fontSize = responsive.isTablet ? 26.0 : 22.0;

    return SizedBox(
      width: boxSize,
      height: boxHeight,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        cursorColor: Colors.white,
        style: TextStyle(
          fontSize: fontSize,
          color: hasError ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: hasError
                  ? Colors.redAccent.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.3),
              width: hasError ? 1.5 : 1.2,
            ),
            borderRadius: BorderRadius.circular(
              responsive.radius(AppDimensions.radiusL),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: hasError ? Colors.redAccent : Colors.blueAccent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(
              responsive.radius(AppDimensions.radiusL),
            ),
          ),
          filled: true,
          fillColor: hasError
              ? Colors.redAccent.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.05),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
