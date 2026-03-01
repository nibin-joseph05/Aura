import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_activityChannel);

    _initialized = true;
  }

  Future<void> showActivityReminder({
    required int id,
    required String activityName,
    String? description,
  }) async {
    await _ensureInitialized();
    try {
      await _plugin.show(
        id: id,
        title: '⏰ Activity Reminder',
        body: description?.isNotEmpty == true
            ? '$activityName — $description'
            : 'Time for: $activityName',
        notificationDetails: NotificationDetails(
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
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
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

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String channelId = 'alarm_reminders',
    String channelName = 'Alarm Reminders',
  }) async {
    await _ensureInitialized();
    try {
      final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
      if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzTime,
        notificationDetails: NotificationDetails(
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('[LocalNotification] schedule error: $e');
    }
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }
}
