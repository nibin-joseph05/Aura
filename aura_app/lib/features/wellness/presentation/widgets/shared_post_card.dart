import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/app_config.dart';
import '../providers/wellness_provider.dart';
import '../widgets/wellness_comments_sheet.dart';

class SharedPostCard extends ConsumerWidget {
  final String postId;

  const SharedPostCard({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(wellnessPostProvider(postId));

    return postAsync.when(
      data: (post) {
        final imageUrl = post.imageUrl != null
            ? (post.imageUrl!.startsWith('http')
                  ? post.imageUrl!
                  : '${AppConfig.baseUrl}${post.imageUrl}')
            : null;

        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => WellnessCommentsSheet(
                post: post,
                currentUserId: '',
              ),
            );
          },
          child: Container(
            width: 240,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2433),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.white.withValues(alpha: 0.05),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.accent.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              (post.userName != null &&
                                      post.userName!.isNotEmpty)
                                  ? post.userName![0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              post.userName ?? 'Anonymous',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.content,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.spa_outlined,
                        color: AppColors.accent,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View Wellness Post',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white38,
                        size: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        width: 240,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2433),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white24,
            ),
          ),
        ),
      ),
      error: (e, _) => Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2433),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white38, size: 16),
            SizedBox(width: 8),
            Text(
              'Post unavailable',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
