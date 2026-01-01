import 'package:flutter/material.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({
    super.key,
    // required this.payload,
  });

  // final AuthSuccessPayload payload;

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
    );
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
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withOpacity(0.15),
                      border: Border.all(color: Colors.greenAccent, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 52,
                      color: Colors.greenAccent,
                    ),
                  ),
                  SizedBox(height: responsive.h(3)),
                  Text(
                    "Authentication Successful",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.isTablet ? 26 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.h(1)),
                  const Text(
                    "Setting up your account…",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
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
