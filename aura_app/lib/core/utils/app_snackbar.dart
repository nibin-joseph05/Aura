import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppSnackbar {
  static void showError({
    required BuildContext context,
    required String message,
    int durationSeconds = 3,
  }) {
    _show(
      context,
      message,
      AppColors.error,
      durationSeconds,
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    int durationSeconds = 2,
  }) {
    _show(
      context,
      message,
      AppColors.success,
      durationSeconds,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    int durationSeconds = 3,
  }) {
    _show(
      context,
      message,
      AppColors.primary,
      durationSeconds,
    );
  }

  static void _show(
      BuildContext context,
      String message,
      Color color,
      int durationSeconds,
      ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      elevation: 8,
      backgroundColor: color.withOpacity(0.95),
      duration: Duration(seconds: durationSeconds),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Text(
        message,
        style: AppTextStyles.textTheme.bodyMedium!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
