import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool _isLoading = false;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.update.content);
    _selectedCategory = widget.update.category;
    _contentController.addListener(() {
      final changed =
          _contentController.text != widget.update.content ||
          _selectedCategory != widget.update.category;
      if (changed != _hasChanged) setState(() => _hasChanged = changed);
    });
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
                                    _hasChanged =
                                        cat != widget.update.category ||
                                        _contentController.text !=
                                            widget.update.content;
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
                            onChanged: (_) => setState(() {}),
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
}
