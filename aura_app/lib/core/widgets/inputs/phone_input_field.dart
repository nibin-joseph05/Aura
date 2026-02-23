import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_dimensions.dart';
import '../../ui/responsive/responsive.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final Responsive responsive;
  final Animation<Offset> slideAnimation;
  final Animation<double> opacityAnimation;
  final String? errorText;
  final Function(String)? onChanged;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.responsive,
    required this.slideAnimation,
    required this.opacityAnimation,
    this.errorText,
    this.onChanged,
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

    final hasError = errorText != null && errorText!.isNotEmpty;

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              cursorColor: Colors.white,
              onChanged: onChanged,
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
                  color: hasError ? Colors.redAccent : Colors.white70,
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
                    color: hasError
                        ? Colors.redAccent
                        : Colors.white.withValues(alpha: 0.35),
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
                    ? Colors.redAccent.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.05),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: responsive.space(AppDimensions.paddingM),
                  vertical: responsive.space(AppDimensions.paddingM),
                ),
              ),
            ),
            if (hasError) ...[
              SizedBox(height: responsive.h(0.5)),
              Padding(
                padding: EdgeInsets.only(left: responsive.w(3)),
                child: Text(
                  errorText!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
