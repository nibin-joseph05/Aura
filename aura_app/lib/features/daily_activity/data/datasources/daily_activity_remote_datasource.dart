import 'package:dio/dio.dart';

import '../../../../core/network/http/api_endpoints.dart';
import '../../../../core/network/http/dio_client.dart';
import '../models/user_activity_model.dart';

class DailyActivityRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<UserActivityModel>> fetchActivities({DateTime? date}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.dailyActivities,
        queryParameters: date != null ? {'date': date.toIso8601String()} : null,
      );

      final List<dynamic> data = response.data['activities'] ?? [];
      return data.map((json) => UserActivityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch activities: ${e.toString()}');
    }
  }

  Future<UserActivityModel> createActivity(UserActivityModel activity) async {
    try {
      final payload = activity.toJson();
      if (activity.metricLogs.isNotEmpty) {
        payload['metrics'] = activity.metricLogs.entries
            .map((e) => {'activityMetricId': e.key, 'value': e.value})
            .toList();
      }

      final response = await _dio.post(
        ApiEndpoints.dailyActivities,
        data: payload,
      );
      return UserActivityModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create activity: ${e.toString()}');
    }
  }

  Future<void> syncActivities(List<UserActivityModel> activities) async {
    try {
      final payloads = activities.map((a) {
        final j = a.toJson();
        if (a.metricLogs.isNotEmpty) {
          j['metrics'] = a.metricLogs.entries
              .map((e) => {'activityMetricId': e.key, 'value': e.value})
              .toList();
        }
        return j;
      }).toList();

      await _dio.post(
        ApiEndpoints.syncDailyActivities,
        data: {'activities': payloads},
      );
    } catch (e) {
      throw Exception('Failed to sync activities: ${e.toString()}');
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.dailyActivities}/$id');
    } catch (e) {
      throw Exception('Failed to delete activity: ${e.toString()}');
    }
  }

  Future<UserActivityModel> updateActivity(UserActivityModel activity) async {
    try {
      final payload = activity.toJson();
      if (activity.metricLogs.isNotEmpty) {
        payload['metrics'] = activity.metricLogs.entries
            .map((e) => {'activityMetricId': e.key, 'value': e.value})
            .toList();
      }

      final response = await _dio.put(
        '${ApiEndpoints.dailyActivities}/${activity.id}',
        data: payload,
      );
      return UserActivityModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update activity: ${e.toString()}');
    }
  }
}
