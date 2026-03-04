import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../data/models/wellness_category.dart';
import '../providers/wellness_provider.dart';

class CreateWellnessUpdateScreen extends ConsumerStatefulWidget {
  const CreateWellnessUpdateScreen({super.key});

  @override
  ConsumerState<CreateWellnessUpdateScreen> createState() =>
      _CreateWellnessUpdateScreenState();
}

class _CreateWellnessUpdateScreenState
    extends ConsumerState<CreateWellnessUpdateScreen> {
  final _contentController = TextEditingController();
  WellnessCategory _selectedCategory = WellnessCategory.general;
  File? _selectedImage;
  bool _isLoading = false;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() {
      if (!_hasChanged && _contentController.text.isNotEmpty) {
        setState(() => _hasChanged = true);
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanged && _selectedImage == null) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Discard post?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('If you leave, your post draft will be discarded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Keep editing',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.original,
          ],
        ),
        IOSUiSettings(title: 'Crop Photo'),
      ],
    );
    if (cropped != null) {
      setState(() {
        _selectedImage = File(cropped.path);
        _hasChanged = true;
      });
    }
  }

  void _showImageSourceSheet() {
    final brightness = Theme.of(context).brightness;
    showModalBottomSheet(
      context: context,
      backgroundColor: brightness == Brightness.dark
          ? const Color(0xFF1A1E2E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.containerBorder(brightness),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.accent,
                ),
                title: Text(
                  'Camera',
                  style: TextStyle(color: AppColors.onSurface(brightness)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.accent,
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(color: AppColors.onSurface(brightness)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Remove photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedImage = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something to share'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    final notifier = ref.read(wellnessNotifierProvider.notifier);
    final update = await notifier.createUpdate(
      content: _contentController.text.trim(),
      category: _selectedCategory,
      imageFile: _selectedImage,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (update != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Your post is live!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final brightness = Theme.of(context).brightness;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canPop = await _onWillPop();
        if (canPop && context.mounted) Navigator.pop(context);
      },
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
                AppHeader(
                  title: 'Share a Post',
                  showBack: true,
                  onBack: () async {
                    final canPop = await _onWillPop();
                    if (canPop && context.mounted) Navigator.pop(context);
                  },
                  actions: [
                    _isLoading
                        ? Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.accent,
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: _submit,
                            child: Text(
                              'Post',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(4),
                      vertical: responsive.h(1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategorySelector(responsive, brightness),
                        SizedBox(height: responsive.h(2.5)),
                        _buildContentInput(responsive, brightness),
                        SizedBox(height: responsive.h(2)),
                        _buildImageSection(responsive, brightness),
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

  Widget _buildCategorySelector(Responsive responsive, Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY',
          style: TextStyle(
            color: AppColors.onSurfaceMuted(brightness),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: responsive.h(1)),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: WellnessCategory.values.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.iconButtonFill(brightness),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.iconButtonBorder(brightness),
                    ),
                  ),
                  child: Text(
                    '${cat.emoji} ${cat.displayName}',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.onSurfaceMuted(brightness),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContentInput(Responsive responsive, Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "WHAT'S ON YOUR MIND?",
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${_contentController.text.length}/1000',
              style: TextStyle(
                color: _contentController.text.length > 900
                    ? Colors.orange
                    : AppColors.onSurfaceFaint(brightness),
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.h(1)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.containerFill(brightness),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.containerBorder(brightness)),
          ),
          child: TextField(
            controller: _contentController,
            maxLength: 1000,
            maxLines: 8,
            minLines: 5,
            style: TextStyle(
              color: AppColors.onSurface(brightness),
              fontSize: 15,
              height: 1.5,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText:
                  'Share how you\'re doing, what\'s helping you, or any wellness thought…',
              hintStyle: TextStyle(
                color: AppColors.onSurfaceFaint(brightness),
                height: 1.5,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(responsive.w(4)),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(Responsive responsive, Brightness brightness) {
    if (_selectedImage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PHOTO',
            style: TextStyle(
              color: AppColors.onSurfaceMuted(brightness),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: responsive.h(1)),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: responsive.h(25),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedImage = null),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: double.infinity,
        height: responsive.h(12),
        decoration: BoxDecoration(
          color: AppColors.containerFill(brightness),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.containerBorder(brightness)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.accent,
              size: 32,
            ),
            SizedBox(height: responsive.h(0.5)),
            Text(
              'Add Photo',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              'Camera or Gallery',
              style: TextStyle(
                color: AppColors.onSurfaceFaint(brightness),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
