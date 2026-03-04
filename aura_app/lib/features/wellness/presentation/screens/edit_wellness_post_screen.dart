import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../data/models/wellness_update.dart';
import '../../data/models/wellness_category.dart';
import '../providers/wellness_provider.dart';

class EditWellnessPostScreen extends ConsumerStatefulWidget {
  final WellnessUpdate update;
  const EditWellnessPostScreen({super.key, required this.update});

  @override
  ConsumerState<EditWellnessPostScreen> createState() =>
      _EditWellnessPostScreenState();
}

class _EditWellnessPostScreenState
    extends ConsumerState<EditWellnessPostScreen> {
  late TextEditingController _contentController;
  late WellnessCategory _selectedCategory;
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.update.content);
    _selectedCategory = widget.update.category;
    _currentImageUrl = widget.update.imageUrl;
    _contentController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed =
        _contentController.text != widget.update.content ||
        _selectedCategory != widget.update.category ||
        _selectedImage != null ||
        _currentImageUrl != widget.update.imageUrl;
    if (changed != _hasChanged) setState(() => _hasChanged = changed);
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
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Photo'),
      ],
    );

    if (cropped != null) {
      setState(() {
        _selectedImage = File(cropped.path);
        _currentImageUrl = null;
        _checkChanges();
      });
    }
  }

  void _showImageSourceSheet() {
    final brightness = Theme.of(context).brightness;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.containerFill(brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.containerBorder(brightness),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: AppColors.accent),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppColors.accent,
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null || _currentImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Remove Image',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedImage = null;
                    _currentImageUrl = null;
                    _checkChanges();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanged) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Discard changes?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Your edits will not be saved.'),
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

  Future<void> _save() async {
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final notifier = ref.read(wellnessNotifierProvider.notifier);
    final updated = await notifier.editUpdate(
      id: widget.update.id,
      content: _contentController.text.trim(),
      category: _selectedCategory,
      imageFile: _selectedImage,
      currentImageUrl: _currentImageUrl,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (updated != null) {
        Navigator.pop(context, updated);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _buildImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${AppConfig.baseUrl}$url';
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
                  title: 'Edit Post',
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
                            onPressed: _hasChanged ? _save : null,
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: _hasChanged
                                    ? AppColors.accent
                                    : AppColors.onSurfaceFaint(brightness),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(responsive.w(4)),
                    child: Column(
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
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = cat;
                                    _checkChanges();
                                  });
                                },
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
                                          : AppColors.iconButtonBorder(
                                              brightness,
                                            ),
                                    ),
                                  ),
                                  child: Text(
                                    '${cat.emoji} ${cat.displayName}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.onSurfaceMuted(
                                              brightness,
                                            ),
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
                        SizedBox(height: responsive.h(2.5)),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.containerFill(brightness),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.containerBorder(brightness),
                            ),
                          ),
                          child: TextField(
                            controller: _contentController,
                            maxLength: 1000,
                            maxLines: 10,
                            minLines: 6,
                            style: TextStyle(
                              color: AppColors.onSurface(brightness),
                              fontSize: 15,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: "What's on your mind?",
                              hintStyle: TextStyle(
                                color: AppColors.onSurfaceFaint(brightness),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(responsive.w(4)),
                              counterText: '',
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.h(2.5)),
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

  Widget _buildImageSection(Responsive responsive, Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IMAGE',
          style: TextStyle(
            color: AppColors.onSurfaceMuted(brightness),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: responsive.h(1)),
        if (_selectedImage != null || _currentImageUrl != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        _buildImageUrl(_currentImageUrl),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: AppColors.containerBorder(brightness),
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: _showImageSourceSheet,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _currentImageUrl = null;
                            _checkChanges();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.containerFill(brightness),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.containerBorder(brightness),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.accent,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a photo',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
