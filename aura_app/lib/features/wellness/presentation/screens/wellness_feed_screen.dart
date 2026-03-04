import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';
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
              _buildHeader(context, responsive),
              _buildCategoryFilter(context, ref, responsive, selectedCategory),
              Expanded(
                child: feedAsync.when(
                  data: (updates) {
                    if (updates.isEmpty) {
                      return const EmptyStateWidget(
                        icon: Icons.spa_outlined,
                        title: 'No wellness updates yet',
                        description: 'Be the first to share!',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(wellnessFeedProvider(selectedCategory));
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.w(4),
                          vertical: responsive.h(2),
                        ),
                        itemCount: updates.length,
                        itemBuilder: (context, index) {
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
                        Icon(
                          Icons.error_outline,
                          color: AppColors.onSurfaceMuted(brightness),
                          size: 48,
                        ),
                        SizedBox(height: responsive.h(2)),
                        Text(
                          'Failed to load feed',
                          style: TextStyle(
                            color: AppColors.onSurfaceMuted(brightness),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref.invalidate(
                            wellnessFeedProvider(selectedCategory),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/wellness-create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Responsive responsive) {
    return const AppHeader(title: 'Wellness Feed');
  }

  Widget _buildCategoryFilter(
    BuildContext context,
    WidgetRef ref,
    Responsive responsive,
    WellnessCategory? selected,
  ) {
    return SizedBox(
      height: responsive.h(5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: responsive.w(4)),
        children: [
          _buildFilterChip(context, ref, null, 'All', selected == null),
          ...WellnessCategory.values.map(
            (cat) => _buildFilterChip(
              context,
              ref,
              cat,
              '${cat.emoji} ${cat.displayName}',
              selected == cat,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    WellnessCategory? category,
    String label,
    bool isSelected,
  ) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () =>
            ref.read(selectedCategoryProvider.notifier).state = category,
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
      ),
    );
  }
}
