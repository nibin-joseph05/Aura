import 'package:hive_flutter/hive_flutter.dart';
import '../../features/activity_types/data/models/activity_category.dart';
import '../../features/activity_types/data/models/activity_type.dart';
import '../../features/user_activities/data/models/activity_log.dart';
import '../../features/user_activities/data/models/activity_status.dart';
import '../../features/user_activities/data/models/repeat_type.dart';
import '../../features/user_activities/data/models/user_activity.dart';

class HiveRegistrar {
  static Future<void> registerAdapters() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ActivityCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(ActivityTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(RepeatTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(UserActivityAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(ActivityStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(ActivityLogAdapter());
    }
  }
}
