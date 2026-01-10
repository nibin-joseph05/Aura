import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../../core/ui/snackbar/app_snackbar.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../../core/widgets/loading/ghost_running.dart';
import '../../../../../core/widgets/navigation/app_header.dart';
import '../../../../../core/widgets/wrappers/confirm_exit_wrapper.dart';
import '../../../../auth/domain/models/auth_success_payload.dart';
import '../../../../common/widgets/password_text_field.dart';
import '../../providers/profile_complete_provider.dart';
import '../../providers/profile_image_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/date_of_birth_picker.dart';
import '../../widgets/gender_selector.dart';
import '../../widgets/phone_number_input.dart';
import '../../widgets/profile_image_picker.dart';

class ProfileCompleteScreen extends ConsumerStatefulWidget {
  const ProfileCompleteScreen({super.key});

  @override
  ConsumerState<ProfileCompleteScreen> createState() =>
      _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState extends ConsumerState<ProfileCompleteScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  Timer? _usernameDebounce;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      final payload = args['payload'] as AuthSuccessPayload?;
      final signupMethod = args['signupMethod'] as String?;

      bool isGoogleAuth = false;
      if (payload != null) {
        isGoogleAuth = payload.method == AuthMethod.google;
      } else if (signupMethod != null) {
        isGoogleAuth = signupMethod.toUpperCase() == 'GOOGLE';
      }

      final email = args['email'] as String?;
      final phone = args['phone'] as String?;
      final displayName = args['displayName'] as String?;
      final photoUrl = args['photoUrl'] as String?;

      Future(() {
        ref.read(profileCompleteProvider.notifier).initializeFromArgs({
          'email': email,
          'phone': phone,
          'displayName': displayName,
          'photoUrl': photoUrl,
          'isGoogleAuth': isGoogleAuth,
        });

        if (photoUrl != null && photoUrl.isNotEmpty) {
          ref.read(profileImageProvider.notifier).initializeWithUrl(photoUrl);
        }
      });

      if (displayName != null && displayName.isNotEmpty) {
        _nameController.text = displayName;
      }

      if (email != null && email.isNotEmpty) {
        _emailController.text = email;
      }

      if (phone != null && phone.isNotEmpty) {
        String phoneDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
        if (phoneDigits.startsWith('91') && phoneDigits.length > 10) {
          phoneDigits = phoneDigits.substring(2);
        }
        _phoneController.text = phoneDigits;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    ref.read(profileCompleteProvider.notifier).onUsernameChanged(value);

    _usernameDebounce?.cancel();
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty && value.length >= 3) {
        ref
            .read(profileCompleteProvider.notifier)
            .checkUsernameAvailability(value);
      }
    });
  }

  Future<void> _submitProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      AppSnackbar.showError(
        context: context,
        message: "Authentication error. Please sign in again.",
      );
      return;
    }

    final notifier = ref.read(profileCompleteProvider.notifier);
    final profileState = ref.read(profileCompleteProvider);
    final imageState = ref.read(profileImageProvider);

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final gender = profileState.selectedGender;
    final dob = profileState.selectedDob;

    final isValid = notifier.validateAllFields(
      name: name,
      username: username,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      gender: gender,
      dob: dob,
      isGoogleAuth: profileState.isGoogleAuth,
    );

    if (!isValid) return;

    if (!profileState.isUsernameAvailable && username.length >= 3) {
      AppSnackbar.showError(
        context: context,
        message: "Username is already taken",
      );
      return;
    }

    notifier.setLoading(true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GhostRunning(
        primaryMessage: "Setting up your profile...",
        secondaryMessage: "Just a moment",
      ),
    );

    try {
      final emailToSend = profileState.isGoogleAuth
          ? profileState.email
          : email;
      final phoneToSend = profileState.isGoogleAuth
          ? '+91$phone'
          : profileState.phone;

      await ref
          .read(userProvider.notifier)
          .updateProfile(
            uid: uid,
            name: name,
            username: username,
            email: emailToSend,
            phone: phoneToSend,
            gender: gender,
            dob: dob,
            profileImageUrl: imageState.imageUrl ?? profileState.photoUrl,
            password: password,
          );

      if (password.isNotEmpty &&
          emailToSend != null &&
          emailToSend.isNotEmpty) {
        try {
          final firebaseAuth = FirebaseAuth.instance;
          final currentUser = firebaseAuth.currentUser;
          if (currentUser != null) {
            final credential = EmailAuthProvider.credential(
              email: emailToSend,
              password: password,
            );
            await currentUser.linkWithCredential(credential);
          }
        } catch (_) {}
      }

      if (!mounted) return;
      Navigator.pop(context);
      notifier.setLoading(false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (_) => false,
        arguments: {'showSuccess': true, 'successType': 'profileComplete'},
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      notifier.setLoading(false);

      AppSnackbar.showError(
        context: context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final profileState = ref.watch(profileCompleteProvider);
    ref.watch(profileImageProvider);
    final notifier = ref.read(profileCompleteProvider.notifier);

    return ConfirmExitWrapper(
      title: "Exit profile setup?",
      message: "If you leave now, your profile setup will be cancelled.",
      confirmText: "Exit",
      cancelText: "Continue",
      onExit: () async {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: Column(
                children: [
                  const AppHeader(
                    title: "Complete Your Profile",
                    textColor: Colors.white,
                    showBack: false,
                    compact: true,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: responsive.horizontal(7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: responsive.h(1.5)),
                            _buildHeader(responsive),
                            SizedBox(height: responsive.h(1.5)),
                            ProfileImagePicker(
                              initialImageUrl: profileState.photoUrl,
                              onImageChanged: (url) {
                                notifier.setProfileImageUrl(url);
                              },
                              responsive: responsive,
                            ),
                            SizedBox(height: responsive.h(1.5)),
                            AppTextField(
                              controller: _nameController,
                              responsive: responsive,
                              hint: "Full Name",
                              icon: Icons.person_outline,
                              errorText: profileState.nameError,
                              onChanged: (v) => notifier.onNameChanged(v),
                            ),
                            SizedBox(height: responsive.h(1.2)),
                            AppTextField(
                              controller: _usernameController,
                              responsive: responsive,
                              hint: "Username",
                              icon: Icons.alternate_email,
                              errorText: profileState.usernameError,
                              onChanged: _onUsernameChanged,
                              suffixIcon: _buildUsernameSuffix(profileState),
                            ),
                            SizedBox(height: responsive.h(1.2)),
                            PhoneNumberInput(
                              controller: _phoneController,
                              responsive: responsive,
                              errorText: profileState.isGoogleAuth
                                  ? profileState.phoneError
                                  : null,
                              onChanged: profileState.isGoogleAuth
                                  ? (v) => notifier.onPhoneChanged(v)
                                  : null,
                              readOnly: !profileState.isGoogleAuth,
                              showVerifiedBadge: !profileState.isGoogleAuth,
                            ),
                            SizedBox(height: responsive.h(1.2)),
                            AppTextField(
                              controller: _emailController,
                              responsive: responsive,
                              hint: "Email Address",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              errorText: profileState.isGoogleAuth
                                  ? null
                                  : profileState.emailError,
                              onChanged: profileState.isGoogleAuth
                                  ? null
                                  : (v) => notifier.onEmailChanged(v),
                              readOnly: profileState.isGoogleAuth,
                              showVerifiedBadge: profileState.isGoogleAuth,
                            ),
                            SizedBox(height: responsive.h(1.2)),
                            GenderSelector(
                              selectedGender: profileState.selectedGender,
                              errorText: profileState.genderError,
                              onGenderSelected: (g) =>
                                  notifier.setSelectedGender(g),
                              responsive: responsive,
                            ),
                            SizedBox(height: responsive.h(1.2)),
                            DateOfBirthPicker(
                              controller: _dobController,
                              responsive: responsive,
                              errorText: profileState.dobError,
                              onDateSelected: (d) => notifier.setSelectedDob(d),
                            ),
                            SizedBox(height: responsive.h(1.5)),
                            _buildSectionLabel("Create Password"),
                            SizedBox(height: responsive.h(0.8)),
                            PasswordTextField(
                              controller: _passwordController,
                              responsive: responsive,
                              hint: "Password",
                              obscureText: profileState.obscurePassword,
                              onToggleVisibility: () =>
                                  notifier.togglePasswordVisibility(),
                              errorText: profileState.passwordError,
                              onChanged: (v) => notifier.onPasswordChanged(
                                v,
                                _confirmPasswordController.text,
                              ),
                            ),
                            SizedBox(height: responsive.h(1.2)),
                            PasswordTextField(
                              controller: _confirmPasswordController,
                              responsive: responsive,
                              hint: "Confirm Password",
                              obscureText: profileState.obscureConfirmPassword,
                              onToggleVisibility: () =>
                                  notifier.toggleConfirmPasswordVisibility(),
                              errorText: profileState.confirmPasswordError,
                              onChanged: (v) =>
                                  notifier.onConfirmPasswordChanged(
                                    _passwordController.text,
                                    v,
                                  ),
                            ),
                            SizedBox(height: responsive.h(2)),
                            profileState.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : PrimaryButton(
                                    label: "Complete Profile",
                                    onPressed: _submitProfile,
                                    responsive: responsive,
                                  ),
                            SizedBox(height: responsive.h(2)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Responsive responsive) {
    return Column(
      children: [
        Text(
          "Tell us about yourself",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: responsive.isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: responsive.h(0.3)),
        const Text(
          "This helps us personalize your experience.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget? _buildUsernameSuffix(ProfileCompleteState state) {
    if (state.isCheckingUsername) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white70,
          ),
        ),
      );
    }

    if (state.isUsernameAvailable && _usernameController.text.length >= 3) {
      return const Icon(
        Icons.check_circle,
        color: Colors.greenAccent,
        size: 22,
      );
    }

    return null;
  }
}
