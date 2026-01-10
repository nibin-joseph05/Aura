import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuccessOverlayData {
  final bool isVisible;
  final String title;
  final String message;
  final String buttonText;
  final IconData icon;
  final Color iconColor;

  const SuccessOverlayData({
    this.isVisible = false,
    this.title = '',
    this.message = '',
    this.buttonText = 'Continue',
    this.icon = Icons.check_circle_outline,
    this.iconColor = Colors.greenAccent,
  });

  static SuccessOverlayData loginSuccess() {
    return const SuccessOverlayData(
      isVisible: true,
      title: 'Welcome Back!',
      message:
          'You have successfully logged in. Ready to explore your wellness journey?',
      buttonText: 'Let\'s Go',
      icon: Icons.waving_hand_rounded,
      iconColor: Color(0xFF64B5F6),
    );
  }

  static SuccessOverlayData profileComplete() {
    return const SuccessOverlayData(
      isVisible: true,
      title: 'Profile Complete!',
      message:
          'Your account is all set up. Start your journey to wellness, routine, and community.',
      buttonText: 'Get Started',
      icon: Icons.celebration_rounded,
      iconColor: Color(0xFF00BCD4),
    );
  }

  static SuccessOverlayData signupSuccess() {
    return const SuccessOverlayData(
      isVisible: true,
      title: 'Welcome to Aura!',
      message:
          'Your account has been created successfully. Let\'s set up your profile.',
      buttonText: 'Continue',
      icon: Icons.rocket_launch_rounded,
      iconColor: Color(0xFF2196F3),
    );
  }

  SuccessOverlayData copyWith({
    bool? isVisible,
    String? title,
    String? message,
    String? buttonText,
    IconData? icon,
    Color? iconColor,
  }) {
    return SuccessOverlayData(
      isVisible: isVisible ?? this.isVisible,
      title: title ?? this.title,
      message: message ?? this.message,
      buttonText: buttonText ?? this.buttonText,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}

class SuccessOverlayNotifier extends StateNotifier<SuccessOverlayData> {
  SuccessOverlayNotifier() : super(const SuccessOverlayData());

  void show(SuccessOverlayData data) {
    state = data;
  }

  void showLogin() {
    state = SuccessOverlayData.loginSuccess();
  }

  void showProfileComplete() {
    state = SuccessOverlayData.profileComplete();
  }

  void showSignup() {
    state = SuccessOverlayData.signupSuccess();
  }

  void hide() {
    state = const SuccessOverlayData();
  }
}

final successOverlayProvider =
    StateNotifierProvider<SuccessOverlayNotifier, SuccessOverlayData>((ref) {
      return SuccessOverlayNotifier();
    });
