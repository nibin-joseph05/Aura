import 'package:hive_flutter/hive_flutter.dart';

import '../models/daily_activity_model.dart';

class DailyActivityLocalDataSource {
  static const String _boxName = 'daily_activities';

  Future<Box<DailyActivityModel>> _openBox() async {
    return Hive.openBox<DailyActivityModel>(_boxName);
  }

  Future<void> save(DailyActivityModel activity) async {
    final box = await _openBox();
    await box.put(activity.id, activity);
  }

  Future<void> saveAll(List<DailyActivityModel> activities) async {
    final box = await _openBox();
    final Map<String, DailyActivityModel> entries = {
      for (var a in activities) a.id: a,
    };
    await box.putAll(entries);
  }

  Future<List<DailyActivityModel>> getAll() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<List<DailyActivityModel>> getByDate(DateTime date) async {
    final box = await _openBox();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return box.values.where((activity) {
      return activity.date.isAfter(
            startOfDay.subtract(const Duration(seconds: 1)),
          ) &&
          activity.date.isBefore(endOfDay);
    }).toList();
  }

  Future<List<DailyActivityModel>> getPendingSync() async {
    final box = await _openBox();
    return box.values.where((activity) => !activity.isSynced).toList();
  }

  Future<void> markAsSynced(String id) async {
    final box = await _openBox();
    final activity = box.get(id);
    if (activity != null) {
      await box.put(id, activity.copyWith(isSynced: true));
    }
  }

  Future<void> delete(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
