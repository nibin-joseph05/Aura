import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/ui/snackbar/app_snackbar.dart';
import '../../../../core/widgets/loading/ghost_running.dart';
import '../providers/profile_image_provider.dart';

class ProfileImagePicker extends ConsumerStatefulWidget {
  final String? initialImageUrl;
  final Function(String?) onImageChanged;
  final Responsive responsive;

  const ProfileImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onImageChanged,
    required this.responsive,
  });

  @override
  ConsumerState<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends ConsumerState<ProfileImagePicker> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      if (widget.initialImageUrl != null) {
        Future(() {
          ref
              .read(profileImageProvider.notifier)
              .initializeWithUrl(widget.initialImageUrl);
        });
      }
    }
  }

  String? _buildFullUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    final base = AppConfig.baseUrl;
    if (path.startsWith('profile-images/')) {
      return '$base/uploads/$path';
    }
    return '$base/uploads/$path';
  }

  Future<void> _pickImage(BuildContext sheetContext, ImageSource source) async {
    Navigator.pop(sheetContext);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GhostRunning(
        primaryMessage: "Uploading image...",
        secondaryMessage: "Please wait",
      ),
    );

    await ref
        .read(profileImageProvider.notifier)
        .uploadImage(File(pickedFile.path));

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();

    final state = ref.read(profileImageProvider);
    if (state.hasError) {
      AppSnackbar.showError(
        context: context,
        message: state.errorMessage ?? 'Failed to upload image',
      );
    } else {
      widget.onImageChanged(state.imageUrl);
    }
  }

  void _removeImage(BuildContext sheetContext) {
    Navigator.pop(sheetContext);
    ref.read(profileImageProvider.notifier).removeImage();
    widget.onImageChanged(null);
  }

  void _showImageSourceDialog() {
    final state = ref.read(profileImageProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: widget.responsive.h(2)),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: widget.responsive.h(2)),
              const Text(
                'Choose Profile Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: widget.responsive.h(2)),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white70),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _pickImage(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white70),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _pickImage(ctx, ImageSource.gallery),
              ),
              if (state.hasImage ||
                  (widget.initialImageUrl != null && !state.wasRemoved))
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () => _removeImage(ctx),
                ),
              SizedBox(height: widget.responsive.h(2)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileImageProvider);
    final rawUrl = state.wasRemoved
        ? state.imageUrl
        : (state.imageUrl ?? widget.initialImageUrl);
    final displayUrl = _buildFullUrl(rawUrl);

    return GestureDetector(
      onTap: state.isUploading ? null : _showImageSourceDialog,
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: displayUrl != null && displayUrl.isNotEmpty
                  ? Image.network(
                      displayUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          SizedBox(height: widget.responsive.h(0.8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                color: state.isUploading ? Colors.white38 : Colors.white70,
                size: 14,
              ),
              SizedBox(width: widget.responsive.w(1.5)),
              Text(
                state.isUploading ? 'Uploading...' : 'Tap to add photo',
                style: TextStyle(
                  color: state.isUploading ? Colors.white38 : Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.person, size: 44, color: Colors.white38),
    );
  }
}
