import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../data/models/wellness_update.dart';
import '../providers/wellness_provider.dart';

class WellnessUpdateCard extends ConsumerStatefulWidget {
  final WellnessUpdate update;

  const WellnessUpdateCard({super.key, required this.update});

  @override
  ConsumerState<WellnessUpdateCard> createState() => _WellnessUpdateCardState();
}

class _WellnessUpdateCardState extends ConsumerState<WellnessUpdateCard> {
  late WellnessUpdate _update;

  @override
  void initState() {
    super.initState();
    _update = widget.update;
  }

  @override
  void didUpdateWidget(WellnessUpdateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.update.id != widget.update.id) {
      _update = widget.update;
    }
  }

  Future<void> _toggleLike() async {
    final notifier = ref.read(wellnessNotifierProvider.notifier);
    final updated = await notifier.toggleLike(_update);
    if (updated != null && mounted) {
      setState(() => _update = updated);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: responsive.h(2)),
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.userProfile,
                  arguments: _update.userId,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  child: Center(
                    child: Text(
                      _update.userName?.isNotEmpty == true
                          ? _update.userName![0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.w(3)),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.userProfile,
                    arguments: _update.userId,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _update.userName ?? 'Anonymous',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTime(_update.createdAt),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_update.category.emoji} ${_update.category.displayName}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(2)),
          Text(
            _update.content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          if (_update.imageUrl != null) ...[
            SizedBox(height: responsive.h(2)),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _update.imageUrl!,
                width: double.infinity,
                height: responsive.h(20),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          SizedBox(height: responsive.h(2)),
          Row(
            children: [
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    Icon(
                      _update.likedByCurrentUser
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _update.likedByCurrentUser
                          ? Colors.red
                          : Colors.white.withValues(alpha: 0.7),
                      size: 22,
                    ),
                    SizedBox(width: responsive.w(1)),
                    Text(
                      '${_update.likesCount}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: responsive.w(5)),
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  SizedBox(width: responsive.w(1)),
                  Text(
                    '${_update.commentsCount}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
