import 'package:dio/dio.dart';

import '../../../../core/network/http/api_endpoints.dart';
import '../../../../core/network/http/dio_client.dart';
import '../../../../core/network/push/fcm_handler.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final requestData = {
        'identifier': identifier.trim(),
        'password': password,
      };
      final fcmToken = await FcmHandler.instance.getToken();

      if (fcmToken != null) {
        requestData['fcmToken'] = fcmToken;
      }

      final response = await _dio.post(ApiEndpoints.login, data: requestData);
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

      final fcmToken = await FcmHandler.instance.getToken();
      if (fcmToken != null) {
        data['fcmToken'] = fcmToken;
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

  Future<void> changePassword({
    required String uid,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.changePassword,
        data: {
          'uid': uid,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['error'] ?? 'Password update failed: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email, {bool force = false}) async {
    try {
      await _dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email.trim(), 'force': force},
      );
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['error'] ??
          'Failed to send reset email: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email.trim(),
          'otp': otp.trim(),
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['error'] ?? 'Password reset failed: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
}
