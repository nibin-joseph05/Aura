import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_colors.dart';
import '../../ui/responsive/responsive.dart';

/// A dismissable banner that encourages users to re-enable push notifications.
/// Shows periodically on the home screen when notification permissions are
/// denied or not determined. Users can snooze for 3 days.
class NotificationEncourageCard extends StatefulWidget {
  const NotificationEncourageCard({super.key});

  @override
  State<NotificationEncourageCard> createState() =>
      _NotificationEncourageCardState();
}

class _NotificationEncourageCardState extends State<NotificationEncourageCard>
    with SingleTickerProviderStateMixin {
  static const _snoozeKey = 'notif_encourage_snoozed_until';
  bool _shouldShow = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _checkPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final snoozedUntil = prefs.getInt(_snoozeKey) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch < snoozedUntil) {
      return;
    }

    if (!mounted) return;
    setState(() => _shouldShow = true);
    _controller.forward();
  }

  Future<void> _onEnable() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      _dismiss();
    } else {
      await FirebaseMessaging.instance.getNotificationSettings(); // refresh
    }
  }

  Future<void> _snooze() async {
    final prefs = await SharedPreferences.getInstance();
    final threeDaysLater = DateTime.now()
        .add(const Duration(days: 3))
        .millisecondsSinceEpoch;
    await prefs.setInt(_snoozeKey, threeDaysLater);
    _dismiss();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _shouldShow = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return const SizedBox.shrink();

    final responsive = Responsive.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.only(bottom: responsive.space(4)),
        padding: EdgeInsets.all(responsive.space(4)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF283593)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(responsive.space(2.5)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(responsive.radius(12)),
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.warning,
                    size: responsive.text(22),
                  ),
                ),
                SizedBox(width: responsive.space(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stay in the loop!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.text(15),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: responsive.space(1)),
                      Text(
                        'Enable notifications so you never miss SOS alerts, messages, or wellness updates.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: responsive.text(12),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.space(3)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _snooze,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          responsive.radius(10),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: responsive.space(2.5),
                      ),
                    ),
                    child: Text(
                      'Later',
                      style: TextStyle(fontSize: responsive.text(13)),
                    ),
                  ),
                ),
                SizedBox(width: responsive.space(3)),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _onEnable,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          responsive.radius(10),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: responsive.space(2.5),
                      ),
                    ),
                    child: Text(
                      'Enable Notifications',
                      style: TextStyle(
                        fontSize: responsive.text(13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
