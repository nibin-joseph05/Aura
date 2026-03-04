import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_activity_model.dart';
import '../models/activity_log_model.dart';

class DailyActivityLocalDataSource {
  static const String _boxName = 'user_activities';
  static const String _logBoxName = 'user_activity_logs';

  Future<Box<UserActivityModel>> _openBox() async {
    return Hive.openBox<UserActivityModel>(_boxName);
  }

  Future<Box<ActivityLogModel>> _openLogBox() async {
    return Hive.openBox<ActivityLogModel>(_logBoxName);
  }

  Future<void> save(UserActivityModel activity) async {
    try {
      final box = await _openBox();
      await box.put(activity.id, activity);
    } catch (_) {}
  }

  Future<void> saveAll(List<UserActivityModel> activities) async {
    try {
      final box = await _openBox();
      final Map<String, UserActivityModel> entries = {
        for (var a in activities) a.id: a,
      };
      await box.putAll(entries);
    } catch (_) {}
  }

  Future<List<UserActivityModel>> getAll() async {
    try {
      final box = await _openBox();
      return box.values.toList();
    } catch (_) {
      try {
        await Hive.deleteBoxFromDisk(_boxName);
      } catch (_) {}
      return [];
    }
  }

  Future<List<UserActivityModel>> getByDate(DateTime date) async {
    try {
      final box = await _openBox();
      final today = DateTime(date.year, date.month, date.day);
      return box.values.where((activity) {
        final activityDate = DateTime(
          activity.date.year,
          activity.date.month,
          activity.date.day,
        );
        final isSameDay = activityDate == today;
        final isRecurring =
            activity.intervalMinutes != null || activity.targetCompletions > 1;
        final startedOnOrBefore = !activityDate.isAfter(today);
        return isSameDay || (isRecurring && startedOnOrBefore);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<UserActivityModel>> getPendingSync() async {
    try {
      final box = await _openBox();
      return box.values.where((activity) => !activity.isSynced).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markAsSynced(String id) async {
    try {
      final box = await _openBox();
      final activity = box.get(id);
      if (activity != null) {
        await box.put(id, activity.copyWith(isSynced: true));
      }
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      final box = await _openBox();
      final logBox = await _openLogBox();
      await box.clear();
      await logBox.clear();
    } catch (_) {}
  }

  Future<void> saveLog(ActivityLogModel log) async {
    try {
      final box = await _openLogBox();
      await box.put(log.id, log);
    } catch (_) {}
  }

  Future<List<ActivityLogModel>> getLogsForActivity(String activityId) async {
    try {
      final box = await _openLogBox();
      return box.values.where((l) => l.userActivityId == activityId).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ActivityLogModel>> getPendingLogs() async {
    try {
      final box = await _openLogBox();
      return box.values.where((l) => !l.isSynced).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markLogAsSynced(String logId) async {
    try {
      final box = await _openLogBox();
      final log = box.get(logId);
      if (log != null) {
        await box.put(logId, log.copyWith(isSynced: true));
      }
    } catch (_) {}
  }

  Future<void> deleteLog(String logId) async {
    try {
      final box = await _openLogBox();
      await box.delete(logId);
    } catch (_) {}
  }
}
