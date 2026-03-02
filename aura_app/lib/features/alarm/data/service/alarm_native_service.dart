import 'package:flutter/services.dart';

class AlarmNativeService {
  static const MethodChannel _channel = MethodChannel('com.aura.alarm/native');

  static Future<bool> scheduleAlarm({
    required String alarmId,
    required DateTime triggerTime,
    required String label,
    required String tone,
    required bool vibrate,
    required String dismissType,
    required int mathDifficulty,
    int snoozeMinutes = 5,
    int hour = 0,
    int minute = 0,
    List<int> repeatDays = const [],
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('scheduleAlarm', {
        'alarmId': alarmId,
        'triggerTimeMillis': triggerTime.millisecondsSinceEpoch,
        'label': label,
        'tone': tone,
        'vibrate': vibrate,
        'dismissType': dismissType,
        'mathDifficulty': mathDifficulty,
        'snoozeMinutes': snoozeMinutes,
        'hour': hour,
        'minute': minute,
        'repeatDays': repeatDays,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelAlarm(String alarmId) async {
    try {
      final result = await _channel.invokeMethod<bool>('cancelAlarm', {
        'alarmId': alarmId,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelAllAlarms() async {
    try {
      final result = await _channel.invokeMethod<bool>('cancelAllAlarms');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkExactAlarmPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'checkExactAlarmPermission',
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> requestExactAlarmPermission() async {
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } catch (e) {}
  }

  static Future<List<Map<String, String>>> getAvailableTones() async {
    try {
      final result = await _channel.invokeMethod<List>('getAvailableTones');
      if (result == null)
        return [
          {'title': 'Default', 'uri': 'default'},
        ];

      return result.map((dynamic item) {
        final map = Map<String, dynamic>.from(item as Map);
        return {
          'title': map['title']?.toString() ?? 'Unknown',
          'uri': map['uri']?.toString() ?? 'default',
        };
      }).toList();
    } catch (e) {
      return [
        {'title': 'Default', 'uri': 'default'},
      ];
    }
  }

  static Future<void> stopAlarmSound() async {
    try {
      await _channel.invokeMethod('stopAlarmSound');
    } catch (e) {}
  }

  static Future<void> playAlarmSound(String tone) async {
    try {
      await _channel.invokeMethod('playAlarmSound', {'tone': tone});
    } catch (e) {}
  }

  static Future<String?> pickCustomRingtone() async {
    try {
      final result = await _channel.invokeMethod<String?>('pickCustomRingtone');
      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<void> snoozeAlarm(String alarmId, int snoozeMinutes) async {
    try {
      await _channel.invokeMethod('snoozeAlarm', {
        'alarmId': alarmId,
        'snoozeMinutes': snoozeMinutes,
      });
    } catch (e) {}
  }
}
