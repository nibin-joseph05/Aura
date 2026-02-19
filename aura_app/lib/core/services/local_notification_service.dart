import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// A central service for scheduling and showing local notifications.
/// Used for daily activity reminders and other in-app alerts.
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationChannel _activityChannel =
      AndroidNotificationChannel(
        'activity_reminders',
        'Activity Reminders',
        description: 'Reminders for your daily activities',
        importance: Importance.high,
        playSound: true,
      );

  Future<void> initialize() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_activityChannel);

    _initialized = true;
  }

  /// Show an immediate activity reminder notification.
  Future<void> showActivityReminder({
    required int id,
    required String activityName,
    String? description,
  }) async {
    await _ensureInitialized();
    try {
      await _plugin.show(
        id,
        '⏰ Activity Reminder',
        description?.isNotEmpty == true
            ? '$activityName — $description'
            : 'Time for: $activityName',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _activityChannel.id,
            _activityChannel.name,
            channelDescription: _activityChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap(
              '@mipmap/ic_launcher',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[LocalNotification] showActivityReminder error: $e');
    }
  }

  /// Shows a notification immediately (used for test/preview).
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String channelId = 'activity_reminders',
    String channelName = 'Activity Reminders',
  }) async {
    await _ensureInitialized();
    try {
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[LocalNotification] showImmediate error: $e');
    }
  }

  /// Cancel a specific notification.
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }
}
