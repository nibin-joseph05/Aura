import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/loading/ghost_running.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../../core/widgets/screens/empty_state_widget.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../data/service/notification_api_service.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final _api = NotificationApiService();
  final List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _notifications.clear();
    }

    if (!_hasMore && !refresh) return;

    setState(() => _isLoading = true);
    final userId = ref.read(userProvider).user?.uid ?? '';

    try {
      final userResult = await _api.getNotifications(userId, page: _page);
      final broadcastResult = await _api.getBroadcastNotifications(page: _page);

      final userItems =
          (userResult['content'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final broadcastItems =
          (broadcastResult['content'] as List?)?.cast<Map<String, dynamic>>() ??
          [];

      final all = [...userItems, ...broadcastItems];
      all.sort((a, b) {
        final aTime = a['createdAt'] ?? '';
        final bTime = b['createdAt'] ?? '';
        return bTime.toString().compareTo(aTime.toString());
      });

      if (mounted) {
        setState(() {
          _notifications.addAll(all);
          _isLoading = false;
          _hasMore = userItems.length >= 20 || broadcastItems.length >= 20;
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
    final brightness = Theme.of(context).brightness;

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
              const AppHeader(title: 'Notifications'),
              Expanded(child: _buildBody(responsive, brightness)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Responsive responsive, Brightness brightness) {
    if (_isLoading && _notifications.isEmpty) {
      return const Center(child: GhostRunning());
    }

    if (_notifications.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.notifications_off_rounded,
        title: 'No Notifications',
        message: 'You\'re all caught up!',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(refresh: true),
      color: brightness == Brightness.dark ? Colors.white : AppColors.primary,
      backgroundColor: brightness == Brightness.dark
          ? AppColors.splashMedium
          : Colors.white,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.w(4),
          vertical: responsive.h(1),
        ),
        itemCount: _notifications.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            if (!_isLoading) {
              _loadNotifications();
            }
            return Padding(
              padding: EdgeInsets.symmetric(vertical: responsive.h(2)),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            );
          }

          return _buildNotificationCard(
            _notifications[index],
            responsive,
            index,
            brightness,
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    Responsive responsive,
    int index,
    Brightness brightness,
  ) {
    final title = notification['title'] ?? '';
    final body = notification['body'] ?? '';
    final type = notification['type'] ?? '';
    final deepLink = notification['deepLink'];
    final isBroadcast = notification['isBroadcast'] == true;
    final createdAt = notification['createdAt'] ?? '';

    IconData icon;
    Color iconColor;
    switch (type) {
      case 'FOLLOW_REQUEST':
        icon = Icons.person_add_rounded;
        iconColor = AppColors.accent;
        break;
      case 'FOLLOW_ACCEPTED':
        icon = Icons.how_to_reg_rounded;
        iconColor = AppColors.success;
        break;
      case 'NEW_MESSAGE':
        icon = Icons.chat_bubble_rounded;
        iconColor = AppColors.primaryLight;
        break;
      case 'POST_APPROVED':
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        break;
      case 'POST_REJECTED':
        icon = Icons.cancel_rounded;
        iconColor = AppColors.error;
        break;
      case 'SOS_TRIGGERED':
        icon = Icons.warning_rounded;
        iconColor = AppColors.error;
        break;
      case 'SOS_RESOLVED':
        icon = Icons.check_circle_outline_rounded;
        iconColor = AppColors.success;
        break;
      case 'AUTH_ALERT':
        icon = Icons.security_rounded;
        iconColor = AppColors.info;
        break;
      case 'ACCOUNT_ALERT':
        icon = Icons.manage_accounts_rounded;
        iconColor = AppColors.primary;
        break;
      default:
        icon = isBroadcast
            ? Icons.campaign_rounded
            : Icons.notifications_rounded;
        iconColor = AppColors.warning;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 300)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _handleNotificationTap(deepLink),
        child: Container(
          margin: EdgeInsets.only(bottom: responsive.h(1)),
          padding: EdgeInsets.all(responsive.w(4)),
          decoration: BoxDecoration(
            color: AppColors.containerFill(brightness),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.containerBorder(brightness)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              SizedBox(width: responsive.w(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.onSurface(brightness),
                        fontSize: responsive.isTablet ? 15 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (body.toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: TextStyle(
                          color: AppColors.onSurfaceMuted(brightness),
                          fontSize: responsive.isTablet ? 13 : 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (createdAt.toString().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(createdAt.toString()),
                        style: TextStyle(
                          color: AppColors.onSurfaceFaint(brightness),
                          fontSize: responsive.isTablet ? 11 : 9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(String? deepLink) {
    if (deepLink == null || deepLink.isEmpty) return;

    if (deepLink.startsWith('/chat/conversation')) {
      Navigator.pushNamed(context, AppRoutes.chatScreen);
    } else if (deepLink.startsWith('/follow-requests')) {
      Navigator.pushNamed(context, AppRoutes.followRequests);
    } else if (deepLink.startsWith('/wellness-feed')) {
      Navigator.pushNamed(context, AppRoutes.wellnessFeed);
    } else if (deepLink.startsWith('/sos')) {
      Navigator.pushNamed(context, AppRoutes.sosTrigger);
    } else {
      Navigator.pushNamed(context, deepLink);
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (_) {
      return '';
    }
  }
}
