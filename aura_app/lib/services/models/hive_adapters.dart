import 'package:hive_flutter/hive_flutter.dart';
import 'user_model.dart';

void registerHiveAdapters() {
  Hive.registerAdapter(UserModelAdapter());
}
