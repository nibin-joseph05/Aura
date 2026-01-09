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

      if (response.statusCode == 200 && response.data['url'] != null) {
        return UploadProfileImageResponse.fromJson(response.data);
      }

      throw Exception(response.data['error'] ?? 'Upload failed');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Failed to upload image: ${e.message}',
      );
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      await _dio.delete(
        ApiEndpoints.uploadProfileImage,
        queryParameters: {'url': imageUrl},
      );
    } catch (e) {}
  }
}
