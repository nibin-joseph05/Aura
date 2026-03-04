import 'package:dio/dio.dart';

import '../../../../core/network/http/api_endpoints.dart';
import '../../../../core/network/http/dio_client.dart';
import '../models/user_activity_model.dart';
import '../models/activity_log_model.dart';

class DailyActivityRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<UserActivityModel>> fetchActivities(
    String userId, {
    DateTime? date,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.userActivitiesForUser(userId),
        queryParameters: date != null ? {'date': date.toIso8601String()} : null,
      );

      final raw = response.data;
      final List<dynamic> data;
      if (raw is List) {
        data = raw;
      } else if (raw is Map<String, dynamic>) {
        final inner = raw['data'] ?? raw['content'] ?? raw;
        data = inner is List ? inner : [];
      } else {
        data = [];
      }
      return data.map((json) => _mapResponseToModel(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch activities: ${e.toString()}');
    }
  }

  Future<UserActivityModel> createActivity(
    String userId,
    UserActivityModel activity,
  ) async {
    try {
      final payload = {
        'activityTypeId': activity.activityTypeId,
        'customTitle': activity.title,
        'intervalMinutes': activity.intervalMinutes,
        'targetCompletions': activity.targetCompletions,
        'isAlarmEnabled': activity.isAlarmEnabled,
        'isPushEnabled': activity.isPushEnabled,
        'startDate':
            "${activity.createdAt.year}-${activity.createdAt.month.toString().padLeft(2, '0')}-${activity.createdAt.day.toString().padLeft(2, '0')}",
        'repeatType': 'DAILY',
        'isActive': true,
      };

      final response = await _dio.post(
        ApiEndpoints.userActivitiesForUser(userId),
        data: payload,
      );

      final mapped = _mapResponseToModel(response.data);
      return activity.copyWith(id: mapped.id, isSynced: true);
    } catch (e) {
      throw Exception('Failed to create activity: ${e.toString()}');
    }
  }

  Future<void> syncActivities(
    String userId,
    List<UserActivityModel> activities,
  ) async {
    try {
      final payloads = activities.map((activity) {
        return {
          'id': activity.id,
          'activityTypeId': activity.activityTypeId,
          'customTitle': activity.title,
          'intervalMinutes': activity.intervalMinutes,
          'targetCompletions': activity.targetCompletions,
          'isAlarmEnabled': activity.isAlarmEnabled,
          'isPushEnabled': activity.isPushEnabled,
          'startDate':
              "${activity.createdAt.year}-${activity.createdAt.month.toString().padLeft(2, '0')}-${activity.createdAt.day.toString().padLeft(2, '0')}",
          'repeatType': 'DAILY',
          'isActive': true,
        };
      }).toList();

      await _dio.post(
        ApiEndpoints.syncDailyActivities(userId),
        data: {'activities': payloads},
      );
    } catch (e) {
      throw Exception('Failed to sync activities: ${e.toString()}');
    }
  }

  Future<void> deleteActivity(String userId, String id) async {
    try {
      await _dio.delete('${ApiEndpoints.userActivities}/$id');
    } catch (e) {
      throw Exception('Failed to delete activity: ${e.toString()}');
    }
  }

  Future<UserActivityModel> updateActivity(
    String userId,
    UserActivityModel activity,
  ) async {
    try {
      final payload = {
        'customTitle': activity.title,
        'intervalMinutes': activity.intervalMinutes,
        'targetCompletions': activity.targetCompletions,
        'isAlarmEnabled': activity.isAlarmEnabled,
        'isPushEnabled': activity.isPushEnabled,
      };

      final response = await _dio.put(
        '${ApiEndpoints.userActivities}/${activity.id}',
        data: payload,
      );

      final mapped = _mapResponseToModel(response.data);
      return activity.copyWith(id: mapped.id, isSynced: true);
    } catch (e) {
      throw Exception('Failed to update activity: ${e.toString()}');
    }
  }

  Future<ActivityLogModel> createLog(
    String userId,
    ActivityLogModel log,
  ) async {
    try {
      final payload = {
        'userActivityId': log.userActivityId,
        'completedAt': log.completedAt.toIso8601String(),
        'metrics': log.metrics,
      };

      final response = await _dio.post(
        ApiEndpoints.activityLogs,
        data: payload,
      );

      return log.copyWith(id: response.data['id'].toString(), isSynced: true);
    } catch (e) {
      throw Exception('Failed to create activity log: ${e.toString()}');
    }
  }

  UserActivityModel _mapResponseToModel(Map<String, dynamic> json) {
    DateTime activityDate = DateTime.now();
    if (json['startDate'] != null) {
      try {
        activityDate = DateTime.parse(json['startDate']);
      } catch (_) {
        if (json['createdAt'] != null) {
          activityDate = DateTime.parse(json['createdAt']);
        }
      }
    } else if (json['createdAt'] != null) {
      activityDate = DateTime.parse(json['createdAt']);
    }

    return UserActivityModel(
      id: json['id'].toString(),
      date: activityDate,
      activityType: json['activityTypeName'] ?? '',
      title: json['customTitle'] ?? json['activityTypeName'] ?? '',
      description: '',
      completedAt: null,
      isSynced: true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      intervalMinutes: json['intervalMinutes'],
      targetCompletions: json['targetCompletions'] ?? 1,
      completionTimes: [],
      isAlarmEnabled: json['isAlarmEnabled'] ?? false,
      isPushEnabled: json['isPushEnabled'] ?? false,
      categoryName: json['categoryName'] ?? '',
      activityTypeIcon: json['activityTypeIcon'] ?? '',
      isGymActivity: json['isGymActivity'] ?? false,
      activityTypeId: json['activityTypeId'] ?? '',
      metrics: [],
      metricLogs: {},
    );
  }
}
