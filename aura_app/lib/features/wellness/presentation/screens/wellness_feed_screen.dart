import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/screens/empty_state_widget.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../data/models/wellness_category.dart';
import '../providers/wellness_provider.dart';
import '../widgets/wellness_update_card.dart';

class WellnessFeedScreen extends ConsumerWidget {
  const WellnessFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final feedAsync = ref.watch(wellnessFeedProvider(selectedCategory));
    final brightness = Theme.of(context).brightness;
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          feedAsync.when(
            data: (updates) {
              if (updates.isEmpty) {
                return Center(
                  child: EmptyStateWidget(
                    icon: Icons.spa_outlined,
                    title: 'No wellness updates yet',
                    description: 'Be the first to share!',
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(wellnessFeedProvider(selectedCategory));
                },
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: updates.length + 1,
                  itemBuilder: (context, index) {
                    if (index == updates.length) {
                      return _buildNoMorePosts(brightness);
                    }
                    return WellnessUpdateCard(
                      update: updates[index],
                      currentUserId: currentUserId,
                      onDeleted: () => ref.invalidate(
                        wellnessFeedProvider(selectedCategory),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.white70, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load feed',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(wellnessFeedProvider(selectedCategory)),
                    child: Text(
                      'Retry',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AURA WELLNESS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            // TODO: Implement search
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildCategoryFilter(
                    context,
                    ref,
                    responsive,
                    selectedCategory,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/wellness-create'),
        backgroundColor: AppColors.accent,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }


  Widget _buildCategoryFilter(
    BuildContext context,
    WidgetRef ref,
    Responsive responsive,
    WellnessCategory? selected,
  ) {
    final brightness = Theme.of(context).brightness;
    return SizedBox(
      height: responsive.h(5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: responsive.w(4)),
        children: [
          _buildCategoryButton(
            label: 'All',
            isSelected: selected == null,
            onTap: () =>
                ref.read(selectedCategoryProvider.notifier).state = null,
            brightness: brightness,
          ),
          ...WellnessCategory.values.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildCategoryButton(
                label: '${cat.emoji} ${cat.displayName}',
                isSelected: selected == cat,
                onTap: () =>
                    ref.read(selectedCategoryProvider.notifier).state = cat,
                brightness: brightness,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Brightness brightness,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppColors.onSurfaceMuted(brightness),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNoMorePosts(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.spa_rounded, size: 64, color: AppColors.accent),
          ),
          const SizedBox(height: 24),
          Text(
            "You've reached the end!",
            style: TextStyle(
              color: AppColors.onSurface(brightness),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for more updates.",
            style: TextStyle(
              color: AppColors.onSurfaceMuted(brightness),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () {
              // TODO: Scroll to top
            },
            icon: const Icon(Icons.arrow_upward_rounded),
            label: const Text('Back to Top'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
