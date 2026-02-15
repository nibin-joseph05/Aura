import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../../core/config/app_config.dart';
import '../../data/service/messaging_api_service.dart';

final messagingProvider =
    StateNotifierProvider<MessagingNotifier, MessagingState>((ref) {
      return MessagingNotifier();
    });

class ConversationModel {
  final String id;
  final String otherUserId;
  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.otherUserId,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final isParticipantOne = json['participantOneId'] == currentUserId;
    return ConversationModel(
      id: json['id'],
      otherUserId: isParticipantOne
          ? json['participantTwoId']
          : json['participantOneId'],
      lastMessagePreview: json['lastMessagePreview'] ?? '',
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      unreadCount: isParticipantOne
          ? (json['unreadCountOne'] ?? 0)
          : (json['unreadCountTwo'] ?? 0),
    );
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String type;
  final String status;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.status,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? json['messageType'] ?? 'TEXT',
      status: json['status'] ?? 'SENT',
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'])
          : DateTime.now(),
    );
  }
}

class FollowRequestModel {
  final String id;
  final String followerId;
  final String followingId;
  final String status;

  FollowRequestModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.status,
  });

  factory FollowRequestModel.fromJson(Map<String, dynamic> json) {
    return FollowRequestModel(
      id: json['id'],
      followerId: json['followerId'],
      followingId: json['followingId'],
      status: json['status'],
    );
  }
}

class MessagingState {
  final List<ConversationModel> conversations;
  final List<MessageModel> messages;
  final List<FollowRequestModel> followRequests;
  final int pendingFollowCount;
  final bool isLoading;
  final String? error;
  final String? activeConversationId;

  MessagingState({
    this.conversations = const [],
    this.messages = const [],
    this.followRequests = const [],
    this.pendingFollowCount = 0,
    this.isLoading = false,
    this.error,
    this.activeConversationId,
  });

  MessagingState copyWith({
    List<ConversationModel>? conversations,
    List<MessageModel>? messages,
    List<FollowRequestModel>? followRequests,
    int? pendingFollowCount,
    bool? isLoading,
    String? error,
    String? activeConversationId,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      followRequests: followRequests ?? this.followRequests,
      pendingFollowCount: pendingFollowCount ?? this.pendingFollowCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeConversationId: activeConversationId ?? this.activeConversationId,
    );
  }
}

class MessagingNotifier extends StateNotifier<MessagingState> {
  MessagingNotifier() : super(MessagingState());

  final _api = MessagingApiService();
  StompClient? _stompClient;
  String? _currentUserId;

  void connectWebSocket(String userId) {
    _currentUserId = userId;

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${AppConfig.baseUrl}/ws',
        onConnect: _onConnect,
        onWebSocketError: (error) {
          state = state.copyWith(error: 'WebSocket error: $error');
        },
        onDisconnect: (frame) {},
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    _stompClient!.subscribe(
      destination: '/user/$_currentUserId/queue/messages',
      callback: (frame) {
        if (frame.body == null) return;
        final data = json.decode(frame.body!);
        final msg = MessageModel.fromJson(data);

        if (state.activeConversationId == msg.conversationId) {
          state = state.copyWith(messages: [msg, ...state.messages]);
        }
        loadConversations(_currentUserId!);
      },
    );

    _stompClient!.subscribe(
      destination: '/user/$_currentUserId/queue/follow-requests',
      callback: (frame) {
        if (frame.body == null) return;
        state = state.copyWith(
          pendingFollowCount: state.pendingFollowCount + 1,
        );
      },
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }

  Future<void> loadConversations(String userId) async {
    try {
      state = state.copyWith(isLoading: true);
      final data = await _api.getConversations(userId);
      final content = data['content'] as List? ?? [];
      final convs = content
          .map(
            (c) =>
                ConversationModel.fromJson(c as Map<String, dynamic>, userId),
          )
          .toList();
      state = state.copyWith(conversations: convs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        activeConversationId: conversationId,
      );
      final data = await _api.getMessages(conversationId);
      final content = data['content'] as List? ?? [];
      final msgs = content
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
      state = state.copyWith(messages: msgs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String conversationId, String content) async {
    if (_currentUserId == null) return;
    try {
      final data = await _api.sendMessage(
        _currentUserId!,
        conversationId,
        content,
      );
      final msg = MessageModel.fromJson(data);
      state = state.copyWith(messages: [msg, ...state.messages]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAsRead(String conversationId) async {
    if (_currentUserId == null) return;
    try {
      await _api.markAsRead(conversationId, _currentUserId!);
    } catch (_) {}
  }

  Future<void> loadFollowRequests(String userId) async {
    try {
      state = state.copyWith(isLoading: true);
      final data = await _api.getPendingFollowRequests(userId);
      final content = data['content'] as List? ?? [];
      final requests = content
          .map((r) => FollowRequestModel.fromJson(r as Map<String, dynamic>))
          .toList();
      state = state.copyWith(followRequests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> acceptFollow(String requestId) async {
    try {
      await _api.acceptFollowRequest(requestId);
      state = state.copyWith(
        followRequests: state.followRequests
            .where((r) => r.id != requestId)
            .toList(),
        pendingFollowCount: (state.pendingFollowCount - 1).clamp(0, 999),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectFollow(String requestId) async {
    try {
      await _api.rejectFollowRequest(requestId);
      state = state.copyWith(
        followRequests: state.followRequests
            .where((r) => r.id != requestId)
            .toList(),
        pendingFollowCount: (state.pendingFollowCount - 1).clamp(0, 999),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendFollowRequest(String toUserId) async {
    if (_currentUserId == null) return;
    try {
      await _api.sendFollowRequest(_currentUserId!, toUserId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadPendingCount(String userId) async {
    try {
      final count = await _api.getPendingFollowCount(userId);
      state = state.copyWith(pendingFollowCount: count);
    } catch (_) {}
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
