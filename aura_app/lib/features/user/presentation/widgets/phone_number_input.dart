import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/ui/responsive/responsive.dart';

class PhoneNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final Responsive responsive;
  final String? errorText;
  final Function(String)? onChanged;
  final bool readOnly;
  final bool showVerifiedBadge;

  const PhoneNumberInput({
    super.key,
    required this.controller,
    required this.responsive,
    this.errorText,
    this.onChanged,
    this.readOnly = false,
    this.showVerifiedBadge = false,
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
              controller: controller,
              keyboardType: TextInputType.phone,
              cursorColor: Colors.white,
              readOnly: readOnly,
              onChanged: onChanged,
              style: TextStyle(color: Colors.white, fontSize: fontSize),
              maxLength: 10,
              decoration: InputDecoration(
                counterText: "",
                hintText: "Mobile Number",
                hintStyle: TextStyle(color: Colors.white54, fontSize: fontSize),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: responsive.w(3)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_outlined, color: Colors.white70),
                      SizedBox(width: responsive.w(2)),
                      Text(
                        "+91",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: fontSize,
                        ),
                      ),
                      SizedBox(width: responsive.w(1)),
                    ],
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
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
