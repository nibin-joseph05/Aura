import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/ui/responsive/responsive.dart';

class DateOfBirthPicker extends StatelessWidget {
  final TextEditingController controller;
  final Responsive responsive;
  final String? errorText;
  final Function(String) onDateSelected;

  const DateOfBirthPicker({
    super.key,
    required this.controller,
    required this.responsive,
    required this.onDateSelected,
    this.errorText,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.splashDark,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.splashDark,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final dobString = DateFormat('yyyy-MM-dd').format(picked);
      controller.text = DateFormat('MMM dd, yyyy').format(picked);
      onDateSelected(dobString);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fontSize = responsive.isTablet ? 18.0 : 16.0;
    final radius = responsive.radius(AppDimensions.radiusL);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(4),
              vertical: responsive.h(2.1),
            ),
            decoration: BoxDecoration(
              color: AppColors.inputFill(brightness),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: errorText != null
                    ? Colors.redAccent
                    : AppColors.inputBorder(brightness),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cake_outlined,
                  color: errorText != null
                      ? Colors.redAccent
                      : AppColors.onSurfaceMuted(brightness),
                ),
                SizedBox(width: responsive.w(3)),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Date of Birth' : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? AppColors.onSurfaceFaint(brightness)
                          : AppColors.onSurface(brightness),
                      fontSize: fontSize,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.onSurfaceMuted(brightness),
                  size: 20,
                ),
              ],
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
