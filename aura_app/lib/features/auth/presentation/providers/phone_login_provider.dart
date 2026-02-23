import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneLoginState {
  final String phoneNumber;
  final bool isLoading;
  final String? phoneError;

  const PhoneLoginState({
    this.phoneNumber = '',
    this.isLoading = false,
    this.phoneError,
  });

  PhoneLoginState copyWith({
    String? phoneNumber,
    bool? isLoading,
    String? phoneError,
    bool clearPhoneError = false,
  }) {
    return PhoneLoginState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
    );
  }
}

class PhoneLoginNotifier extends StateNotifier<PhoneLoginState> {
  PhoneLoginNotifier() : super(const PhoneLoginState());

  void updatePhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void onPhoneChanged(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      state = state.copyWith(phoneError: "Phone number is required");
    } else if (digits.length != 10) {
      state = state.copyWith(phoneError: "Must be 10 digits");
    } else {
      state = state.copyWith(clearPhoneError: true);
    }
  }

  bool validatePhone(String phone) {
    if (phone.isEmpty) {
      state = state.copyWith(phoneError: "Phone number is required");
      return false;
    }
    if (phone.length != 10) {
      state = state.copyWith(phoneError: "Must be 10 digits");
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      state = state.copyWith(phoneError: "Only numbers allowed");
      return false;
    }
    state = state.copyWith(clearPhoneError: true);
    return true;
  }

  void reset() {
    state = const PhoneLoginState();
  }
}

final phoneLoginProvider =
    StateNotifierProvider<PhoneLoginNotifier, PhoneLoginState>(
      (ref) => PhoneLoginNotifier(),
    );
