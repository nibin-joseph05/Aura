import 'package:dio/dio.dart';
import '../../../core/network/http/api_endpoints.dart';
import '../../../core/network/http/dio_client.dart';
import 'models/activity_category.dart';
import 'models/activity_type.dart';

class ActivityTypeRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<ActivityCategory>> getActiveCategories() async {
    final response = await _dio.get(ApiEndpoints.activityCategoriesActive);
    final List data = response.data as List;
    return data.map((json) => ActivityCategory.fromJson(json)).toList();
  }

  Future<List<ActivityType>> getActiveTypes() async {
    final response = await _dio.get(ApiEndpoints.activityTypesActive);
    final List data = response.data as List;
    return data.map((json) => ActivityType.fromJson(json)).toList();
  }

  Future<List<ActivityType>> getTypesByCategory(String categoryId) async {
    final response = await _dio.get(
      ApiEndpoints.activityTypesByCategory(categoryId),
    );
    final List data = response.data as List;
    return data.map((json) => ActivityType.fromJson(json)).toList();
  }
}
