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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: responsive.isTablet ? 18 : 15,
                  ),
                ),
                SizedBox(width: responsive.w(2)),
                Text(
                  'Vibes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.isTablet ? 20 : 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: responsive.isTablet ? 13 : 11,
                    fontWeight: FontWeight.w600,
                  ),
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
                return _buildVibeCard(context, responsive, update);
              }).toList(),
            );
          },
          loading: () => _buildLoadingState(responsive),
          error: (_, __) => _buildErrorState(responsive),
        ),
      ],
    );
  }

  Widget _buildVibeCard(
    BuildContext context,
    Responsive responsive,
    WellnessUpdate update,
  ) {
    final initial = update.userName?.isNotEmpty == true
        ? update.userName![0].toUpperCase()
        : '?';

    final categoryColors = _getCategoryColors(update.category.emoji);

    return Container(
      margin: EdgeInsets.only(bottom: responsive.h(1.2)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.all(responsive.w(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: categoryColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColors[0].withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: responsive.isTablet ? 18 : 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: responsive.w(3)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            update.userName ?? 'Anonymous',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.isTablet ? 14 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _formatTime(update.createdAt),
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: responsive.isTablet ? 11 : 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        update.category.emoji,
                        style: TextStyle(
                          fontSize: responsive.isTablet ? 14 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.h(1.2)),
                Text(
                  update.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: responsive.isTablet ? 13 : 12,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: responsive.h(1.2)),
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.favorite_border_rounded,
                      label: '${update.likesCount}',
                      responsive: responsive,
                    ),
                    SizedBox(width: responsive.w(4)),
                    _buildActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: '${update.commentsCount}',
                      responsive: responsive,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.bookmark_border_rounded,
                      color: Colors.white38,
                      size: responsive.isTablet ? 18 : 15,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Responsive responsive,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white38, size: responsive.isTablet ? 17 : 14),
        SizedBox(width: responsive.w(1)),
        Text(
          label,
          style: TextStyle(
            color: Colors.white38,
            fontSize: responsive.isTablet ? 12 : 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Color> _getCategoryColors(String emoji) {
    switch (emoji) {
      case '🧘':
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
      case '💪':
        return [const Color(0xFF11998E), const Color(0xFF38EF7D)];
      case '😊':
        return [const Color(0xFFFFD200), const Color(0xFFF7971E)];
      case '😴':
        return [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)];
      default:
        return [const Color(0xFF2196F3), const Color(0xFF00BCD4)];
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildEmptyState(Responsive responsive) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: responsive.h(4),
        horizontal: responsive.w(6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const Text('✨', style: TextStyle(fontSize: 36)),
          SizedBox(height: responsive.h(1)),
          Text(
            'No vibes yet',
            style: TextStyle(
              color: Colors.white60,
              fontSize: responsive.isTablet ? 15 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: responsive.h(0.4)),
          Text(
            'Be the first to share your wellness journey!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: responsive.isTablet ? 12 : 11,
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
        borderRadius: BorderRadius.circular(18),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          SizedBox(width: responsive.w(2)),
          Text(
            'Failed to load vibes',
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
