import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/http/dio_client.dart';

class NotificationApiService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getNotifications(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    debugPrint(
      '[NOTIF_API] getNotifications userId=$userId page=$page size=$size',
    );
    final response = await _dio.get(
      '/api/users/$userId/notifications',
      queryParameters: {'page': page, 'size': size},
    );
    final raw = response.data as Map<String, dynamic>? ?? {};
    final data = raw['data'] as Map<String, dynamic>? ?? raw;
    debugPrint(
      '[NOTIF_API] getNotifications RESPONSE: ${(data['content'] as List?)?.length ?? 0} items',
    );
    return data;
  }

  Future<Map<String, dynamic>> getBroadcastNotifications({
    int page = 0,
    int size = 20,
  }) async {
    debugPrint('[NOTIF_API] getBroadcastNotifications page=$page size=$size');
    final response = await _dio.get(
      '/api/admin/notifications/broadcasts',
      queryParameters: {'page': page, 'size': size},
    );
    final raw = response.data as Map<String, dynamic>? ?? {};
    final data = raw['data'] as Map<String, dynamic>? ?? raw;
    debugPrint(
      '[NOTIF_API] getBroadcastNotifications RESPONSE: ${(data['content'] as List?)?.length ?? 0} items',
    );
    return data;
  }

  Future<void> registerFcmToken(String uid, String token) async {
    debugPrint('[NOTIF_API] registerFcmToken uid=$uid');
    await _dio.post('/api/user/fcm-token', data: {'uid': uid, 'token': token});
  }

  Future<void> markAsRead(String notificationId) async {
    debugPrint('[NOTIF_API] markAsRead id=$notificationId');
    await _dio.put('/api/notifications/$notificationId/read');
  }
}
