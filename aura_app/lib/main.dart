import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'features/user/data/models/hive_adapters.dart';
import 'core/network/sync/sync_manager.dart';
import 'core/network/push/fcm_handler.dart';
import 'core/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // Initialize push notification handlers
  await FcmHandler.instance.initialize();
  await LocalNotificationService.instance.initialize();

  await Hive.initFlutter();
  registerHiveAdapters();

  await SyncManager().initialize();

  runApp(const ProviderScope(child: AuraApp()));
}
