import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../providers/profile_image_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/image_crop_dialog.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _selectedGender;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final user = ref.read(userProvider).user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _usernameController.text = user.username ?? '';
      _selectedGender = user.gender;
      if (user.dob != null) {
        _dateOfBirth = DateTime.tryParse(user.dob!);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
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

  Future<void> _pickAndCropImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.accent),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.accent,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
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

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              surface: const Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(userProvider).user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(userProvider.notifier)
          .updateProfile(
            uid: user.uid,
            name: _nameController.text.trim(),
            username: _usernameController.text.trim(),
            gender: _selectedGender,
            dob: _dateOfBirth?.toIso8601String().split('T').first,
          );

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final user = ref.watch(userProvider).user;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: responsive.h(2)),
                          _buildProfileImageSection(responsive),
                          SizedBox(height: responsive.h(3)),
                          _buildTextField(
                            responsive,
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: responsive.h(2)),
                          _buildTextField(
                            responsive,
                            controller: _usernameController,
                            label: 'Username',
                            icon: Icons.alternate_email,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a username';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: responsive.h(2)),
                          _buildReadOnlyField(
                            responsive,
                            label: 'Email',
                            value: user?.email ?? 'Not set',
                            icon: Icons.email_outlined,
                          ),
                          SizedBox(height: responsive.h(2)),
                          _buildReadOnlyField(
                            responsive,
                            label: 'Phone',
                            value: user?.phone ?? 'Not set',
                            icon: Icons.phone_outlined,
                          ),
                          SizedBox(height: responsive.h(2)),
                          _buildDatePicker(responsive),
                          SizedBox(height: responsive.h(2)),
                          _buildGenderSelector(responsive),
                          SizedBox(height: responsive.h(4)),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
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
                              child: _isLoading
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(Responsive responsive) {
    final user = ref.watch(userProvider).user;
    final imgState = ref.watch(profileImageProvider);
    final profileUrl = _buildFullImageUrl(
      imgState.imageUrl ?? user?.profileImageUrl,
      cacheBust: imgState.uploadedAt,
    );

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
                        color: Colors.white24,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
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
                            color: Colors.white24,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white54,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white24,
                          child: Icon(
                            Icons.person,
                            size: responsive.isTablet ? 50 : 40,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.white24,
                        child: Icon(
                          Icons.person,
                          size: responsive.isTablet ? 50 : 40,
                          color: Colors.white,
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
                  border: Border.all(color: const Color(0xFF0A1A2F), width: 2),
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

  Widget _buildTextField(
    Responsive responsive, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(
    Responsive responsive, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38),
          SizedBox(width: responsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: responsive.isTablet ? 12 : 11,
                  ),
                ),
                Text(value, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Icon(Icons.lock_outline, color: Colors.white24, size: 18),
        ],
      ),
    );
  }

  Widget _buildDatePicker(Responsive responsive) {
    final displayDate = _dateOfBirth != null
        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
        : 'Select date';

    return GestureDetector(
      onTap: _selectDateOfBirth,
      child: Container(
        padding: EdgeInsets.all(responsive.w(4)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cake_outlined,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            SizedBox(width: responsive.w(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: responsive.isTablet ? 12 : 11,
                    ),
                  ),
                  Text(
                    displayDate,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector(Responsive responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: responsive.isTablet ? 14 : 12,
          ),
        ),
        SizedBox(height: responsive.h(1)),
        Row(
          children: [
            _buildGenderChip(responsive, 'Male'),
            SizedBox(width: responsive.w(2)),
            _buildGenderChip(responsive, 'Female'),
            SizedBox(width: responsive.w(2)),
            _buildGenderChip(responsive, 'Other'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(Responsive responsive, String gender) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.w(4),
          vertical: responsive.h(1.2),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: Colors.white,
            fontSize: responsive.isTablet ? 14 : 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
