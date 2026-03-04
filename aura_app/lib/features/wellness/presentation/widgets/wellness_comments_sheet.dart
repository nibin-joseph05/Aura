import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/wellness_comment.dart';
import '../../data/models/wellness_update.dart';
import '../providers/wellness_provider.dart';

class WellnessCommentsSheet extends ConsumerStatefulWidget {
  final WellnessUpdate post;
  final String currentUserId;

  const WellnessCommentsSheet({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  ConsumerState<WellnessCommentsSheet> createState() =>
      _WellnessCommentsSheetState();
}

class _WellnessCommentsSheetState extends ConsumerState<WellnessCommentsSheet> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    final notifier = ref.read(wellnessNotifierProvider.notifier);
    final comment = await notifier.addComment(widget.post.id, text);
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (comment != null) {
        _commentController.clear();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add comment')));
      }
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final commentsAsync = ref.watch(wellnessCommentsProvider(widget.post.id));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? const Color(0xFF1A1E2E)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.containerBorder(brightness),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    color: AppColors.onSurface(brightness),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.post.commentsCount}',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.containerBorder(brightness)),
          Expanded(
            child: commentsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (_, __) => Center(
                child: Text(
                  'Failed to load comments',
                  style: TextStyle(color: AppColors.onSurfaceMuted(brightness)),
                ),
              ),
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: AppColors.onSurfaceFaint(brightness),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No comments yet.\nBe the first to comment!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.onSurfaceMuted(brightness),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  itemCount: comments.length,
                  itemBuilder: (_, i) {
                    final comment = comments[i];
                    return _CommentTile(
                      comment: comment,
                      isOwn: comment.userId == widget.currentUserId,
                      brightness: brightness,
                      timeAgo: _timeAgo(comment.createdAt),
                      onDelete: () async {
                        final notifier = ref.read(
                          wellnessNotifierProvider.notifier,
                        );
                        await notifier.deleteComment(
                          comment.id,
                          widget.post.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1, color: AppColors.containerBorder(brightness)),
          Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFill(brightness),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.inputBorder(brightness),
                      ),
                    ),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 3,
                      minLines: 1,
                      maxLength: 500,
                      style: TextStyle(
                        color: AppColors.onSurface(brightness),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add a comment…',
                        hintStyle: TextStyle(
                          color: AppColors.onSurfaceFaint(brightness),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        counterText: '',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isSubmitting ? null : _submitComment,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: _isSubmitting
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final WellnessComment comment;
  final bool isOwn;
  final Brightness brightness;
  final String timeAgo;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.isOwn,
    required this.brightness,
    required this.timeAgo,
    required this.onDelete,
  });

  String _buildImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${AppConfig.baseUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _buildImageUrl(comment.userProfileImage);
    final name = comment.userName ?? 'User';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            backgroundColor: AppColors.accent.withValues(alpha: 0.2),
            child: imageUrl.isEmpty
                ? Text(
                    initials,
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.containerFill(brightness),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: AppColors.containerBorder(brightness),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: AppColors.onSurface(brightness),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: AppColors.onSurfaceFaint(brightness),
                          fontSize: 11,
                        ),
                      ),
                      if (isOwn) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onDelete,
                          child: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: TextStyle(
                      color: AppColors.onSurfaceMuted(brightness),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
