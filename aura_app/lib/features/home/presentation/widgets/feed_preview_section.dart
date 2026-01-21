import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../wellness/data/models/wellness_update.dart';
import '../../../wellness/presentation/providers/wellness_provider.dart';

class FeedPreviewSection extends ConsumerWidget {
  final VoidCallback onSeeAll;

  const FeedPreviewSection({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final feedAsync = ref.watch(wellnessFeedProvider(null));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Wellness Feed',
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See All',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: responsive.isTablet ? 14 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.h(1.5)),
        feedAsync.when(
          data: (updates) {
            if (updates.isEmpty) {
              return _buildEmptyState(responsive);
            }
            return Column(
              children: updates.take(3).map((update) {
                return _buildFeedItem(responsive, update);
              }).toList(),
            );
          },
          loading: () => _buildLoadingState(responsive),
          error: (_, __) => _buildErrorState(responsive),
        ),
      ],
    );
  }

  Widget _buildFeedItem(Responsive responsive, WellnessUpdate update) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.h(1)),
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            child: Center(
              child: Text(
                update.userName?.isNotEmpty == true
                    ? update.userName![0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: responsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        update.userName ?? 'Anonymous',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        update.category.emoji,
                        style: TextStyle(
                          fontSize: responsive.isTablet ? 12 : 10,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.h(0.5)),
                Text(
                  update.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: responsive.isTablet ? 13 : 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.w(6)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.explore_outlined,
            color: Colors.white38,
            size: responsive.isTablet ? 40 : 32,
          ),
          SizedBox(height: responsive.h(1)),
          Text(
            'No posts yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: responsive.isTablet ? 14 : 12,
            ),
          ),
          Text(
            'Be the first to share!',
            style: TextStyle(
              color: Colors.white38,
              fontSize: responsive.isTablet ? 12 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.w(6)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorState(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          SizedBox(width: responsive.w(2)),
          Text(
            'Failed to load feed',
            style: TextStyle(
              color: Colors.white70,
              fontSize: responsive.isTablet ? 13 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
