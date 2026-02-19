import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/widgets.dart';
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
  final String otherUserName;
  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.otherUserId,
    this.otherUserName = '',
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
      otherUserName: isParticipantOne
          ? (json['participantTwoName'] ?? '')
          : (json['participantOneName'] ?? ''),
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
  final String followerName;
  final String followingId;
  final String status;

  FollowRequestModel({
    required this.id,
    required this.followerId,
    this.followerName = '',
    required this.followingId,
    required this.status,
  });

  factory FollowRequestModel.fromJson(Map<String, dynamic> json) {
    return FollowRequestModel(
      id: json['id'],
      followerId: json['followerId'],
      followerName: json['followerName'] ?? '',
      followingId: json['followingId'],
      status: json['status'],
    );
  }
}

class _QueuedMessage {
  final String conversationId;
  final String content;
  final DateTime queuedAt;

  _QueuedMessage({
    required this.conversationId,
    required this.content,
    DateTime? queuedAt,
  }) : queuedAt = queuedAt ?? DateTime.now();
}

class MessagingState {
  final List<ConversationModel> conversations;
  final List<MessageModel> messages;
  final List<FollowRequestModel> followRequests;
  final int pendingFollowCount;
  final bool isLoading;
  final String? error;
  final String? activeConversationId;
  final bool isConnected;

  MessagingState({
    this.conversations = const [],
    this.messages = const [],
    this.followRequests = const [],
    this.pendingFollowCount = 0,
    this.isLoading = false,
    this.error,
    this.activeConversationId,
    this.isConnected = false,
  });

  MessagingState copyWith({
    List<ConversationModel>? conversations,
    List<MessageModel>? messages,
    List<FollowRequestModel>? followRequests,
    int? pendingFollowCount,
    bool? isLoading,
    String? error,
    String? activeConversationId,
    bool? isConnected,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      followRequests: followRequests ?? this.followRequests,
      pendingFollowCount: pendingFollowCount ?? this.pendingFollowCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class MessagingNotifier extends StateNotifier<MessagingState>
    with WidgetsBindingObserver {
  MessagingNotifier() : super(MessagingState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final _api = MessagingApiService();
  StompClient? _stompClient;
  String? _currentUserId;

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _baseReconnectDelay = Duration(seconds: 2);

  final Queue<_QueuedMessage> _offlineQueue = Queue<_QueuedMessage>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentUserId == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _reconnect();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void connectWebSocket(String userId) {
    _currentUserId = userId;
    _reconnectAttempts = 0;
    _cancelReconnectTimer();
    _doConnect();
  }

  void _doConnect() {
    if (_currentUserId == null) return;

    try {
      _stompClient?.deactivate();
    } catch (_) {}

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${AppConfig.baseUrl}/ws',
        onConnect: _onConnect,
        onWebSocketError: (error) {
          state = state.copyWith(
            error: 'WebSocket error: $error',
            isConnected: false,
          );
          _scheduleReconnect();
        },
        onDisconnect: (frame) {
          state = state.copyWith(isConnected: false);
          _scheduleReconnect();
        },
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    _reconnectAttempts = 0;
    state = state.copyWith(isConnected: true);

    _stompClient!.subscribe(
      destination: '/user/$_currentUserId/queue/messages',
      callback: (frame) {
        if (frame.body == null) return;
        final data = json.decode(frame.body!);
        final msg = MessageModel.fromJson(data);

        if (state.activeConversationId == msg.conversationId) {
          state = state.copyWith(messages: [msg, ...state.messages]);
          markAsRead(msg.conversationId);
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

    _flushOfflineQueue();
  }

  void disconnect() {
    _cancelReconnectTimer();
    _currentUserId = null;
    try {
      _stompClient?.deactivate();
    } catch (_) {}
    _stompClient = null;
    state = state.copyWith(isConnected: false);
  }

  void _scheduleReconnect() {
    if (_currentUserId == null) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) return;

    _cancelReconnectTimer();
    final delay = _baseReconnectDelay * (1 << _reconnectAttempts);
    _reconnectAttempts++;

    _reconnectTimer = Timer(delay, _reconnect);
  }

  void _reconnect() {
    if (_currentUserId == null) return;
    if (state.isConnected) return;
    _doConnect();
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Future<void> _flushOfflineQueue() async {
    while (_offlineQueue.isNotEmpty) {
      final queued = _offlineQueue.removeFirst();
      try {
        await _sendMessageInternal(queued.conversationId, queued.content);
      } catch (_) {
        _offlineQueue.addFirst(queued);
        break;
      }
    }
  }

  Future<void> loadConversations([String? userId]) async {
    final uid = userId ?? _currentUserId;
    if (uid == null) return;
    try {
      state = state.copyWith(isLoading: true);
      final data = await _api.getConversations(uid);
      final content = data['content'] as List? ?? [];
      final convs = content
          .map(
            (c) => ConversationModel.fromJson(c as Map<String, dynamic>, uid),
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

      markAsRead(conversationId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String conversationId, String content) async {
    if (_currentUserId == null) return;

    if (!state.isConnected) {
      _offlineQueue.add(
        _QueuedMessage(conversationId: conversationId, content: content),
      );
      state = state.copyWith(
        messages: [
          MessageModel(
            id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
            conversationId: conversationId,
            senderId: _currentUserId!,
            content: content,
            type: 'TEXT',
            status: 'PENDING',
            sentAt: DateTime.now(),
          ),
          ...state.messages,
        ],
      );
      return;
    }

    await _sendMessageInternal(conversationId, content);
  }

  Future<void> _sendMessageInternal(
    String conversationId,
    String content,
  ) async {
    try {
      final data = await _api.sendMessage(
        _currentUserId!,
        conversationId,
        content,
      );
      final msg = MessageModel.fromJson(data);
      final updated = state.messages
          .where((m) => !m.id.startsWith('pending_') || m.content != content)
          .toList();
      state = state.copyWith(messages: [msg, ...updated]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    if (_currentUserId == null) return;
    try {
      await _api.markAsRead(conversationId, _currentUserId!);
      final updatedConvs = state.conversations.map((c) {
        if (c.id == conversationId) {
          return ConversationModel(
            id: c.id,
            otherUserId: c.otherUserId,
            otherUserName: c.otherUserName,
            lastMessagePreview: c.lastMessagePreview,
            lastMessageAt: c.lastMessageAt,
            unreadCount: 0,
          );
        }
        return c;
      }).toList();
      state = state.copyWith(conversations: updatedConvs);
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
    _cancelReconnectTimer();
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    super.dispose();
  }
}
