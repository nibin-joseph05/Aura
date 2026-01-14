import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../ui/responsive/responsive.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final double? maxHeight;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.maxHeight,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double? maxHeight,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AppBottomSheet(title: title, maxHeight: maxHeight, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? mediaQuery.size.height * 0.85,
      ),
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius(24)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: responsive.space(12)),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null) ...[
              SizedBox(height: responsive.space(16)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.space(24)),
                child: Text(
                  title!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.text(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            SizedBox(height: responsive.space(16)),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
