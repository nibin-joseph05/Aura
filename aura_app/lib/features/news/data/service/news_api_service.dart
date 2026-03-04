import 'package:dio/dio.dart';

import '../../../../core/network/http/api_endpoints.dart';
import '../../../../core/network/http/dio_client.dart';
import '../models/news_article.dart';

class NewsApiService {
  final Dio _dio = DioClient().dio;

  Future<List<NewsArticle>> getWellnessNews({
    String? query,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.newsWellness,
        queryParameters: {
          if (query != null) 'query': query,
          'pageSize': pageSize,
        },
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((j) => NewsArticle.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<NewsArticle>> getHealthHeadlines({int pageSize = 10}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.newsHeadlines,
        queryParameters: {'pageSize': pageSize},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((j) => NewsArticle.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }
}
