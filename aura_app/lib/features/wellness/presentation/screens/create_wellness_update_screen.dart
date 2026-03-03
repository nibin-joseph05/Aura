import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some content'),
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
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (update != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update posted! Pending approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post update'),
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

    return Scaffold(
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
              _buildHeader(context, responsive, brightness),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(responsive.w(5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategorySelector(responsive, brightness),
                      SizedBox(height: responsive.h(3)),
                      _buildContentInput(responsive, brightness),
                      SizedBox(height: responsive.h(3)),
                      _buildSubmitButton(responsive, brightness),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Responsive responsive,
    Brightness brightness,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(4),
        vertical: responsive.h(2),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: AppColors.onSurface(brightness)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Share Wellness Update',
              style: TextStyle(
                color: AppColors.onSurface(brightness),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(Responsive responsive, Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            color: AppColors.onSurface(brightness),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.h(1)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: WellnessCategory.values.map((cat) {
            final isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
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
                  ),
                ),
              ),
            );
          }).toList(),
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
              "What's on your mind?",
              style: TextStyle(
                color: AppColors.onSurface(brightness),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_contentController.text.length}/500',
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
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
            maxLength: 500,
            maxLines: 6,
            style: TextStyle(color: AppColors.onSurface(brightness)),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Share your progress, tips, or motivation...',
              hintStyle: TextStyle(color: AppColors.onSurfaceFaint(brightness)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(responsive.w(4)),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(Responsive responsive, Brightness brightness) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: responsive.h(2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
                'Post Update',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
