import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../model/alarm_model.dart';

class AlarmRepository {
  static const String _boxName = 'alarms';
  Box<AlarmModel>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(30)) {
      Hive.registerAdapter(AlarmModelAdapter());
    }
    _box = await Hive.openBox<AlarmModel>(_boxName);
  }

  Box<AlarmModel> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Alarm box not initialized');
    }
    return _box!;
  }

  Future<AlarmModel> createAlarm({
    required int hour,
    required int minute,
    String label = '',
    List<int> repeatDays = const [],
    String tone = 'default',
    String dismissType = 'button',
    int mathDifficulty = 1,
    bool vibrate = true,
    int snoozeMinutes = 5,
  }) async {
    final alarm = AlarmModel(
      id: const Uuid().v4(),
      hour: hour,
      minute: minute,
      label: label,
      repeatDays: repeatDays,
      tone: tone,
      dismissType: dismissType,
      mathDifficulty: mathDifficulty,
      vibrate: vibrate,
      snoozeMinutes: snoozeMinutes,
    );

    alarm.nextTriggerTime = alarm.calculateNextTrigger();
    await box.put(alarm.id, alarm);
    return alarm;
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    alarm.nextTriggerTime = alarm.calculateNextTrigger();
    await alarm.save();
  }

  Future<void> deleteAlarm(String id) async {
    await box.delete(id);
  }

  Future<void> toggleAlarm(String id, bool enabled) async {
    final alarm = box.get(id);
    if (alarm != null) {
      alarm.isEnabled = enabled;
      if (enabled) {
        alarm.nextTriggerTime = alarm.calculateNextTrigger();
      }
      await alarm.save();
    }
  }

  List<AlarmModel> getAllAlarms() {
    final alarms = box.values.toList();
    alarms.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return alarms;
  }

  List<AlarmModel> getEnabledAlarms() {
    return getAllAlarms().where((a) => a.isEnabled).toList();
  }

  AlarmModel? getAlarm(String id) {
    return box.get(id);
  }

  Future<void> snoozeAlarm(String id) async {
    final alarm = box.get(id);
    if (alarm != null) {
      final now = DateTime.now();
      alarm.nextTriggerTime = now.add(Duration(minutes: alarm.snoozeMinutes));
      await alarm.save();
    }
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}
