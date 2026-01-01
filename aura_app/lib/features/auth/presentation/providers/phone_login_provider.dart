import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneLoginState {
  final String phoneNumber;
  final bool isLoading;

  const PhoneLoginState({this.phoneNumber = '', this.isLoading = false});

  PhoneLoginState copyWith({String? phoneNumber, bool? isLoading}) {
    return PhoneLoginState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
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

  void reset() {
    state = const PhoneLoginState();
  }
}

final phoneLoginProvider =
    StateNotifierProvider<PhoneLoginNotifier, PhoneLoginState>(
      (ref) => PhoneLoginNotifier(),
    );
