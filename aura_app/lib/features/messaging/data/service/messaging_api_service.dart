import 'package:dio/dio.dart';
import '../../../../core/network/http/dio_client.dart';

class MessagingApiService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> sendFollowRequest(
    String fromUserId,
    String toUserId,
  ) async {
    final response = await _dio.post(
      '/api/messaging/follow/request',
      data: {'fromUserId': fromUserId, 'toUserId': toUserId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> acceptFollowRequest(String requestId) async {
    final response = await _dio.post('/api/messaging/follow/accept/$requestId');
    return response.data;
  }

  Future<void> rejectFollowRequest(String requestId) async {
    await _dio.post('/api/messaging/follow/reject/$requestId');
  }

  Future<Map<String, dynamic>> getPendingFollowRequests(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/api/messaging/follow/pending/$userId',
      queryParameters: {'page': page, 'size': size},
    );
    return response.data;
  }

  Future<int> getPendingFollowCount(String userId) async {
    final response = await _dio.get('/api/messaging/follow/count/$userId');
    return response.data['count'] ?? 0;
  }

  Future<Map<String, dynamic>> getOrCreateConversation(
    String userA,
    String userB,
  ) async {
    final response = await _dio.post(
      '/api/messaging/conversations',
      data: {'userA': userA, 'userB': userB},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getConversations(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/api/messaging/conversations/$userId',
      queryParameters: {'page': page, 'size': size},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> sendMessage(
    String senderId,
    String conversationId,
    String content, {
    String type = 'TEXT',
  }) async {
    final response = await _dio.post(
      '/api/messaging/messages',
      data: {
        'senderId': senderId,
        'conversationId': conversationId,
        'content': content,
        'type': type,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    int page = 0,
    int size = 30,
  }) async {
    final response = await _dio.get(
      '/api/messaging/messages/$conversationId',
      queryParameters: {'page': page, 'size': size},
    );
    return response.data;
  }

  Future<void> markAsRead(String conversationId, String userId) async {
    await _dio.post(
      '/api/messaging/messages/$conversationId/read',
      data: {'userId': userId},
    );
  }
}
