import 'package:flutter/material.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../auth/domain/models/auth_success_payload.dart';

class SuccessScreen extends StatefulWidget {
  final AuthSuccessPayload payload;

  const SuccessScreen({super.key, required this.payload});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  static const _delay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(_delay);

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.profileComplete,
      (_) => false,
      arguments: widget.payload,
    );
  }

  String get _title {
    switch (widget.payload.method) {
      case AuthMethod.phone:
        return "Phone verified";
      case AuthMethod.google:
        return "Google account connected";
      case AuthMethod.email:
        return "Email verified";
    }
  }

  String get _subtitle {
    switch (widget.payload.method) {
      case AuthMethod.phone:
        return "Your phone number ${widget.payload.identifier ?? ''} has been verified successfully.";
      case AuthMethod.google:
        return "Your Google account has been successfully linked.";
      case AuthMethod.email:
        return "Your email ${widget.payload.identifier ?? ''} has been verified.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: responsive.horizontal(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withOpacity(0.14),
                      border: Border.all(color: Colors.greenAccent, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 48,
                      color: Colors.greenAccent,
                    ),
                  ),
                  SizedBox(height: responsive.h(3)),
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.isTablet ? 26 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.h(1)),
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: responsive.h(2)),
                  const Text(
                    "Preparing your account…",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
