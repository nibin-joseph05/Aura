import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/user_remote_datasource.dart';

class EditProfileState {
  final bool isLoading;
  final String? nameError;
  final String? usernameError;
  final String? genderError;
  final String? dobError;
  final bool isCheckingUsername;
  final bool isUsernameAvailable;
  final String selectedGender;
  final String selectedDob;

  const EditProfileState({
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

  EditProfileState copyWith({
    bool? isLoading,
    String? nameError,
    String? usernameError,
    String? genderError,
    String? dobError,
    bool? isCheckingUsername,
    bool? isUsernameAvailable,
    String? selectedGender,
    String? selectedDob,
    bool clearNameError = false,
    bool clearUsernameError = false,
    bool clearGenderError = false,
    bool clearDobError = false,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      usernameError: clearUsernameError
          ? null
          : (usernameError ?? this.usernameError),
      genderError: clearGenderError ? null : (genderError ?? this.genderError),
      dobError: clearDobError ? null : (dobError ?? this.dobError),
      isCheckingUsername: isCheckingUsername ?? this.isCheckingUsername,
      isUsernameAvailable: isUsernameAvailable ?? this.isUsernameAvailable,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedDob: selectedDob ?? this.selectedDob,
    );
  }
}

class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final UserRemoteDataSource _dataSource;

  EditProfileNotifier(this._dataSource) : super(const EditProfileState());

  void initialize(String gender, String dob) {
    state = state.copyWith(selectedGender: gender, selectedDob: dob);
  }

  void setSelectedGender(String gender) {
    state = state.copyWith(selectedGender: gender, clearGenderError: true);
  }

  void setSelectedDob(String dob) {
    state = state.copyWith(selectedDob: dob, clearDobError: true);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  String? _validateName(String name) {
    if (name.isEmpty) return 'Full name is required';
    if (name.length < 2) return 'Name must be at least 2 characters';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name))
      return 'Name can only contain letters';
    return null;
  }

  String? _validateUsername(String username) {
    if (username.isEmpty) return 'Username is required';
    if (username.length < 3) return 'Username must be at least 3 characters';
    if (!RegExp(r'^[a-zA-Z_]+$').hasMatch(username))
      return 'Only letters and underscores allowed';
    return null;
  }

  void onNameChanged(String value) {
    final error = _validateName(value);
    state = state.copyWith(nameError: error, clearNameError: error == null);
  }

  void onUsernameChanged(String value) {
    final error = _validateUsername(value);
    if (error != null) {
      state = state.copyWith(usernameError: error, isUsernameAvailable: false);
    } else {
      state = state.copyWith(
        clearUsernameError: true,
        isUsernameAvailable: false,
      );
    }
  }

  Future<void> checkUsernameAvailability(
    String username,
    String currentUsername,
  ) async {
    if (username.trim() == currentUsername.trim()) {
      state = state.copyWith(
        isUsernameAvailable: true,
        isCheckingUsername: false,
        clearUsernameError: true,
      );
      return;
    }

    final validationError = _validateUsername(username);
    if (validationError != null) {
      state = state.copyWith(
        isUsernameAvailable: false,
        isCheckingUsername: false,
        usernameError: validationError,
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    state = state.copyWith(isCheckingUsername: true, clearUsernameError: true);

    try {
      final available = await _dataSource.isUsernameAvailable(
        username: username,
        uid: uid,
      );
      state = state.copyWith(
        isUsernameAvailable: available,
        isCheckingUsername: false,
        usernameError: available ? null : 'Username is already taken',
      );
    } catch (_) {
      state = state.copyWith(
        isCheckingUsername: false,
        usernameError: 'Failed to check username',
      );
    }
  }

  bool validateAll({
    required String name,
    required String username,
    required String gender,
    required String dob,
  }) {
    final nameError = _validateName(name);
    final usernameError = _validateUsername(username);
    final genderError = gender.isEmpty ? 'Please select your gender' : null;
    final dobError = dob.isEmpty ? 'Please select your date of birth' : null;

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
}

final editProfileProvider =
    StateNotifierProvider<EditProfileNotifier, EditProfileState>(
      (ref) => EditProfileNotifier(UserRemoteDataSource()),
    );
