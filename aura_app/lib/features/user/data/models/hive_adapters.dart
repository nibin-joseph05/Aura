import 'package:hive_flutter/hive_flutter.dart';
import 'user_model.dart';
import '../../../daily_activity/data/models/user_activity_model.dart';
import '../../../daily_activity/data/models/activity_log_model.dart';
import '../../../sos/data/models/trusted_contact.dart';
import '../../../sos/data/models/sos_settings.dart';
import '../../../sos/data/models/sos_event_status.dart';
import '../../../sos/data/models/sos_event.dart';
import '../../../wellness/data/models/wellness_category.dart';
import '../../../wellness/data/models/wellness_update.dart';
import '../../../wellness/data/models/pending_wellness_operation.dart';
import '../../../walking/data/model/walking_session_model.dart';
import '../../../alarm/data/model/alarm_model.dart';

void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(UserActivityModelAdapter().typeId)) {
    Hive.registerAdapter(UserActivityModelAdapter());
  }
  if (!Hive.isAdapterRegistered(ActivityLogModelAdapter().typeId)) {
    Hive.registerAdapter(ActivityLogModelAdapter());
  }
  if (!Hive.isAdapterRegistered(TrustedContactAdapter().typeId)) {
    Hive.registerAdapter(TrustedContactAdapter());
  }
  if (!Hive.isAdapterRegistered(SOSSettingsAdapter().typeId)) {
    Hive.registerAdapter(SOSSettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(SOSEventStatusAdapter().typeId)) {
    Hive.registerAdapter(SOSEventStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(SOSEventAdapter().typeId)) {
    Hive.registerAdapter(SOSEventAdapter());
  }
  if (!Hive.isAdapterRegistered(WellnessCategoryAdapter().typeId)) {
    Hive.registerAdapter(WellnessCategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(WellnessUpdateAdapter().typeId)) {
    Hive.registerAdapter(WellnessUpdateAdapter());
  }
  if (!Hive.isAdapterRegistered(PendingWellnessOperationAdapter().typeId)) {
    Hive.registerAdapter(PendingWellnessOperationAdapter());
  }
  if (!Hive.isAdapterRegistered(WalkingSessionModelAdapter().typeId)) {
    Hive.registerAdapter(WalkingSessionModelAdapter());
  }
  if (!Hive.isAdapterRegistered(RoutePointAdapter().typeId)) {
    Hive.registerAdapter(RoutePointAdapter());
  }
  if (!Hive.isAdapterRegistered(AlarmModelAdapter().typeId)) {
    Hive.registerAdapter(AlarmModelAdapter());
  }
}
