import 'package:hive/hive.dart';
import 'models/user_activity.dart';
import 'models/activity_log.dart';

class UserActivityLocalDataSource {
  static const String activitiesBoxName = 'user_activities';
  static const String logsBoxName = 'activity_logs';

  Future<Box<UserActivity>> get _activitiesBox async =>
      await Hive.openBox<UserActivity>(activitiesBoxName);

  Future<Box<ActivityLog>> get _logsBox async =>
      await Hive.openBox<ActivityLog>(logsBoxName);

  Future<List<UserActivity>> getActivities(String userId) async {
    final box = await _activitiesBox;
    return box.values.where((a) => a.userId == userId && a.isActive).toList();
  }

  Future<List<UserActivity>> getActivitiesForDate(
    String userId,
    DateTime date,
  ) async {
    final box = await _activitiesBox;
    final dateOnly = DateTime(date.year, date.month, date.day);
    return box.values.where((a) {
      if (a.userId != userId || !a.isActive) return false;
      final startDate = DateTime(
        a.startDate.year,
        a.startDate.month,
        a.startDate.day,
      );
      final endDate = a.endDate != null
          ? DateTime(a.endDate!.year, a.endDate!.month, a.endDate!.day)
          : null;
      return startDate.isBefore(dateOnly.add(const Duration(days: 1))) &&
          (endDate == null ||
              endDate.isAfter(dateOnly.subtract(const Duration(days: 1))));
    }).toList();
  }

  Future<void> saveActivities(List<UserActivity> activities) async {
    final box = await _activitiesBox;
    for (var activity in activities) {
      await box.put(activity.id, activity);
    }
  }

  Future<void> saveActivity(UserActivity activity) async {
    final box = await _activitiesBox;
    await box.put(activity.id, activity);
  }

  Future<void> deleteActivity(String activityId) async {
    final box = await _activitiesBox;
    await box.delete(activityId);
  }

  Future<List<ActivityLog>> getLogsForDate(String userId, DateTime date) async {
    final box = await _logsBox;
    final dateOnly = DateTime(date.year, date.month, date.day);
    return box.values.where((log) {
      final logDate = DateTime(
        log.logDate.year,
        log.logDate.month,
        log.logDate.day,
      );
      return logDate == dateOnly;
    }).toList();
  }

  Future<void> saveLogs(List<ActivityLog> logs) async {
    final box = await _logsBox;
    for (var log in logs) {
      await box.put(log.id, log);
    }
  }

  Future<void> saveLog(ActivityLog log) async {
    final box = await _logsBox;
    await box.put(log.id, log);
  }
}
