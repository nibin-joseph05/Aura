import 'package:hive_flutter/hive_flutter.dart';
import 'user_model.dart';
import '../../../daily_activity/data/models/daily_activity_model.dart';

void registerHiveAdapters() {
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(DailyActivityModelAdapter());
}
