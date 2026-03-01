import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../../app.dart';
import '../../widgets/notifications/in_app_notification_overlay.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class FcmHandler {
  FcmHandler._();
  static final FcmHandler instance = FcmHandler._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  void Function(String route, Map<String, dynamic>? arguments)? onNavigate;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'aura_high_importance',
    'Aura Notifications',
    description: 'Important notifications from Aura',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    if (await Permission.notification.status.isDenied) {
      await Permission.notification.request();
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleMessageOpen(initial);
    }

    final token = await _messaging.getToken();
    debugPrint('[FCM] Token: $token');
  }

  Future<String?> getToken() => _messaging.getToken();

  void _handleForegroundMessage(RemoteMessage message) {
    String? title =
        message.notification?.title ?? message.data['title'] as String?;
    String? body =
        message.notification?.body ?? message.data['body'] as String?;

    if (title == null && body == null) return;

    debugPrint('[FCM] Foreground message: $title');

    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState != null) {
      InAppNotificationOverlay.show(
        null,
        overlayState: overlayState,
        title: title ?? 'Aura',
        body: body ?? '',
        onTap: () {
          _handleMessageOpen(message);
        },
      );
    }

    _localNotifications.show(
      id: message.hashCode,
      title: title ?? 'Aura',
      body: body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: json.encode(message.data),
    );
  }

  void _handleMessageOpen(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route != null && onNavigate != null) {
      final argsString = message.data['arguments'] as String?;
      Map<String, dynamic>? arguments;
      if (argsString != null) {
        try {
          arguments = json.decode(argsString) as Map<String, dynamic>;
        } catch (_) {}
      }
      onNavigate!(route, arguments);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = json.decode(response.payload!) as Map<String, dynamic>;
      final route = data['route'] as String?;
      if (route != null && onNavigate != null) {
        final argsString = data['arguments'] as String?;
        Map<String, dynamic>? arguments;
        if (argsString != null) {
          try {
            arguments = json.decode(argsString) as Map<String, dynamic>;
          } catch (_) {}
        }
        onNavigate!(route, arguments);
      }
    } catch (_) {}
  }
}
