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
    } catch (e) {
    }
  }

  static Future<List<String>> getAvailableTones() async {
    try {
      final result = await _channel.invokeMethod<List>('getAvailableTones');
      return result?.cast<String>() ?? ['default'];
    } catch (e) {
      return ['default'];
    }
  }

  static Future<void> stopAlarmSound() async {
    try {
      await _channel.invokeMethod('stopAlarmSound');
    } catch (e) {
    }
  }

  static Future<void> snoozeAlarm(String alarmId, int snoozeMinutes) async {
    try {
      await _channel.invokeMethod('snoozeAlarm', {
        'alarmId': alarmId,
        'snoozeMinutes': snoozeMinutes,
      });
    } catch (e) {
      
    }
  }
}
