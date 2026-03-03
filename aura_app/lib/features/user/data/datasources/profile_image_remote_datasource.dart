import 'dart:developer' as dev;
import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/network/http/api_endpoints.dart';
import '../../../../core/network/http/dio_client.dart';
import '../models/upload_profile_image_response.dart';

class ProfileImageRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<UploadProfileImageResponse> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      dev.log(
        'UPLOAD_DS - POST ${ApiEndpoints.uploadProfileImage} | userId: $userId | file: ${imageFile.path} | size: ${imageFile.lengthSync()} bytes',
        name: 'API',
      );

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(Platform.pathSeparator).last,
        ),
        'userId': userId,
      });

      final response = await _dio.post(
        ApiEndpoints.uploadProfileImage,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      dev.log(
        'UPLOAD_DS - POST /profile-image RESPONSE: ${response.statusCode} | data: ${response.data}',
        name: 'API',
      );

      if (response.statusCode == 200 && response.data['url'] != null) {
        return UploadProfileImageResponse.fromJson(response.data);
      }

      throw Exception(response.data['error'] ?? 'Upload failed');
    } on DioException catch (e) {
      dev.log(
        'UPLOAD_DS - POST /profile-image DIO ERROR: ${e.response?.statusCode} | ${e.response?.data}',
        name: 'API',
      );
      throw Exception(
        e.response?.data?['error'] ?? 'Failed to upload image: ${e.message}',
      );
    } catch (e) {
      dev.log('UPLOAD_DS - POST /profile-image ERROR: $e', name: 'API');
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      dev.log(
        'UPLOAD_DS - DELETE ${ApiEndpoints.uploadProfileImage} | url: $imageUrl',
        name: 'API',
      );
      await _dio.delete(
        ApiEndpoints.uploadProfileImage,
        queryParameters: {'url': imageUrl},
      );
      dev.log('UPLOAD_DS - DELETE /profile-image RESPONSE: OK', name: 'API');
    } catch (e) {
      dev.log('UPLOAD_DS - DELETE /profile-image ERROR: $e', name: 'API');
    }
  }
}
