import '../../../core/network/http/dio_client.dart';
import '../../../core/network/http/api_endpoints.dart';
import 'models/wellness_update.dart';
import 'models/wellness_category.dart';

class WellnessRemoteDataSource {
  final DioClient _client = DioClient();

  Future<List<WellnessUpdate>> getFeed({
    int page = 0,
    int size = 20,
    WellnessCategory? category,
  }) async {
    String url = '${ApiEndpoints.wellnessFeed}?page=$page&size=$size';
    if (category != null) {
      url += '&category=${category.name.toUpperCase()}';
    }

    final response = await _client.dio.get(url);
    if (response.data['success'] == true) {
      final content = response.data['data']['content'] as List<dynamic>;
      return content.map((json) => WellnessUpdate.fromJson(json)).toList();
    }
    throw Exception(response.data['error'] ?? 'Failed to fetch feed');
  }

  Future<List<WellnessUpdate>> getMyUpdates({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.dio.get(
      '${ApiEndpoints.wellnessMyUpdates}?page=$page&size=$size',
    );
    if (response.data['success'] == true) {
      final content = response.data['data']['content'] as List<dynamic>;
      return content.map((json) => WellnessUpdate.fromJson(json)).toList();
    }
    throw Exception(response.data['error'] ?? 'Failed to fetch updates');
  }

  Future<List<WellnessUpdate>> getTrending() async {
    final response = await _client.dio.get(ApiEndpoints.wellnessTrending);
    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => WellnessUpdate.fromJson(json)).toList();
    }
    throw Exception(response.data['error'] ?? 'Failed to fetch trending');
  }

  Future<WellnessUpdate> createUpdate({
    required String content,
    required WellnessCategory category,
    String? imageUrl,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.wellnessUpdates,
      data: {
        'content': content,
        'category': category.name.toUpperCase(),
        'imageUrl': imageUrl,
      },
    );
    if (response.data['success'] == true) {
      return WellnessUpdate.fromJson(response.data['data']);
    }
    throw Exception(response.data['error'] ?? 'Failed to create update');
  }

  Future<void> deleteUpdate(String id) async {
    final response = await _client.dio.delete(
      '${ApiEndpoints.wellnessUpdates}/$id',
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Failed to delete update');
    }
  }

  Future<WellnessUpdate> likeUpdate(String id) async {
    final response = await _client.dio.post(
      '${ApiEndpoints.wellnessUpdates}/$id/like',
    );
    if (response.data['success'] == true) {
      return WellnessUpdate.fromJson(response.data['data']);
    }
    throw Exception(response.data['error'] ?? 'Failed to like update');
  }

  Future<WellnessUpdate> unlikeUpdate(String id) async {
    final response = await _client.dio.delete(
      '${ApiEndpoints.wellnessUpdates}/$id/like',
    );
    if (response.data['success'] == true) {
      return WellnessUpdate.fromJson(response.data['data']);
    }
    throw Exception(response.data['error'] ?? 'Failed to unlike update');
  }
}
