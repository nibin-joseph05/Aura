import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/user_remote_datasource.dart';

class ProfileCompleteState {
  final bool isLoading;
  final String? nameError;
  final String? usernameError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? genderError;
  final String? dobError;
  final bool isCheckingUsername;
  final bool isUsernameAvailable;
  final String selectedGender;
  final String selectedDob;
  final String? phone;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isGoogleAuth;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool emailVerificationSent;
  final bool phoneVerificationSent;
  final bool verifyLaterEmail;
  final bool verifyLaterPhone;
  final bool isRegister;

  const ProfileCompleteState({
    this.isLoading = false,
    this.nameError,
    this.usernameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    this.confirmPasswordError,
    this.genderError,
    this.dobError,
    this.isCheckingUsername = false,
    this.isUsernameAvailable = false,
    this.selectedGender = '',
    this.selectedDob = '',
    this.phone,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isGoogleAuth = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.emailVerificationSent = false,
    this.phoneVerificationSent = false,
    this.verifyLaterEmail = false,
    this.verifyLaterPhone = false,
    this.isRegister = false,
  });

  ProfileCompleteState copyWith({
    bool? isLoading,
    String? nameError,
    String? usernameError,
    String? emailError,
    String? phoneError,
    String? passwordError,
    String? confirmPasswordError,
    String? genderError,
    String? dobError,
    bool? isCheckingUsername,
    bool? isUsernameAvailable,
    String? selectedGender,
    String? selectedDob,
    String? phone,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isGoogleAuth,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool clearNameError = false,
    bool clearUsernameError = false,
    bool clearEmailError = false,
    bool clearPhoneError = false,
    bool clearPasswordError = false,
    bool clearConfirmPasswordError = false,
    bool clearGenderError = false,
    bool clearDobError = false,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? emailVerificationSent,
    bool? phoneVerificationSent,
    bool? verifyLaterEmail,
    bool? verifyLaterPhone,
    bool? isRegister,
  }) {
    return ProfileCompleteState(
      isLoading: isLoading ?? this.isLoading,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      usernameError: clearUsernameError
          ? null
          : (usernameError ?? this.usernameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      confirmPasswordError: clearConfirmPasswordError
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
      genderError: clearGenderError ? null : (genderError ?? this.genderError),
      dobError: clearDobError ? null : (dobError ?? this.dobError),
      isCheckingUsername: isCheckingUsername ?? this.isCheckingUsername,
      isUsernameAvailable: isUsernameAvailable ?? this.isUsernameAvailable,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedDob: selectedDob ?? this.selectedDob,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isGoogleAuth: isGoogleAuth ?? this.isGoogleAuth,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      emailVerificationSent:
          emailVerificationSent ?? this.emailVerificationSent,
      phoneVerificationSent:
          phoneVerificationSent ?? this.phoneVerificationSent,
      verifyLaterEmail: verifyLaterEmail ?? this.verifyLaterEmail,
      verifyLaterPhone: verifyLaterPhone ?? this.verifyLaterPhone,
      isRegister: isRegister ?? this.isRegister,
    );
  }
}

class ProfileCompleteNotifier extends StateNotifier<ProfileCompleteState> {
  final UserRemoteDataSource _dataSource;

  ProfileCompleteNotifier(this._dataSource)
    : super(const ProfileCompleteState());

  void initializeFromArgs(Map<String, dynamic>? args) {
    if (args == null) return;

    final email = args['email'] as String?;
    final phone = args['phone'] as String?;
    final displayName = args['displayName'] as String?;
    final photoUrl = args['photoUrl'] as String?;
    final isGoogle = args['isGoogleAuth'] as bool? ?? false;
    final isRegister = args['isRegister'] as bool? ?? false;

    state = state.copyWith(
      email: email,
      phone: phone,
      displayName: displayName,
      photoUrl: photoUrl,
      isGoogleAuth: isGoogle,
      isRegister: isRegister,
      isEmailVerified: isGoogle,
      isPhoneVerified:
          !isGoogle && !isRegister && phone != null && phone.isNotEmpty,
    );
  }

  void setSelectedGender(String gender) {
    state = state.copyWith(selectedGender: gender, clearGenderError: true);
  }

  void setSelectedDob(String dob) {
    state = state.copyWith(selectedDob: dob, clearDobError: true);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  void clearAllErrors() {
    state = state.copyWith(
      clearNameError: true,
      clearUsernameError: true,
      clearEmailError: true,
      clearPhoneError: true,
      clearPasswordError: true,
      clearConfirmPasswordError: true,
      clearGenderError: true,
      clearDobError: true,
    );
  }

  void setEmailVerified(bool verified) {
    state = state.copyWith(isEmailVerified: verified);
  }

  void setPhoneVerified(bool verified) {
    state = state.copyWith(isPhoneVerified: verified);
  }

  void setEmailVerificationSent(bool sent) {
    state = state.copyWith(emailVerificationSent: sent);
  }

  void setPhoneVerificationSent(bool sent) {
    state = state.copyWith(phoneVerificationSent: sent);
  }

  void setVerifyLaterEmail() {
    state = state.copyWith(verifyLaterEmail: true);
  }

  void setVerifyLaterPhone() {
    state = state.copyWith(verifyLaterPhone: true);
  }

  String? validateName(String name) {
    if (name.isEmpty) return "Name is required";
    if (name.length < 2) return "Name must be at least 2 characters";
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name))
      return "Name can only contain letters";
    return null;
  }

  String? validateUsername(String username) {
    if (username.isEmpty) return "Username is required";
    if (username.length < 3) return "Username must be at least 3 characters";
    if (!RegExp(r'^[a-zA-Z_]+$').hasMatch(username))
      return "Only letters and underscores allowed";
    return null;
  }

  String? validateEmail(String email) {
    if (email.isEmpty) return "Email is required";
    if (!RegExp(r'^[\w\.-]+@[\w-]+\.[\w-]{2,4}$').hasMatch(email))
      return "Please enter a valid email";
    return null;
  }

  String? validatePhone(String phone) {
    if (phone.isEmpty) return "Phone number is required";
    if (phone.length != 10) return "Phone number must be 10 digits";
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) return "Only numbers allowed";
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return "Password is required";
    if (password.length < 8) return "Minimum 8 characters required";
    if (!RegExp(r'[A-Z]').hasMatch(password))
      return "Must contain uppercase letter";
    if (!RegExp(r'[a-z]').hasMatch(password))
      return "Must contain lowercase letter";
    if (!RegExp(r'[0-9]').hasMatch(password)) return "Must contain number";
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password))
      return "Must contain special character";
    return null;
  }

  String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return "Please confirm password";
    if (password != confirmPassword) return "Passwords do not match";
    return null;
  }

  void onNameChanged(String value) {
    final error = validateName(value);
    state = state.copyWith(nameError: error, clearNameError: error == null);
  }

  void onUsernameChanged(String value) {
    final error = validateUsername(value);
    if (error != null) {
      state = state.copyWith(usernameError: error, isUsernameAvailable: false);
    } else {
      state = state.copyWith(clearUsernameError: true);
    }
  }

  void onEmailChanged(String value) {
    final error = validateEmail(value);
    state = state.copyWith(emailError: error, clearEmailError: error == null);
  }

  void onPhoneChanged(String value) {
    final error = validatePhone(value);
    state = state.copyWith(phoneError: error, clearPhoneError: error == null);
  }

  void onPasswordChanged(String value, String confirmPassword) {
    final error = validatePassword(value);
    state = state.copyWith(
      passwordError: error,
      clearPasswordError: error == null,
    );

    if (confirmPassword.isNotEmpty) {
      final confirmError = validateConfirmPassword(value, confirmPassword);
      state = state.copyWith(
        confirmPasswordError: confirmError,
        clearConfirmPasswordError: confirmError == null,
      );
    }
  }

  void onConfirmPasswordChanged(String password, String confirmPassword) {
    final error = validateConfirmPassword(password, confirmPassword);
    state = state.copyWith(
      confirmPasswordError: error,
      clearConfirmPasswordError: error == null,
    );
  }

  bool validateAllFields({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String gender,
    required String dob,
    required bool isGoogleAuth,
  }) {
    final nameError = validateName(name);
    final usernameError = validateUsername(username);

    String? emailError;
    String? phoneError;
    if (state.isRegister) {
      emailError = validateEmail(email);
      phoneError = validatePhone(phone);
    } else {
      emailError = isGoogleAuth ? null : validateEmail(email);
      phoneError = isGoogleAuth ? validatePhone(phone) : null;
    }

    final passwordError = validatePassword(password);
    final confirmPasswordError = validateConfirmPassword(
      password,
      confirmPassword,
    );
    String? genderError;
    String? dobError;

    if (gender.isEmpty) genderError = "Please select gender";
    if (dob.isEmpty) dobError = "Please select date of birth";

    state = state.copyWith(
      nameError: nameError,
      usernameError: usernameError,
      emailError: emailError,
      phoneError: phoneError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      genderError: genderError,
      dobError: dobError,
    );

    return nameError == null &&
        usernameError == null &&
        emailError == null &&
        phoneError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        genderError == null &&
        dobError == null;
  }

  Future<void> checkUsernameAvailability(String username) async {
    final validationError = validateUsername(username);
    if (validationError != null) {
      state = state.copyWith(
        isUsernameAvailable: false,
        isCheckingUsername: false,
        usernameError: validationError,
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'new_user';

    state = state.copyWith(isCheckingUsername: true, clearUsernameError: true);

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

  void setProfileImageUrl(String? url) {
    state = state.copyWith(photoUrl: url);
  }

  void reset() {
    state = const ProfileCompleteState();
  }
}

final profileCompleteProvider =
    StateNotifierProvider<ProfileCompleteNotifier, ProfileCompleteState>(
      (ref) => ProfileCompleteNotifier(UserRemoteDataSource()),
    );
