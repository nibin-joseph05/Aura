import 'package:dio/dio.dart';

import '../../../../core/network/http/api_endpoints.dart';
import '../../../../core/network/http/dio_client.dart';
import '../../../auth/data/models/user_model.dart';

class UserRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch current user: ${e.toString()}');
    }
  }

  Future<UserModel> getUserByUid(String uid) async {
    try {
      final response = await _dio.get('${ApiEndpoints.userProfile}/$uid');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }

  Future<bool> isUsernameAvailable({
    required String username,
    required String uid,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.usernameAvailable,
        queryParameters: {
          'username': username,
          'uid': uid,
        },
      );
      return response.data['available'] ?? false;
    } catch (e) {
      throw Exception('Failed to check username: ${e.toString()}');
    }
  }

  Future<UserModel> updateProfile({
    required String uid,
    String? name,
    String? username,
    String? gender,
    String? dob,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.updateProfile,
        data: {
          'uid': uid,
          if (name != null) 'name': name,
          if (username != null) 'username': username,
          if (gender != null) 'gender': gender,
          if (dob != null) 'dob': dob,
          if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        },
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}