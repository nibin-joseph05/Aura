import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
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
  void didUpdateWidget(WellnessUpdateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.update != oldWidget.update) {
      setState(() => _update = widget.update);
    }
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
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final brightness = Theme.of(context).brightness;
    final profileImageUrl = _buildImageUrl(_update.userProfileImage);
    final postImageUrl = _buildImageUrl(_update.imageUrl);
    final name = _update.userName?.isNotEmpty == true
        ? _update.userName!
        : 'User';
    final isOwn = _update.userId == widget.currentUserId;

    return Container(
      width: size.width,
      height: size.height,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (postImageUrl.isNotEmpty)
            Image.network(
              postImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(brightness),
            )
          else
            _buildPlaceholder(brightness),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            right: 12,
            bottom: 100 + bottomInset,
            child: Column(
              children: [
                _buildActionButton(
                  icon: _update.likedByCurrentUser
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: '${_update.likesCount}',
                  color: _update.likedByCurrentUser ? Colors.red : Colors.white,
                  onTap: _toggleLike,
                  isAnimated: true,
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${_update.commentsCount}',
                  onTap: _showComments,
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    // TODO: Implement share
                  },
                ),
                if (isOwn) ...[
                  const SizedBox(height: 20),
                  _buildActionButton(
                    icon: Icons.more_vert_rounded,
                    label: 'Options',
                    onTap: _showOptionsMenu,
                  ),
                ],
              ],
            ),
          ),

          Positioned(
            left: 16,
            right: 80,
            bottom: 40 + bottomInset,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/user-profile',
                        arguments: _update.userId,
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : null,
                        backgroundColor: AppColors.accent.withValues(
                          alpha: 0.3,
                        ),
                        child: profileImageUrl.isEmpty
                            ? Text(
                                name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black54),
                              ],
                            ),
                          ),
                          Text(
                            _timeAgo(_update.createdAt),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _update.category.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _update.category.color.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '${_update.category.emoji} ${_update.category.displayName}',
                    style: TextStyle(
                      color: _update.category.color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _update.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(Brightness brightness) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.accent.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.spa_rounded,
          size: 100,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
    bool isAnimated = false,
  }) {
    Widget iconWidget = Icon(icon, color: color, size: 30);
    if (isAnimated) {
      iconWidget = ScaleTransition(scale: _likeScale, child: iconWidget);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: iconWidget,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 2, color: Colors.black)],
            ),
          ),
        ],
      ),
    );
  }
}
