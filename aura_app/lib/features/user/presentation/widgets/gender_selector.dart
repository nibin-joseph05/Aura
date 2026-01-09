import 'package:flutter/material.dart';
import '../../../../core/ui/responsive/responsive.dart';

class GenderSelector extends StatelessWidget {
  final String selectedGender;
  final String? errorText;
  final Function(String) onGenderSelected;
  final Responsive responsive;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
    required this.responsive,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildGenderOption('Male', Icons.male),
            SizedBox(width: responsive.w(3)),
            _buildGenderOption('Female', Icons.female),
            SizedBox(width: responsive.w(3)),
            _buildGenderOption('Other', Icons.transgender),
          ],
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

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => onGenderSelected(gender),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: responsive.space(14)),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: responsive.isTablet ? 28 : 24,
              ),
              SizedBox(height: responsive.h(0.5)),
              Text(
                gender,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.isTablet ? 14 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
