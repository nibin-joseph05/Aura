import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpState {
  final String? verificationId;
  final int? resendToken;
  final String? phoneNumber;

  const OtpState({this.verificationId, this.resendToken, this.phoneNumber});

  OtpState copyWith({
    String? verificationId,
    int? resendToken,
    String? phoneNumber,
    bool clearAll = false,
  }) {
    if (clearAll) {
      return const OtpState();
    }
    return OtpState(
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  bool get hasVerificationId => verificationId != null;
}

class OtpStateNotifier extends StateNotifier<OtpState> {
  OtpStateNotifier() : super(const OtpState());

  void setVerificationData({
    required String verificationId,
    int? resendToken,
    String? phoneNumber,
  }) {
    state = state.copyWith(
      verificationId: verificationId,
      resendToken: resendToken,
      phoneNumber: phoneNumber,
    );
  }

  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  void clear() {
    state = state.copyWith(clearAll: true);
  }
}

final otpStateProvider = StateNotifierProvider<OtpStateNotifier, OtpState>(
  (ref) => OtpStateNotifier(),
);
