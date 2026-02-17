import 'package:dio/dio.dart';
import '../network/http/dio_client.dart';

class ApiClient {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post(path, data: body);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.put(path, data: body);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
