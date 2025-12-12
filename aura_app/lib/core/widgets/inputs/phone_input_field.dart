import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/responsive.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final Responsive responsive;
  final Animation<Offset> slideAnimation;
  final Animation<double> opacityAnimation;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.responsive,
    required this.slideAnimation,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final labelSize = responsive.isLargeTablet
        ? 18.0
        : responsive.isTablet
        ? 16.0
        : 14.0;

    final inputSize = responsive.isLargeTablet
        ? 20.0
        : responsive.isTablet
        ? 18.0
        : 16.0;

    final prefixSize = responsive.isLargeTablet
        ? 20.0
        : responsive.isTablet
        ? 18.0
        : 16.0;

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          cursorColor: Colors.white,
          style: TextStyle(
            color: Colors.white,
            fontSize: inputSize,
            letterSpacing: 0.5,
          ),
          maxLength: 10,
          decoration: InputDecoration(
            counterText: "",
            labelText: "Mobile Number",
            labelStyle: TextStyle(
              color: Colors.white70,
              fontSize: labelSize,
            ),
            prefixText: "+91  ",
            prefixStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: prefixSize,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.35),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(
                responsive.radius(AppDimensions.radiusL),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.blueAccent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(
                responsive.radius(AppDimensions.radiusL),
              ),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.space(AppDimensions.paddingM),
              vertical: responsive.space(AppDimensions.paddingM),
            ),
          ),
        ),
      ),
    );
  }
}