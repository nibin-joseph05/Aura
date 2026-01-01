import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/asset_constants.dart';

class AppSnackbar {
  static void showError({
    required BuildContext context,
    required String message,
    int durationSeconds = 3,
  }) {
    _show(context, message, AppColors.error);
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    int durationSeconds = 2,
  }) {
    _show(context, message, AppColors.success);
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    int durationSeconds = 3,
  }) {
    _show(context, message, AppColors.primary);
  }

  static void showWarning({
    required BuildContext context,
    required String message,
  }) {
    _show(context, message, AppColors.warning);
  }

  static DateTime? _lastShown;
  static const Duration _cooldown = Duration(milliseconds: 1200);

  static void _show(BuildContext context, String message, Color color) {
    final now = DateTime.now();

    if (_lastShown != null && now.difference(_lastShown!) < _cooldown) {
      return;
    }
    _lastShown = now;

    final textTheme = Theme.of(context).textTheme;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      elevation: 0,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      content: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0.92, end: 1.0),
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.42),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      AssetConstants.auraAppIconNew,
                      height: 28,
                      width: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
