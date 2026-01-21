import 'package:dio/dio.dart';
import '../../../core/network/connectivity/connectivity_service.dart';
import 'user_activity_local_datasource.dart';
import 'user_activity_remote_datasource.dart';
import 'models/user_activity.dart';
import 'models/activity_log.dart';

class UserActivityRepository {
  final UserActivityRemoteDataSource _remoteDataSource;
  final UserActivityLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;

  UserActivityRepository({
    UserActivityRemoteDataSource? remoteDataSource,
    UserActivityLocalDataSource? localDataSource,
    ConnectivityService? connectivityService,
  }) : _remoteDataSource = remoteDataSource ?? UserActivityRemoteDataSource(),
       _localDataSource = localDataSource ?? UserActivityLocalDataSource(),
       _connectivityService = connectivityService ?? ConnectivityService();

  Future<List<UserActivity>> getUserActivities(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || await _connectivityService.hasConnection()) {
      try {
        final activities = await _remoteDataSource.getUserActivities(userId);
        await _localDataSource.saveActivities(activities);
        return activities;
      } on DioException {
        return await _localDataSource.getActivities(userId);
      }
    }
    return await _localDataSource.getActivities(userId);
  }

  Future<List<UserActivity>> getActivitiesForDate(
    String userId,
    DateTime date,
  ) async {
    if (await _connectivityService.hasConnection()) {
      try {
        final activities = await _remoteDataSource.getActivitiesForDate(
          userId,
          date,
        );
        await _localDataSource.saveActivities(activities);
        return activities;
      } on DioException {
        return await _localDataSource.getActivitiesForDate(userId, date);
      }
    }
    return await _localDataSource.getActivitiesForDate(userId, date);
  }

  Future<UserActivity> createActivity(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final activity = await _remoteDataSource.createActivity(userId, data);
    await _localDataSource.saveActivity(activity);
    return activity;
  }

  Future<UserActivity> updateActivity(
    String activityId,
    Map<String, dynamic> data,
  ) async {
    final activity = await _remoteDataSource.updateActivity(activityId, data);
    await _localDataSource.saveActivity(activity);
    return activity;
  }

  Future<void> deleteActivity(String activityId) async {
    await _remoteDataSource.deleteActivity(activityId);
    await _localDataSource.deleteActivity(activityId);
  }

  Future<List<ActivityLog>> getLogsForDate(
    String userId,
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || await _connectivityService.hasConnection()) {
      try {
        final logs = await _remoteDataSource.getLogsForDate(userId, date);
        await _localDataSource.saveLogs(logs);
        return logs;
      } on DioException {
        return await _localDataSource.getLogsForDate(userId, date);
      }
    }
    return await _localDataSource.getLogsForDate(userId, date);
  }

  Future<ActivityLog> createLog(Map<String, dynamic> data) async {
    final log = await _remoteDataSource.createLog(data);
    await _localDataSource.saveLog(log);
    return log;
  }

  Future<ActivityLog> markLogCompleted(String logId) async {
    final log = await _remoteDataSource.markLogCompleted(logId);
    await _localDataSource.saveLog(log);
    return log;
  }

  Future<ActivityLog> markLogSkipped(String logId) async {
    final log = await _remoteDataSource.markLogSkipped(logId);
    await _localDataSource.saveLog(log);
    return log;
  }
}
