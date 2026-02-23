import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpState {
  final List<String> digits;
  final bool isVerified;
  final bool isVerifying;
  final bool isResendActive;
  final int timerSeconds;
  final bool hasError;
  final String? errorMessage;

  const OtpState({
    this.digits = const ['', '', '', '', '', ''],
    this.isVerified = false,
    this.isVerifying = false,
    this.isResendActive = false,
    this.timerSeconds = 60,
    this.hasError = false,
    this.errorMessage,
  });

  String get fullOtp => digits.join();
  bool get isComplete => digits.every((d) => d.isNotEmpty);
  bool get canResend => isResendActive;

  OtpState copyWith({
    List<String>? digits,
    bool? isVerified,
    bool? isVerifying,
    bool? isResendActive,
    int? timerSeconds,
    bool? hasError,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OtpState(
      digits: digits ?? this.digits,
      isVerified: isVerified ?? this.isVerified,
      isVerifying: isVerifying ?? this.isVerifying,
      isResendActive: isResendActive ?? this.isResendActive,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier() : super(const OtpState());

  void updateDigit(int index, String value) {
    final newDigits = List<String>.from(state.digits);
    newDigits[index] = value;
    state = state.copyWith(digits: newDigits, clearError: true);
  }

  void setAutoFillOtp(String code) {
    if (code.length != 6) return;
    final digits = code.split('');
    state = state.copyWith(digits: digits, clearError: true);
  }

  void setVerified(bool verified) {
    state = state.copyWith(isVerified: verified);
  }

  void setVerifying(bool verifying) {
    state = state.copyWith(isVerifying: verifying);
  }

  void setError(String message) {
    state = state.copyWith(hasError: true, errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearOtp() {
    state = state.copyWith(
      digits: const ['', '', '', '', '', ''],
      clearError: true,
    );
  }

  void setResendActive(bool active) {
    state = state.copyWith(isResendActive: active);
  }

  void setTimerSeconds(int seconds) {
    state = state.copyWith(timerSeconds: seconds);
  }

  void resetTimer() {
    state = state.copyWith(timerSeconds: 60, isResendActive: false);
  }

  void reset() {
    state = const OtpState();
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>(
  (ref) => OtpNotifier(),
);
