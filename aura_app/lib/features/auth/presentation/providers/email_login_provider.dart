import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/snackbar/app_snackbar.dart';

class EmailLoginState {
  final bool isLoading;
  final bool obscurePassword;
  final String? emailError;
  final String? passwordError;

  const EmailLoginState({
    this.isLoading = false,
    this.obscurePassword = true,
    this.emailError,
    this.passwordError,
  });

  EmailLoginState copyWith({
    bool? isLoading,
    bool? obscurePassword,
    String? emailError,
    String? passwordError,
  }) {
    return EmailLoginState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      emailError: emailError,
      passwordError: passwordError,
    );
  }
}

class EmailLoginNotifier extends StateNotifier<EmailLoginState> {
  EmailLoginNotifier() : super(const EmailLoginState());

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@'
    r'(gmail\.com|yahoo\.com|hotmail\.com|outlook\.com|icloud\.com|protonmail\.com|'
    r'[a-zA-Z0-9-]+\.[a-zA-Z]{2,})$',
  );

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void clearErrors() {
    state = state.copyWith(emailError: null, passwordError: null);
  }

  bool validateFields({
    required String email,
    required String password,
    required BuildContext context,
  }) {
    if (email.isEmpty && password.isEmpty) {
      AppSnackbar.showInfo(
        context: context,
        message: "Please fill out all required fields",
      );
      return false;
    }

    String? emailError;
    String? passwordError;

    if (email.isEmpty) {
      emailError = "Email is required";
    } else if (!_emailRegex.hasMatch(email)) {
      emailError = "Enter a valid email address";
    }

    if (password.isEmpty) {
      passwordError = "Password is required";
    } else if (password.length < 8) {
      passwordError = "Password must be at least 8 characters";
    }

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
    );

    return emailError == null && passwordError == null;
  }

  void reset() {
    state = const EmailLoginState();
  }
}

final emailLoginProvider =
    StateNotifierProvider<EmailLoginNotifier, EmailLoginState>(
      (ref) => EmailLoginNotifier(),
    );
