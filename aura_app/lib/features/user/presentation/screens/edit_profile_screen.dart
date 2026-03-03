import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/ui/snackbar/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../providers/edit_profile_provider.dart';
import '../providers/profile_image_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/date_of_birth_picker.dart';
import '../widgets/gender_selector.dart';
import '../widgets/image_crop_dialog.dart';
import '../widgets/phone_number_input.dart';
import '../widgets/verify_email_dialog.dart';
import '../widgets/verify_phone_dialog.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  Timer? _usernameDebounce;
  bool _initialized = false;
  String _originalUsername = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  void _loadUserData() {
    if (_initialized) return;
    _initialized = true;
    final user = ref.read(userProvider).user;
    if (user == null) return;

    _nameController.text = user.name ?? '';
    _usernameController.text = user.username ?? '';
    _originalUsername = user.username ?? '';

    final rawPhone = user.phone ?? '';
    String digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    }
    _phoneController.text = digits;
    _emailController.text = user.email ?? '';

    final gender = user.gender ?? '';
    final dob = user.dob ?? '';
    if (dob.isNotEmpty) {
      try {
        final parsed = DateTime.parse(dob);
        _dobController.text =
            '${_monthName(parsed.month)} ${parsed.day.toString().padLeft(2, '0')}, ${parsed.year}';
      } catch (_) {
        _dobController.text = dob;
      }
    }

    ref.read(editProfileProvider.notifier).initialize(gender, dob);
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String? _buildFullImageUrl(String? path, {int? cacheBust}) {
    if (path == null || path.isEmpty) return null;
    String url;
    if (path.startsWith('http')) {
      url = path;
    } else {
      final base = AppConfig.baseUrl;
      if (path.startsWith('/uploads/')) {
        url = '$base$path';
      } else {
        url = '$base/uploads/$path';
      }
    }
    if (cacheBust != null) return '$url?v=$cacheBust';
    return url;
  }

  void _onUsernameChanged(String value) {
    ref.read(editProfileProvider.notifier).onUsernameChanged(value);
    _usernameDebounce?.cancel();
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty && value.length >= 3) {
        ref
            .read(editProfileProvider.notifier)
            .checkUsernameAvailability(value, _originalUsername);
      }
    });
  }

  Future<void> _pickAndCropImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final br = Theme.of(ctx).brightness;
        return Container(
          decoration: BoxDecoration(
            color: br == Brightness.dark
                ? const Color(0xFF1A1A2E)
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.onSurfaceFaint(br),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Change Profile Photo',
                    style: TextStyle(
                      color: AppColors.onSurface(br),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt,
                      color: AppColors.accent,
                    ),
                    title: Text(
                      'Take Photo',
                      style: TextStyle(color: AppColors.onSurface(br)),
                    ),
                    onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: AppColors.accent,
                    ),
                    title: Text(
                      'Choose from Gallery',
                      style: TextStyle(color: AppColors.onSurface(br)),
                    ),
                    onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;

    final cropped = await ImageCropDialog.show(context, File(picked.path));
    if (cropped == null || !mounted) return;

    await ref.read(profileImageProvider.notifier).uploadImage(cropped);

    if (!mounted) return;
    final imgState = ref.read(profileImageProvider);
    if (!imgState.hasError) {
      final user = ref.read(userProvider).user;
      if (user != null) {
        await ref
            .read(userProvider.notifier)
            .updateProfile(uid: user.uid, profileImageUrl: imgState.imageUrl);
      }
    }
  }

  Future<void> _saveProfile() async {
    final profileState = ref.read(editProfileProvider);
    final user = ref.read(userProvider).user;
    if (user == null) return;

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final gender = profileState.selectedGender;
    final dob = profileState.selectedDob;

    final isValid = ref
        .read(editProfileProvider.notifier)
        .validateAll(name: name, username: username, gender: gender, dob: dob);

    if (!isValid) return;

    if (username != _originalUsername) {
      if (!profileState.isUsernameAvailable) {
        await ref
            .read(editProfileProvider.notifier)
            .checkUsernameAvailability(username, _originalUsername);
        final rechecked = ref.read(editProfileProvider);
        if (!rechecked.isUsernameAvailable) {
          if (mounted) {
            AppSnackbar.showError(
              context: context,
              message: 'Username is already taken',
            );
          }
          return;
        }
      }
    }

    ref.read(editProfileProvider.notifier).setLoading(true);

    try {
      await ref
          .read(userProvider.notifier)
          .updateProfile(
            uid: user.uid,
            name: name,
            username: username,
            gender: gender.isNotEmpty ? gender : null,
            dob: dob.isNotEmpty ? dob : null,
          );

      if (!mounted) return;
      ref.read(editProfileProvider.notifier).setLoading(false);
      _originalUsername = username;
      AppSnackbar.showSuccess(
        context: context,
        message: 'Profile updated successfully',
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ref.read(editProfileProvider.notifier).setLoading(false);
      AppSnackbar.showError(
        context: context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final user = ref.watch(userProvider).user;
    final profileState = ref.watch(editProfileProvider);
    final imgState = ref.watch(profileImageProvider);
    final notifier = ref.read(editProfileProvider.notifier);
    final brightness = Theme.of(context).brightness;

    final profileUrl = _buildFullImageUrl(
      imgState.imageUrl ?? user?.profileImageUrl,
      cacheBust: imgState.uploadedAt,
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.backgroundGradient(brightness),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const AppHeader(title: 'Edit Profile', showBack: true),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: responsive.horizontal(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: responsive.h(2)),
                        _buildProfileImageSection(
                          responsive,
                          profileUrl,
                          imgState,
                        ),
                        SizedBox(height: responsive.h(1)),
                        _buildPhotoNote(responsive, imgState),
                        SizedBox(height: responsive.h(2)),

                        AppTextField(
                          controller: _nameController,
                          responsive: responsive,
                          hint: 'Full Name',
                          icon: Icons.person_outline,
                          errorText: profileState.nameError,
                          onChanged: (v) => notifier.onNameChanged(v),
                        ),
                        SizedBox(height: responsive.h(2)),
                        AppTextField(
                          controller: _usernameController,
                          responsive: responsive,
                          hint: 'Username',
                          icon: Icons.alternate_email,
                          errorText: profileState.usernameError,
                          onChanged: _onUsernameChanged,
                          suffixIcon: _buildUsernameSuffix(profileState),
                        ),
                        SizedBox(height: responsive.h(2)),
                        _buildContactField(
                          responsive: responsive,
                          label: 'Email',
                          value: user?.email ?? 'Not set',
                          icon: Icons.email_outlined,
                          isVerified: user?.emailVerified ?? false,
                          canVerify:
                              (user?.email != null && user!.email!.isNotEmpty),
                          onVerify: () async {
                            if (user?.email == null) return;
                            final verified = await VerifyEmailDialog.show(
                              context,
                              user!.email!,
                            );
                            if (verified && mounted) {
                              AppSnackbar.showSuccess(
                                context: context,
                                message: 'Email verified successfully',
                              );
                            }
                          },
                        ),
                        SizedBox(height: responsive.h(2)),
                        _buildPhoneField(responsive, user),
                        SizedBox(height: responsive.h(2)),
                        GenderSelector(
                          selectedGender: profileState.selectedGender,
                          errorText: profileState.genderError,
                          onGenderSelected: (g) =>
                              notifier.setSelectedGender(g),
                          responsive: responsive,
                        ),
                        SizedBox(height: responsive.h(2)),
                        DateOfBirthPicker(
                          controller: _dobController,
                          responsive: responsive,
                          errorText: profileState.dobError,
                          onDateSelected: (d) => notifier.setSelectedDob(d),
                        ),
                        SizedBox(height: responsive.h(4)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: profileState.isLoading
                                ? null
                                : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: responsive.h(2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: profileState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: responsive.h(3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoNote(Responsive responsive, dynamic imgState) {
    final brightness = Theme.of(context).brightness;
    final wasJustUploaded = imgState.uploadedAt != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(3.5),
        vertical: responsive.h(1),
      ),
      decoration: BoxDecoration(
        color: wasJustUploaded
            ? Colors.greenAccent.withValues(alpha: 0.12)
            : AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: wasJustUploaded
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : AppColors.containerBorder(brightness),
        ),
      ),
      child: Row(
        children: [
          Icon(
            wasJustUploaded ? Icons.check_circle_outline : Icons.info_outline,
            size: 15,
            color: wasJustUploaded
                ? Colors.greenAccent
                : AppColors.onSurfaceFaint(brightness),
          ),
          SizedBox(width: responsive.w(2)),
          Expanded(
            child: Text(
              wasJustUploaded
                  ? 'Your profile photo was updated instantly — no need to tap Save Changes.'
                  : 'Profile photo is saved immediately when changed, independent of Save Changes.',
              style: TextStyle(
                color: wasJustUploaded
                    ? Colors.greenAccent
                    : AppColors.onSurfaceFaint(brightness),
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection(
    Responsive responsive,
    String? profileUrl,
    dynamic imgState,
  ) {
    final brightness = Theme.of(context).brightness;
    return Center(
      child: GestureDetector(
        onTap: _pickAndCropImage,
        child: Stack(
          children: [
            Container(
              width: responsive.isTablet ? 120 : 100,
              height: responsive.isTablet ? 120 : 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: imgState.isUploading
                    ? Container(
                        color: AppColors.iconButtonFill(brightness),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                      )
                    : profileUrl != null
                    ? Image.network(
                        profileUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.iconButtonFill(brightness),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accent,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.iconButtonFill(brightness),
                          child: Icon(
                            Icons.person,
                            size: responsive.isTablet ? 50 : 40,
                            color: AppColors.onSurfaceMuted(brightness),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.iconButtonFill(brightness),
                        child: Icon(
                          Icons.person,
                          size: responsive.isTablet ? 50 : 40,
                          color: AppColors.onSurfaceMuted(brightness),
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: brightness == Brightness.dark
                        ? const Color(0xFF0A1A2F)
                        : Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: responsive.isTablet ? 18 : 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildUsernameSuffix(EditProfileState state) {
    if (state.isCheckingUsername) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accent,
          ),
        ),
      );
    }

    final currentUsername = _usernameController.text.trim();
    if (currentUsername == _originalUsername && currentUsername.isNotEmpty) {
      return const Icon(
        Icons.check_circle,
        color: Colors.greenAccent,
        size: 22,
      );
    }

    if (state.isUsernameAvailable && currentUsername.length >= 3) {
      return const Icon(
        Icons.check_circle,
        color: Colors.greenAccent,
        size: 22,
      );
    }

    return null;
  }

  Widget _buildContactField({
    required Responsive responsive,
    required String label,
    required String value,
    required IconData icon,
    required bool isVerified,
    required bool canVerify,
    required VoidCallback onVerify,
  }) {
    final brightness = Theme.of(context).brightness;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(4),
            vertical: responsive.h(2),
          ),
          decoration: BoxDecoration(
            color: AppColors.containerFill(brightness),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isVerified
                  ? Colors.greenAccent.withValues(alpha: 0.5)
                  : AppColors.containerBorder(brightness),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.onSurfaceMuted(brightness)),
              SizedBox(width: responsive.w(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColors.onSurfaceMuted(brightness),
                        fontSize: responsive.isTablet ? 12 : 11,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: AppColors.onSurfaceMuted(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.lock_outline,
                color: AppColors.onSurfaceFaint(brightness),
                size: 18,
              ),
            ],
          ),
        ),
        if (isVerified)
          Positioned(
            top: -8,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Verified',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (!isVerified && canVerify)
          Positioned(
            top: -8,
            right: 12,
            child: GestureDetector(
              onTap: onVerify,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneField(Responsive responsive, dynamic user) {
    final isVerified = user?.phoneVerified ?? false;
    final hasPhone =
        (user?.phone != null && (user?.phone as String).isNotEmpty);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        PhoneNumberInput(
          controller: _phoneController,
          responsive: responsive,
          readOnly: true,
          showVerifiedBadge: false,
        ),
        if (isVerified)
          Positioned(
            top: -8,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Verified',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (!isVerified && hasPhone)
          Positioned(
            top: -8,
            right: 12,
            child: GestureDetector(
              onTap: () async {
                final phone = user?.phone as String;
                final verified = await VerifyPhoneDialog.show(context, phone);
                if (verified && mounted) {
                  AppSnackbar.showSuccess(
                    context: context,
                    message: 'Phone number verified successfully',
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
