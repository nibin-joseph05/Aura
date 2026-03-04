import 'package:hive/hive.dart';
import 'models/activity_category.dart';
import 'models/activity_type.dart';

class ActivityTypeLocalDataSource {
  static const String categoriesBoxName = 'activity_categories';
  static const String typesBoxName = 'activity_types';

  Future<Box<ActivityCategory>> get _categoriesBox async =>
      await Hive.openBox<ActivityCategory>(categoriesBoxName);

  Future<Box<ActivityType>> get _typesBox async =>
      await Hive.openBox<ActivityType>(typesBoxName);

  Future<List<ActivityCategory>> getCategories() async {
    try {
      final box = await _categoriesBox;
      return box.values.toList();
    } catch (_) {
      try {
        await Hive.deleteBoxFromDisk(categoriesBoxName);
      } catch (_) {}
      return [];
    }
  }

  Future<void> saveCategories(List<ActivityCategory> categories) async {
    try {
      final box = await _categoriesBox;
      await box.clear();
      for (var category in categories) {
        await box.put(category.id, category);
      }
    } catch (_) {}
  }

  Future<List<ActivityType>> getTypes() async {
    try {
      final box = await _typesBox;
      return box.values.toList();
    } catch (_) {
      try {
        await Hive.deleteBoxFromDisk(typesBoxName);
      } catch (_) {}
      return [];
    }
  }

  Future<List<ActivityType>> getTypesByCategory(String categoryId) async {
    try {
      final box = await _typesBox;
      return box.values.where((type) => type.categoryId == categoryId).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTypes(List<ActivityType> types) async {
    try {
      final box = await _typesBox;
      await box.clear();
      for (var type in types) {
        await box.put(type.id, type);
      }
    } catch (_) {}
  }

  Future<ActivityType?> getTypeById(String id) async {
    try {
      final box = await _typesBox;
      return box.get(id);
    } catch (_) {
      return null;
    }
  }
}
