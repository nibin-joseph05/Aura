import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/model/comment_model.dart';

class CommentCard extends StatefulWidget {
  final CommentModel comment;
  final VoidCallback? onTranslate;
  final bool isTranslating;

  const CommentCard({
    super.key,
    required this.comment,
    this.onTranslate,
    this.isTranslating = false,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final comment = widget.comment;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Icon(Icons.person, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _showTranslation && comment.hasTranslation
                ? comment.translatedContent!
                : comment.originalContent,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textPrimary,
            ),
          ),
          if (comment.canTranslate || comment.hasTranslation) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                if (comment.hasTranslation) {
                  setState(() => _showTranslation = !_showTranslation);
                } else if (widget.onTranslate != null) {
                  widget.onTranslate!();
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isTranslating)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(Icons.translate, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    comment.hasTranslation
                        ? (_showTranslation
                              ? 'Show original'
                              : 'Show translation')
                        : 'See translation',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (comment.translationStatus == 'FAILED') ...[
            const SizedBox(height: 6),
            Text(
              'Translation unavailable',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.warning,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
