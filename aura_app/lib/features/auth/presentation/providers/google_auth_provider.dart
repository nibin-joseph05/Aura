import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoogleAuthState {
  final bool isLoading;

  const GoogleAuthState({this.isLoading = false});

  GoogleAuthState copyWith({bool? isLoading}) {
    return GoogleAuthState(isLoading: isLoading ?? this.isLoading);
  }
}

class GoogleAuthNotifier extends StateNotifier<GoogleAuthState> {
  GoogleAuthNotifier() : super(const GoogleAuthState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void reset() {
    state = const GoogleAuthState();
  }
}

final googleAuthProvider =
    StateNotifierProvider<GoogleAuthNotifier, GoogleAuthState>(
      (ref) => GoogleAuthNotifier(),
    );
