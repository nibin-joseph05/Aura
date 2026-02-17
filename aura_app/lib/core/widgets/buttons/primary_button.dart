import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../ui/responsive/responsive.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Responsive responsive;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final buttonFontSize = responsive.isLargeTablet
        ? 24.0
        : responsive.isTablet
        ? 21.0
        : 18.0;

    final buttonPadding = responsive.isLargeTablet
        ? 22.0
        : responsive.isTablet
        ? 20.0
        : 16.0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: buttonPadding),
          backgroundColor: AppColors.primary,
          elevation: AppDimensions.elevationL,
          shadowColor: AppColors.primary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              responsive.radius(AppDimensions.radiusL),
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: buttonFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
