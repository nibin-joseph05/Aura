import 'package:dio/dio.dart';

import '../../../../core/network/http/api_endpoints.dart';
import '../../../../core/network/http/dio_client.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'identifier': identifier.trim(), 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['error'] ?? 'Login failed: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
}
