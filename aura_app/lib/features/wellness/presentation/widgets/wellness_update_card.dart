import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/wellness_update.dart';
import '../providers/wellness_provider.dart';
import '../screens/edit_wellness_post_screen.dart';
import 'wellness_comments_sheet.dart';

class WellnessUpdateCard extends ConsumerStatefulWidget {
  final WellnessUpdate update;
  final String currentUserId;
  final VoidCallback? onDeleted;

  const WellnessUpdateCard({
    super.key,
    required this.update,
    required this.currentUserId,
    this.onDeleted,
  });

  @override
  ConsumerState<WellnessUpdateCard> createState() => _WellnessUpdateCardState();
}

class _WellnessUpdateCardState extends ConsumerState<WellnessUpdateCard>
    with SingleTickerProviderStateMixin {
  late WellnessUpdate _update;
  bool _isLiking = false;
  late AnimationController _likeAnimController;
  late Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _update = widget.update;
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _likeScale =
        Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut))
            .animate(_likeAnimController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _likeAnimController.reverse();
            }
          });
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  String _buildImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${AppConfig.baseUrl}$url';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;
    setState(() => _isLiking = true);
    _likeAnimController.forward();
    final notifier = ref.read(wellnessNotifierProvider.notifier);
    final result = await notifier.toggleLike(_update);
    if (mounted && result != null) {
      setState(() => _update = result);
    }
    if (mounted) setState(() => _isLiking = false);
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WellnessCommentsSheet(
        post: _update,
        currentUserId: widget.currentUserId,
      ),
    );
  }

  void _showOptionsMenu() {
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
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppColors.accent),
              title: Text(
                'Edit post',
                style: TextStyle(color: AppColors.onSurface(brightness)),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditWellnessPostScreen(update: _update),
                  ),
                );
                if (result is WellnessUpdate && mounted) {
                  setState(() => _update = result);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete post',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: const Text('Delete post?'),
                    content: const Text(
                      'This post will be permanently deleted.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(d, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(d, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final notifier = ref.read(wellnessNotifierProvider.notifier);
                  await notifier.deleteUpdate(_update.id);
                  widget.onDeleted?.call();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isOwn = _update.userId == widget.currentUserId;
    final profileImageUrl = _buildImageUrl(_update.userProfileImage);
    final postImageUrl = _buildImageUrl(_update.imageUrl);
    final name = _update.userName?.isNotEmpty == true
        ? _update.userName!
        : 'User';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.containerBorder(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.userProfile,
                    arguments: _update.userId,
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                    child: profileImageUrl.isEmpty
                        ? Text(
                            initials,
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.userProfile,
                          arguments: _update.userId,
                        ),
                        child: Text(
                          name,
                          style: TextStyle(
                            color: AppColors.onSurface(brightness),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _update.category.color.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_update.category.emoji} ${_update.category.displayName}',
                              style: TextStyle(
                                color: _update.category.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _timeAgo(_update.createdAt),
                            style: TextStyle(
                              color: AppColors.onSurfaceFaint(brightness),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isOwn)
                  IconButton(
                    onPressed: _showOptionsMenu,
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.onSurfaceMuted(brightness),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Text(
              _update.content,
              style: TextStyle(
                color: AppColors.onSurface(brightness),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          if (postImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Image.network(
                postImageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        ScaleTransition(
                          scale: _likeScale,
                          child: Icon(
                            _update.likedByCurrentUser
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _update.likedByCurrentUser
                                ? Colors.red
                                : AppColors.onSurfaceMuted(brightness),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_update.likesCount}',
                          style: TextStyle(
                            color: _update.likedByCurrentUser
                                ? Colors.red
                                : AppColors.onSurfaceMuted(brightness),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showComments,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: AppColors.onSurfaceMuted(brightness),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_update.commentsCount}',
                          style: TextStyle(
                            color: AppColors.onSurfaceMuted(brightness),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
