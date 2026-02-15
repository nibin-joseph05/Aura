import 'package:hive_flutter/hive_flutter.dart';
import 'user_model.dart';
import '../../../daily_activity/data/models/daily_activity_model.dart';
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
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(DailyActivityModelAdapter());
  Hive.registerAdapter(TrustedContactAdapter());
  Hive.registerAdapter(SOSSettingsAdapter());
  Hive.registerAdapter(SOSEventStatusAdapter());
  Hive.registerAdapter(SOSEventAdapter());
  Hive.registerAdapter(WellnessCategoryAdapter());
  Hive.registerAdapter(WellnessUpdateAdapter());
  Hive.registerAdapter(PendingWellnessOperationAdapter());
  Hive.registerAdapter(WalkingSessionModelAdapter());
  Hive.registerAdapter(RoutePointAdapter());
  Hive.registerAdapter(AlarmModelAdapter());
}
