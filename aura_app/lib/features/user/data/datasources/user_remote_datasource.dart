import 'dart:developer' as dev;
import 'package:dio/dio.dart';

import '../../../../core/network/http/api_endpoints.dart';
import '../../../../core/network/http/dio_client.dart';
import '../../../../core/network/push/fcm_handler.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<UserModel> getCurrentUser() async {
    try {
      dev.log('USER_DS - GET ${ApiEndpoints.me}', name: 'API');
      final response = await _dio.get(ApiEndpoints.me);
      dev.log(
        'USER_DS - GET /me RESPONSE: ${response.statusCode} | profileCompleted: ${response.data['profileCompleted']} | username: ${response.data['username']}',
        name: 'API',
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      dev.log('USER_DS - GET /me ERROR: $e', name: 'API');
      throw Exception('Failed to fetch current user: ${e.toString()}');
    }
  }

  Future<UserModel> getUserByUid(String uid) async {
    try {
      dev.log('USER_DS - GET ${ApiEndpoints.userProfile}/$uid', name: 'API');
      final response = await _dio.get('${ApiEndpoints.userProfile}/$uid');
      dev.log(
        'USER_DS - GET /user/$uid RESPONSE: ${response.statusCode}',
        name: 'API',
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      dev.log('USER_DS - GET /user/$uid ERROR: $e', name: 'API');
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }

  Future<bool> isUsernameAvailable({
    required String username,
    required String uid,
  }) async {
    try {
      dev.log(
        'USER_DS - GET ${ApiEndpoints.usernameAvailable} | username: $username | uid: $uid',
        name: 'API',
      );
      final response = await _dio.get(
        ApiEndpoints.usernameAvailable,
        queryParameters: {'username': username, 'uid': uid},
      );
      final available = response.data['available'] ?? false;
      dev.log(
        'USER_DS - /username-available RESPONSE: available=$available',
        name: 'API',
      );
      return available;
    } catch (e) {
      dev.log('USER_DS - /username-available ERROR: $e', name: 'API');
      throw Exception('Failed to check username: ${e.toString()}');
    }
  }

  Future<UserModel> updateProfile({
    required String uid,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? gender,
    String? dob,
    String? profileImageUrl,
    String? password,
    bool? phoneVerified,
  }) async {
    try {
      final data = <String, dynamic>{
        'uid': uid,
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
        if (dob != null) 'dob': dob,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (password != null) 'password': '***',
        if (phoneVerified == true) 'phoneVerified': true,
      };

      final requestData = <String, dynamic>{
        'uid': uid,
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
        if (dob != null) 'dob': dob,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (password != null) 'password': password,
        if (phoneVerified == true) 'phoneVerified': true,
      };

      dev.log(
        'USER_DS - PUT ${ApiEndpoints.updateProfile} | data: $data',
        name: 'API',
      );

      final fcmToken = await FcmHandler.instance.getToken();
      if (fcmToken != null) {
        requestData['fcmToken'] = fcmToken;
        dev.log(
          'USER_DS - PUT /profile | Injected fcmToken $fcmToken',
          name: 'API',
        );
      }

      final response = await _dio.put(
        ApiEndpoints.updateProfile,
        data: requestData,
      );
      dev.log(
        'USER_DS - PUT /profile RESPONSE: ${response.statusCode} | profileCompleted: ${response.data['profileCompleted']}',
        name: 'API',
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['error'] ??
          'Failed to update profile: ${e.message}';
      dev.log(
        'USER_DS - PUT /profile DIO ERROR: $errorMessage | status: ${e.response?.statusCode}',
        name: 'API',
      );
      throw Exception(errorMessage);
    } catch (e) {
      dev.log('USER_DS - PUT /profile ERROR: $e', name: 'API');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}
