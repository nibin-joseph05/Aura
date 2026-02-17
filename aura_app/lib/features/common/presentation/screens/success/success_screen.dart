import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../auth/domain/models/auth_success_payload.dart';
import '../../../../user/presentation/providers/user_provider.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  final AuthSuccessPayload payload;

  const SuccessScreen({super.key, required this.payload});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  static const _delay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _syncUserAndNavigate();
  }

  Future<void> _syncUserAndNavigate() async {
    await Future.delayed(_delay);

    if (!mounted) return;

    try {
      await ref.read(userProvider.notifier).syncCurrentUser();

      if (!mounted) return;

      final userState = ref.read(userProvider);
      final user = userState.user;

      if (user == null) {
        _navigateToProfileComplete();
        return;
      }

      final hasBasicInfo =
          user.name != null &&
          user.name!.isNotEmpty &&
          user.username != null &&
          user.username!.isNotEmpty;

      if (user.profileCompleted && hasBasicInfo) {
        _navigateToHome();
      } else {
        _navigateToProfileComplete();
      }
    } catch (e) {
      if (!mounted) return;
      _navigateToProfileComplete();
    }
  }

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (_) => false,
      arguments: {'showSuccess': true, 'successType': 'login'},
    );
  }

  void _navigateToProfileComplete() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userState = ref.read(userProvider);
    final user = userState.user;

    final isGoogleAuth = widget.payload.method == AuthMethod.google;
    final isPhoneAuth = widget.payload.method == AuthMethod.phone;

    String? email;
    String? phone;

    if (isGoogleAuth) {
      email = widget.payload.identifier ?? user?.email ?? currentUser?.email;
      phone = user?.phone;
    } else if (isPhoneAuth) {
      phone =
          widget.payload.identifier ?? user?.phone ?? currentUser?.phoneNumber;
      email = user?.email;
    } else {
      email = widget.payload.identifier ?? user?.email ?? currentUser?.email;
      phone = user?.phone ?? currentUser?.phoneNumber;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.profileComplete,
      (_) => false,
      arguments: {
        'payload': widget.payload,
        'email': email,
        'phone': phone,
        'displayName': user?.name ?? currentUser?.displayName,
        'photoUrl': user?.profileImageUrl ?? currentUser?.photoURL,
        'signupMethod':
            user?.signupMethod ?? widget.payload.method.name.toUpperCase(),
      },
    );
  }

  String get _displayIdentifier {
    if (widget.payload.identifier != null &&
        widget.payload.identifier!.isNotEmpty) {
      return widget.payload.identifier!;
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    if (widget.payload.method == AuthMethod.google) {
      return currentUser?.email ?? '';
    }
    if (widget.payload.method == AuthMethod.phone) {
      return currentUser?.phoneNumber ?? '';
    }
    return currentUser?.email ?? '';
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
    final identifier = _displayIdentifier;
    switch (widget.payload.method) {
      case AuthMethod.phone:
        return "Your phone number $identifier has been verified successfully.";
      case AuthMethod.google:
        return identifier.isNotEmpty
            ? "Your Google account $identifier has been successfully linked."
            : "Your Google account has been successfully linked.";
      case AuthMethod.email:
        return "Your email $identifier has been verified.";
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
                      color: Colors.greenAccent.withValues(alpha: 0.14),
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
