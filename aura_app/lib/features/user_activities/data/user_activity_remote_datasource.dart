import 'package:dio/dio.dart';
import '../../../core/network/http/api_endpoints.dart';
import '../../../core/network/http/dio_client.dart';
import 'models/user_activity.dart';
import 'models/activity_log.dart';

class UserActivityRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<UserActivity>> getUserActivities(String userId) async {
    final response = await _dio.get(ApiEndpoints.userActivitiesForUser(userId));
    final List data = response.data as List;
    return data.map((json) => UserActivity.fromJson(json)).toList();
  }

  Future<List<UserActivity>> getActivitiesForDate(
    String userId,
    DateTime date,
  ) async {
    final dateStr = date.toIso8601String().split('T').first;
    final response = await _dio.get(
      ApiEndpoints.userActivitiesForDate(userId, dateStr),
    );
    final List data = response.data as List;
    return data.map((json) => UserActivity.fromJson(json)).toList();
  }

  Future<UserActivity> createActivity(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.userActivitiesForUser(userId),
      data: data,
    );
    return UserActivity.fromJson(response.data);
  }

  Future<UserActivity> updateActivity(
    String activityId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      '${ApiEndpoints.userActivities}/$activityId',
      data: data,
    );
    return UserActivity.fromJson(response.data);
  }

  Future<void> deleteActivity(String activityId) async {
    await _dio.delete('${ApiEndpoints.userActivities}/$activityId');
  }

  Future<List<ActivityLog>> getLogsForDate(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    final response = await _dio.get(
      ApiEndpoints.activityLogsForDate(userId, dateStr),
    );
    final List data = response.data as List;
    return data.map((json) => ActivityLog.fromJson(json)).toList();
  }

  Future<ActivityLog> createLog(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.activityLogs, data: data);
    return ActivityLog.fromJson(response.data);
  }

  Future<ActivityLog> markLogCompleted(String logId) async {
    final response = await _dio.patch(
      '${ApiEndpoints.activityLogs}/$logId/complete',
    );
    return ActivityLog.fromJson(response.data);
  }

  Future<ActivityLog> markLogSkipped(String logId) async {
    final response = await _dio.patch(
      '${ApiEndpoints.activityLogs}/$logId/skip',
    );
    return ActivityLog.fromJson(response.data);
  }
}
