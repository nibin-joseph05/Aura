import 'package:dio/dio.dart';

import '../../../../core/network/http/api_endpoints.dart';
import '../../../../core/network/http/dio_client.dart';
import '../models/daily_activity_model.dart';

class DailyActivityRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<DailyActivityModel>> fetchActivities({DateTime? date}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.dailyActivities,
        queryParameters: date != null ? {'date': date.toIso8601String()} : null,
      );

      final List<dynamic> data = response.data['activities'] ?? [];
      return data.map((json) => DailyActivityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch activities: ${e.toString()}');
    }
  }

  Future<DailyActivityModel> createActivity(DailyActivityModel activity) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.dailyActivities,
        data: activity.toJson(),
      );
      return DailyActivityModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create activity: ${e.toString()}');
    }
  }

  Future<void> syncActivities(List<DailyActivityModel> activities) async {
    try {
      await _dio.post(
        ApiEndpoints.syncDailyActivities,
        data: {'activities': activities.map((a) => a.toJson()).toList()},
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

  Future<DailyActivityModel> updateActivity(DailyActivityModel activity) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.dailyActivities}/${activity.id}',
        data: activity.toJson(),
      );
      return DailyActivityModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update activity: ${e.toString()}');
    }
  }
}
