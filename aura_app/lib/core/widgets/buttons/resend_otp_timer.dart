import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/responsive/responsive.dart';

class ResendOtpTimer extends ConsumerWidget {
  final int timerSeconds;
  final bool canResend;
  final VoidCallback onResend;

  const ResendOtpTimer({
    super.key,
    required this.timerSeconds,
    required this.canResend,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final textSize = responsive.isTablet ? 15.0 : 13.0;
    final buttonSize = responsive.isTablet ? 17.0 : 15.0;

    return Column(
      children: [
        Text(
          canResend
              ? "Didn't receive the code?"
              : "Resend OTP in $timerSeconds seconds",
          style: TextStyle(color: Colors.white70, fontSize: textSize),
          textAlign: TextAlign.center,
        ),
        if (canResend)
          TextButton(
            onPressed: onResend,
            child: Text(
              "Resend OTP",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: buttonSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
