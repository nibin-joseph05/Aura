import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/network/http/api_endpoints.dart';
import '../../../core/network/http/dio_client.dart';
import 'models/wellness_update.dart';
import 'models/wellness_comment.dart';
import 'models/wellness_category.dart';

class WellnessRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<WellnessUpdate>> getFeed({
    int page = 0,
    int size = 20,
    WellnessCategory? category,
  }) async {
    String url = '${ApiEndpoints.wellnessFeed}?page=$page&size=$size';
    if (category != null) {
      url += '&category=${category.name.toUpperCase()}';
    }
    final response = await _dio.get(url);
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
    final response = await _dio.get(
      '${ApiEndpoints.wellnessMyUpdates}?page=$page&size=$size',
    );
    if (response.data['success'] == true) {
      final content = response.data['data']['content'] as List<dynamic>;
      return content.map((json) => WellnessUpdate.fromJson(json)).toList();
    }
    throw Exception(response.data['error'] ?? 'Failed to fetch updates');
  }

  Future<List<WellnessUpdate>> getUserPosts(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '${ApiEndpoints.wellnessUpdates}/user-posts/$userId?page=$page&size=$size',
    );
    if (response.data['success'] == true) {
      final content = response.data['data']['content'] as List<dynamic>;
      return content.map((json) => WellnessUpdate.fromJson(json)).toList();
    }
    throw Exception(response.data['error'] ?? 'Failed to fetch user posts');
  }

  Future<List<WellnessUpdate>> getTrending() async {
    final response = await _dio.get(ApiEndpoints.wellnessTrending);
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
    final response = await _dio.post(
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
    throw Exception(response.data['error'] ?? 'Failed to create post');
  }

  Future<WellnessUpdate> editUpdate({
    required String id,
    required String content,
    required WellnessCategory category,
    String? imageUrl,
  }) async {
    final response = await _dio.put(
      '${ApiEndpoints.wellnessUpdates}/$id',
      data: {
        'content': content,
        'category': category.name.toUpperCase(),
        'imageUrl': imageUrl,
      },
    );
    if (response.data['success'] == true) {
      return WellnessUpdate.fromJson(response.data['data']);
    }
    throw Exception(response.data['error'] ?? 'Failed to update post');
  }

  Future<String> uploadImage(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(Platform.pathSeparator).last,
      ),
    });
    final response = await _dio.post(
      ApiEndpoints.wellnessImageUpload,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.data['success'] == true) {
      return response.data['url'] as String;
    }
    throw Exception(response.data['error'] ?? 'Failed to upload image');
  }

  Future<void> deleteUpdate(String id) async {
    final response = await _dio.delete('${ApiEndpoints.wellnessUpdates}/$id');
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Failed to delete post');
    }
  }

  Future<WellnessUpdate> likeUpdate(String id) async {
    final response = await _dio.post(
      '${ApiEndpoints.wellnessUpdates}/$id/like',
    );
    if (response.data['success'] == true) {
      return WellnessUpdate.fromJson(response.data['data']);
    }
    throw Exception(response.data['error'] ?? 'Failed to like post');
  }

  Future<WellnessUpdate> unlikeUpdate(String id) async {
    final response = await _dio.delete(
      '${ApiEndpoints.wellnessUpdates}/$id/like',
    );
    if (response.data['success'] == true) {
      return WellnessUpdate.fromJson(response.data['data']);
    }
    throw Exception(response.data['error'] ?? 'Failed to unlike post');
  }

  Future<List<WellnessComment>> getComments(String postId) async {
    final response = await _dio.get(
      '${ApiEndpoints.wellnessBase}/$postId/comments',
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => WellnessComment.fromJson(json)).toList();
    }
    throw Exception(response.data['error'] ?? 'Failed to load comments');
  }

  Future<WellnessComment> createComment(String postId, String content) async {
    final response = await _dio.post(
      '${ApiEndpoints.wellnessBase}/$postId/comments',
      data: {'content': content},
    );
    if (response.data['success'] == true) {
      return WellnessComment.fromJson(response.data['data']);
    }
    throw Exception(response.data['error'] ?? 'Failed to add comment');
  }

  Future<void> deleteComment(String commentId) async {
    final response = await _dio.delete(
      '${ApiEndpoints.wellnessComments}/$commentId',
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Failed to delete comment');
    }
  }

  Future<WellnessUpdate> getUpdateById(String id) async {
    final response = await _dio.get('${ApiEndpoints.wellnessUpdates}/$id');
    if (response.data['success'] == true) {
      return WellnessUpdate.fromJson(response.data['data']);
    }
    throw Exception(response.data['error'] ?? 'Failed to fetch post');
  }
}
