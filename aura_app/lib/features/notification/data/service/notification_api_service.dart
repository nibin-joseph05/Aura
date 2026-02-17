import 'package:dio/dio.dart';
import '../../../../core/network/http/dio_client.dart';

class NotificationApiService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getNotifications(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/api/users/$userId/notifications',
      queryParameters: {'page': page, 'size': size},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getBroadcastNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/api/notifications/broadcast',
      queryParameters: {'page': page, 'size': size},
    );
    return response.data;
  }

  Future<void> registerFcmToken(String uid, String token) async {
    await _dio.post('/api/user/fcm-token', data: {'uid': uid, 'token': token});
  }
}
