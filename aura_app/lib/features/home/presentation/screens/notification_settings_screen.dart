import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';

class _NotifSetting {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  bool enabled = true;

  _NotifSetting({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _pushEnabled = true;

  final List<_NotifSetting> _settings = [
    _NotifSetting(
      key: 'sos_alerts',
      title: 'SOS Alerts',
      subtitle: 'Emergency alerts from contacts',
      icon: Icons.warning_rounded,
    ),
    _NotifSetting(
      key: 'messages',
      title: 'Messages',
      subtitle: 'New chat messages',
      icon: Icons.chat_bubble_rounded,
    ),
    _NotifSetting(
      key: 'friend_requests',
      title: 'Friend Requests',
      subtitle: 'New follow & friend requests',
      icon: Icons.person_add_rounded,
    ),
    _NotifSetting(
      key: 'wellness',
      title: 'Wellness Updates',
      subtitle: 'Post approvals and feed updates',
      icon: Icons.spa_rounded,
    ),
    _NotifSetting(
      key: 'reminders',
      title: 'Activity Reminders',
      subtitle: 'Daily activity and alarm reminders',
      icon: Icons.alarm_rounded,
    ),
    _NotifSetting(
      key: 'announcements',
      title: 'Announcements',
      subtitle: 'App updates and broadcasts',
      icon: Icons.campaign_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkPushStatus();
  }

  Future<void> _checkPushStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    setState(() {
      _pushEnabled =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  Future<void> _togglePush(bool value) async {
    if (value) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      setState(() {
        _pushEnabled =
            settings.authorizationStatus == AuthorizationStatus.authorized;
      });
    } else {
      setState(() => _pushEnabled = false);
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
              const AppHeader(title: 'Notification Settings', showBack: true),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: responsive.horizontal(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: responsive.h(2)),
                      _buildPushToggle(responsive),
                      SizedBox(height: responsive.h(2)),
                      _buildCategorySection(responsive),
                      SizedBox(height: responsive.h(3)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPushToggle(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _pushEnabled
              ? [
                  AppColors.success.withValues(alpha: 0.2),
                  AppColors.success.withValues(alpha: 0.1),
                ]
              : [
                  AppColors.error.withValues(alpha: 0.2),
                  AppColors.error.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (_pushEnabled ? AppColors.success : AppColors.error)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (_pushEnabled ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _pushEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: _pushEnabled ? AppColors.success : AppColors.error,
              size: 24,
            ),
          ),
          SizedBox(width: responsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _pushEnabled
                      ? 'Notifications are enabled'
                      : 'Notifications are disabled',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: responsive.isTablet ? 12 : 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _pushEnabled,
            onChanged: _togglePush,
            activeTrackColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(Responsive responsive) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              responsive.w(4),
              responsive.h(2),
              responsive.w(4),
              responsive.h(1),
            ),
            child: Text(
              'Notification Categories',
              style: TextStyle(
                color: Colors.white54,
                fontSize: responsive.isTablet ? 13 : 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ..._settings.asMap().entries.map((entry) {
            final setting = entry.value;
            final isLast = entry.key == _settings.length - 1;
            return _buildSettingTile(setting, isLast, responsive);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    _NotifSetting setting,
    bool isLast,
    Responsive responsive,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(4),
        vertical: responsive.h(1.2),
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(setting.icon, size: 18, color: AppColors.accent),
          ),
          SizedBox(width: responsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  setting.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.isTablet ? 15 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  setting.subtitle,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: responsive.isTablet ? 11 : 10,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: setting.enabled && _pushEnabled,
            onChanged: _pushEnabled
                ? (val) => setState(() => setting.enabled = val)
                : null,
            activeTrackColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
