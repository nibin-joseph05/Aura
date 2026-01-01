import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailLoginState {
  final String email;
  final String password;
  final bool isLoading;
  final bool isSignUp;
  final bool obscurePassword;

  const EmailLoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.isSignUp = false,
    this.obscurePassword = true,
  });

  EmailLoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? isSignUp,
    bool? obscurePassword,
  }) {
    return EmailLoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isSignUp: isSignUp ?? this.isSignUp,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

class EmailLoginNotifier extends StateNotifier<EmailLoginState> {
  EmailLoginNotifier() : super(const EmailLoginState());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void toggleMode() {
    state = state.copyWith(isSignUp: !state.isSignUp);
  }

  void reset() {
    state = const EmailLoginState();
  }
}

final emailLoginProvider =
StateNotifierProvider<EmailLoginNotifier, EmailLoginState>(
      (ref) => EmailLoginNotifier(),
);