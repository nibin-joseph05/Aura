import 'package:dio/dio.dart';

import '../../../../core/network/http/api_endpoints.dart';
import '../../../../core/network/http/dio_client.dart';
import '../models/user_model.dart';

class EmailVerificationService {
  final Dio _dio = DioClient().dio;

  Future<void> sendOtp(String email) async {
    try {
      await _dio.post(ApiEndpoints.verifyEmailSend, data: {'email': email});
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Failed to send OTP';
      throw Exception(msg);
    }
  }

  Future<UserModel> confirmOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyEmailConfirm,
        data: {'email': email, 'otp': otp},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Invalid or expired OTP';
      throw Exception(msg);
    }
  }
}
