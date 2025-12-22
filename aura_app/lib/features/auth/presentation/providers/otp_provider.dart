import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class OtpState {
  final List<String> otpDigits;
  final bool isVerifying;
  final int timerSeconds;
  final bool canResend;

  const OtpState({
    this.otpDigits = const ['', '', '', '', '', ''],
    this.isVerifying = false,
    this.timerSeconds = 30,
    this.canResend = false,
  });

  OtpState copyWith({
    List<String>? otpDigits,
    bool? isVerifying,
    int? timerSeconds,
    bool? canResend,
  }) {
    return OtpState(
      otpDigits: otpDigits ?? this.otpDigits,
      isVerifying: isVerifying ?? this.isVerifying,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      canResend: canResend ?? this.canResend,
    );
  }

  String get fullOtp => otpDigits.join();
  bool get isComplete => otpDigits.every((d) => d.isNotEmpty);
}

class OtpNotifier extends StateNotifier<OtpState> {
  Timer? _timer;

  OtpNotifier() : super(const OtpState()) {
    _startTimer();
  }

  void updateDigit(int index, String value) {
    final newDigits = List<String>.from(state.otpDigits);
    newDigits[index] = value;
    state = state.copyWith(otpDigits: newDigits);
  }

  void setAutoFillOtp(String otp) {
    if (otp.length == 6) {
      final digits = otp.split('');
      state = state.copyWith(otpDigits: digits);
    }
  }

  void clearOtp() {
    state = state.copyWith(otpDigits: ['', '', '', '', '', '']);
  }

  void setVerifying(bool isVerifying) {
    state = state.copyWith(isVerifying: isVerifying);
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(timerSeconds: 30, canResend: false);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timerSeconds == 0) {
        timer.cancel();
        state = state.copyWith(canResend: true);
      } else {
        state = state.copyWith(timerSeconds: state.timerSeconds - 1);
      }
    });
  }

  void resetTimer() {
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final otpProvider = StateNotifierProvider.autoDispose<OtpNotifier, OtpState>(
      (ref) => OtpNotifier(),
);