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
import '../../../../user/presentation/providers/profile_complete_provider.dart';
import '../../../../user/presentation/providers/user_provider.dart';

class ProfileCompleteScreen extends ConsumerStatefulWidget {
  const ProfileCompleteScreen({super.key});

  @override
  ConsumerState<ProfileCompleteScreen> createState() =>
      _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState
    extends ConsumerState<ProfileCompleteScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  Timer? _usernameDebounce;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty && value.length >= 3) {
        ref
            .read(profileCompleteProvider.notifier)
            .checkUsernameAvailability(value);
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.primaryDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final dobString =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _dobController.text = dobString;
      ref.read(profileCompleteProvider.notifier).setSelectedDob(dobString);
    }
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

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final profileState = ref.read(profileCompleteProvider);
    final gender = profileState.selectedGender;
    final dob = profileState.selectedDob;

    final notifier = ref.read(profileCompleteProvider.notifier);
    notifier.clearErrors();

    final isValid = notifier.validateFields(
      name: name,
      username: username,
      gender: gender,
      dob: dob,
      context: context,
    );

    if (!isValid) return;

    if (!profileState.isUsernameAvailable) {
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
      await ref.read(userProvider.notifier).updateProfile(
        uid: uid,
        name: name,
        username: username,
        gender: gender,
        dob: dob,
      );

      if (!mounted) return;
      Navigator.pop(context);

      notifier.setLoading(false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
            (_) => false,
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

    return ConfirmExitWrapper(
      title: "Exit profile setup?",
      message:
      "If you leave now, your profile setup will be cancelled. You can complete it later.",
      confirmText: "Exit",
      cancelText: "Continue",
      onExit: () async {
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
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
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: responsive.horizontal(7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: responsive.h(3)),
                            Text(
                              "Tell us a bit about yourself",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: responsive.h(1)),
                            const Text(
                              "This helps us personalize your experience.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: responsive.h(4)),
                            AppTextField(
                              controller: _nameController,
                              responsive: responsive,
                              hint: "Full Name",
                              icon: Icons.person_outline,
                              errorText: profileState.nameError,
                            ),
                            SizedBox(height: responsive.h(2)),
                            AppTextField(
                              controller: _usernameController,
                              responsive: responsive,
                              hint: "Username",
                              icon: Icons.alternate_email,
                              errorText: profileState.usernameError,
                              onChanged: _onUsernameChanged,
                              suffixIcon: profileState.isCheckingUsername
                                  ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white70,
                                  ),
                                ),
                              )
                                  : profileState.isUsernameAvailable &&
                                  _usernameController.text.length >= 3
                                  ? const Icon(
                                Icons.check_circle,
                                color: Colors.greenAccent,
                              )
                                  : null,
                            ),
                            SizedBox(height: responsive.h(2)),
                            _buildGenderSelector(responsive, profileState),
                            SizedBox(height: responsive.h(2)),
                            GestureDetector(
                              onTap: _selectDate,
                              child: AbsorbPointer(
                                child: AppTextField(
                                  controller: _dobController,
                                  responsive: responsive,
                                  hint: "Date of Birth",
                                  icon: Icons.calendar_today_outlined,
                                  errorText: profileState.dobError,
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.h(4)),
                            profileState.isLoading
                                ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                                : PrimaryButton(
                              label: "Continue",
                              onPressed: _submitProfile,
                              responsive: responsive,
                            ),
                            SizedBox(height: responsive.h(3)),
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

  Widget _buildGenderSelector(
      Responsive responsive, ProfileCompleteState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildGenderOption('Male', responsive, state),
            SizedBox(width: responsive.w(4)),
            _buildGenderOption('Female', responsive, state),
            SizedBox(width: responsive.w(4)),
            _buildGenderOption('Other', responsive, state),
          ],
        ),
        if (state.genderError != null) ...[
          SizedBox(height: responsive.h(0.5)),
          Padding(
            padding: EdgeInsets.only(left: responsive.w(4)),
            child: Text(
              state.genderError!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenderOption(
      String gender, Responsive responsive, ProfileCompleteState state) {
    final isSelected = state.selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(profileCompleteProvider.notifier).setSelectedGender(gender);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: responsive.space(12),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            gender,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.isTablet ? 16 : 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}