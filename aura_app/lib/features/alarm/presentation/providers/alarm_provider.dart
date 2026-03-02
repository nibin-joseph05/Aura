import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_notification_service.dart';
import '../../data/model/alarm_model.dart';
import '../../data/repository/alarm_repository.dart';
import '../../data/service/alarm_native_service.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository();
});

final alarmProvider = StateNotifierProvider<AlarmNotifier, AlarmState>((ref) {
  return AlarmNotifier(ref.read(alarmRepositoryProvider));
});

class AlarmState {
  final List<AlarmModel> alarms;
  final bool isLoading;
  final String? error;
  final bool hasPermission;

  AlarmState({
    this.alarms = const [],
    this.isLoading = false,
    this.error,
    this.hasPermission = false,
  });

  AlarmState copyWith({
    List<AlarmModel>? alarms,
    bool? isLoading,
    String? error,
    bool? hasPermission,
  }) {
    return AlarmState(
      alarms: alarms ?? this.alarms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

class AlarmNotifier extends StateNotifier<AlarmState> {
  final AlarmRepository _repository;

  AlarmNotifier(this._repository) : super(AlarmState());

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.init();
      final hasPermission =
          await AlarmNativeService.checkExactAlarmPermission();
      state = state.copyWith(
        alarms: _repository.getAllAlarms(),
        isLoading: false,
        hasPermission: hasPermission,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAlarms() async {
    state = state.copyWith(alarms: _repository.getAllAlarms());
  }

  Future<bool> createAlarm({
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
    try {
      final alarm = await _repository.createAlarm(
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

      await _scheduleNativeAlarm(alarm);
      state = state.copyWith(alarms: _repository.getAllAlarms());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateAlarm(AlarmModel alarm) async {
    try {
      await _repository.updateAlarm(alarm);
      if (alarm.isEnabled) {
        await _scheduleNativeAlarm(alarm);
      } else {
        await AlarmNativeService.cancelAlarm(alarm.id);
        await LocalNotificationService.instance.cancel(alarm.id.hashCode);
      }
      state = state.copyWith(alarms: _repository.getAllAlarms());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> toggleAlarm(String id, bool enabled) async {
    await _repository.toggleAlarm(id, enabled);
    final alarm = _repository.getAlarm(id);
    if (alarm != null) {
      if (enabled) {
        await _scheduleNativeAlarm(alarm);
      } else {
        await AlarmNativeService.cancelAlarm(id);
        await LocalNotificationService.instance.cancel(id.hashCode);
      }
    }
    state = state.copyWith(alarms: _repository.getAllAlarms());
  }

  Future<void> deleteAlarm(String id) async {
    await AlarmNativeService.cancelAlarm(id);
    await LocalNotificationService.instance.cancel(id.hashCode);
    await _repository.deleteAlarm(id);
    state = state.copyWith(alarms: _repository.getAllAlarms());
  }

  Future<void> snoozeAlarm(String id) async {
    final alarm = _repository.getAlarm(id);
    if (alarm != null) {
      await _repository.snoozeAlarm(id);
      await AlarmNativeService.snoozeAlarm(id, alarm.snoozeMinutes);
    }
  }

  Future<void> dismissAlarm(String id) async {
    await AlarmNativeService.stopAlarmSound();
    final alarm = _repository.getAlarm(id);
    if (alarm != null && alarm.isOneTime) {
      await toggleAlarm(id, false);
    } else if (alarm != null) {
      alarm.nextTriggerTime = alarm.calculateNextTrigger();
      await _repository.updateAlarm(alarm);
      await _scheduleNativeAlarm(alarm);
    }
    state = state.copyWith(alarms: _repository.getAllAlarms());
  }

  Future<void> requestPermission() async {
    await AlarmNativeService.requestExactAlarmPermission();
    final hasPermission = await AlarmNativeService.checkExactAlarmPermission();
    state = state.copyWith(hasPermission: hasPermission);
  }

  Future<void> _scheduleNativeAlarm(AlarmModel alarm) async {
    if (alarm.nextTriggerTime == null) return;

    await AlarmNativeService.scheduleAlarm(
      alarmId: alarm.id,
      triggerTime: alarm.nextTriggerTime!,
      label: alarm.label,
      tone: alarm.tone,
      vibrate: alarm.vibrate,
      dismissType: alarm.dismissType,
      mathDifficulty: alarm.mathDifficulty,
      snoozeMinutes: alarm.snoozeMinutes,
      hour: alarm.hour,
      minute: alarm.minute,
      repeatDays: alarm.repeatDays,
    );

    final preAlarmTime = alarm.nextTriggerTime!.subtract(
      const Duration(minutes: 10),
    );

    await LocalNotificationService.instance.cancel(alarm.id.hashCode);

    if (preAlarmTime.isAfter(DateTime.now())) {
      await LocalNotificationService.instance.schedule(
        id: alarm.id.hashCode,
        title: 'Upcoming Alarm',
        body:
            'Your alarm ${alarm.label.isNotEmpty ? "'${alarm.label}' " : ''}will ring in 10 minutes. Tap to turn it off early.',
        scheduledTime: preAlarmTime,
      );
    }
  }
}
