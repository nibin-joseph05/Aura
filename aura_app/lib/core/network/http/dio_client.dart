import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import 'firebase_auth_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    final baseUrl = AppConfig.baseUrl;

    if (baseUrl.isEmpty) {
      throw Exception("API_BASE_URL is not set in .env");
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      ),
    );

    dio.interceptors.add(AuthInterceptor());
  }
}
