import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../user/data/datasources/user_remote_datasource.dart';

class ProfileCompleteState {
  final bool isLoading;
  final String? nameError;
  final String? usernameError;
  final String? genderError;
  final String? dobError;
  final bool isCheckingUsername;
  final bool isUsernameAvailable;
  final String selectedGender;
  final String selectedDob;

  const ProfileCompleteState({
    this.isLoading = false,
    this.nameError,
    this.usernameError,
    this.genderError,
    this.dobError,
    this.isCheckingUsername = false,
    this.isUsernameAvailable = false,
    this.selectedGender = '',
    this.selectedDob = '',
  });

  ProfileCompleteState copyWith({
    bool? isLoading,
    String? nameError,
    String? usernameError,
    String? genderError,
    String? dobError,
    bool? isCheckingUsername,
    bool? isUsernameAvailable,
    String? selectedGender,
    String? selectedDob,
  }) {
    return ProfileCompleteState(
      isLoading: isLoading ?? this.isLoading,
      nameError: nameError,
      usernameError: usernameError,
      genderError: genderError,
      dobError: dobError,
      isCheckingUsername: isCheckingUsername ?? this.isCheckingUsername,
      isUsernameAvailable: isUsernameAvailable ?? this.isUsernameAvailable,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedDob: selectedDob ?? this.selectedDob,
    );
  }
}

class ProfileCompleteNotifier extends StateNotifier<ProfileCompleteState> {
  final UserRemoteDataSource _dataSource;

  ProfileCompleteNotifier(this._dataSource)
      : super(const ProfileCompleteState());

  void setSelectedGender(String gender) {
    state = state.copyWith(selectedGender: gender);
  }

  void setSelectedDob(String dob) {
    state = state.copyWith(selectedDob: dob);
  }

  void clearErrors() {
    state = state.copyWith(
      nameError: null,
      usernameError: null,
      genderError: null,
      dobError: null,
    );
  }

  bool validateFields({
    required String name,
    required String username,
    required String gender,
    required String dob,
    required BuildContext context,
  }) {
    String? nameError;
    String? usernameError;
    String? genderError;
    String? dobError;

    if (name.isEmpty) {
      nameError = "Name is required";
    } else if (name.length < 2) {
      nameError = "Name must be at least 2 characters";
    }

    if (username.isEmpty) {
      usernameError = "Username is required";
    } else if (username.length < 3) {
      usernameError = "Username must be at least 3 characters";
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      usernameError =
      "Username can only contain letters, numbers, and underscores";
    }

    if (gender.isEmpty) {
      genderError = "Please select your gender";
    }

    if (dob.isEmpty) {
      dobError = "Please select your date of birth";
    }

    state = state.copyWith(
      nameError: nameError,
      usernameError: usernameError,
      genderError: genderError,
      dobError: dobError,
    );

    return nameError == null &&
        usernameError == null &&
        genderError == null &&
        dobError == null;
  }

  Future<void> checkUsernameAvailability(String username) async {
    if (username.isEmpty || username.length < 3) {
      state = state.copyWith(
        isUsernameAvailable: false,
        isCheckingUsername: false,
        usernameError: null,
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      state = state.copyWith(
        isCheckingUsername: false,
        usernameError: "Authentication error",
      );
      return;
    }

    state = state.copyWith(
      isCheckingUsername: true,
      usernameError: null,
    );

    try {
      final available = await _dataSource.isUsernameAvailable(
        username: username,
        uid: uid,
      );

      state = state.copyWith(
        isUsernameAvailable: available,
        isCheckingUsername: false,
        usernameError: available ? null : "Username is already taken",
      );
    } catch (e) {
      state = state.copyWith(
        isCheckingUsername: false,
        usernameError: "Failed to check username",
      );
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void reset() {
    state = const ProfileCompleteState();
  }
}

final profileCompleteProvider =
StateNotifierProvider<ProfileCompleteNotifier, ProfileCompleteState>(
      (ref) => ProfileCompleteNotifier(UserRemoteDataSource()),
);