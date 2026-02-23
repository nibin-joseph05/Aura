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

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String username,
    required String password,
    String? phone,
    String? gender,
    String? dob,
    String? profileImageUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim(),
        'username': username.trim(),
        'password': password,
      };
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (gender != null && gender.isNotEmpty) data['gender'] = gender;
      if (dob != null && dob.isNotEmpty) data['dob'] = dob;
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        data['profileImageUrl'] = profileImageUrl;
      }

      final response = await _dio.post(ApiEndpoints.register, data: data);
      return response.data;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['error'] ?? 'Registration failed: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
}
