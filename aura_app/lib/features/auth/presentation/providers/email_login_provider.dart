import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailLoginState {
  final bool isLoading;
  final bool obscurePassword;

  const EmailLoginState({this.isLoading = false, this.obscurePassword = true});

  EmailLoginState copyWith({bool? isLoading, bool? obscurePassword}) {
    return EmailLoginState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

class EmailLoginNotifier extends StateNotifier<EmailLoginState> {
  EmailLoginNotifier() : super(const EmailLoginState());

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void reset() {
    state = const EmailLoginState();
  }
}

final emailLoginProvider =
    StateNotifierProvider<EmailLoginNotifier, EmailLoginState>(
      (ref) => EmailLoginNotifier(),
    );
