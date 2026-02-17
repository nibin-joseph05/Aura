import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/loading/ghost_running.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../../core/widgets/screens/empty_state_widget.dart';
import '../../../messaging/data/service/messaging_api_service.dart';

class FollowListScreen extends ConsumerStatefulWidget {
  final String userId;
  final bool isFollowers;

  const FollowListScreen({
    super.key,
    required this.userId,
    required this.isFollowers,
  });

  @override
  ConsumerState<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends ConsumerState<FollowListScreen> {
  final _api = MessagingApiService();
  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!_hasMore && !_isLoading) return;

    try {
      final result = widget.isFollowers
          ? await _api.getFollowers(widget.userId, page: _page)
          : await _api.getFollowing(widget.userId, page: _page);

      final content =
          (result['content'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      if (mounted) {
        setState(() {
          _items.addAll(content);
          _isLoading = false;
          _hasMore = content.length >= 20;
          _page++;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(title: widget.isFollowers ? 'Followers' : 'Following'),
              Expanded(child: _buildBody(responsive)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Responsive responsive) {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: GhostRunning());
    }

    if (_items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline_rounded,
        title: widget.isFollowers ? 'No Followers' : 'Not Following Anyone',
        message: widget.isFollowers
            ? 'No one is following this user yet'
            : 'This user isn\'t following anyone yet',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(4),
        vertical: responsive.h(1),
      ),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          _loadData();
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              ),
            ),
          );
        }

        final item = _items[index];
        return _buildUserTile(item, responsive, index);
      },
    );
  }

  Widget _buildUserTile(
    Map<String, dynamic> item,
    Responsive responsive,
    int index,
  ) {
    final userId = widget.isFollowers
        ? item['followerId'] ?? ''
        : item['followingId'] ?? '';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 250 + (index * 40).clamp(0, 200)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.userProfile,
          arguments: userId,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: responsive.h(0.8)),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(4),
            vertical: responsive.h(1.2),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: Colors.white24,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.w(3)),
              Expanded(
                child: Text(
                  userId,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.isTablet ? 15 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white38,
                size: responsive.isTablet ? 22 : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
