import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../loading/ghost_running.dart';

class ConfirmExitWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onExit;

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  const ConfirmExitWrapper({
    super.key,
    required this.child,
    required this.onExit,
    this.title = "Exit?",
    this.message =
        "If you leave now, your progress will be lost. You can complete it later.",
    this.confirmText = "Exit",
    this.cancelText = "Continue",
  });

  Future<void> _showExitDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Text(
                        cancelText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldExit == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => const GhostRunning(
          primaryMessage: "Exiting",
          secondaryMessage: "Please wait…",
        ),
      );

      await Future.delayed(const Duration(milliseconds: 200));
      await onExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: child,
    );
  }
}
