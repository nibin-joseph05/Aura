import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../data/service/notification_api_service.dart';

class NotificationState {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<Map<String, dynamic>>? notifications,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationApiService _api;
  final String _userId;

  NotificationNotifier(this._api, this._userId)
    : super(const NotificationState());

  Future<void> loadNotifications({bool refresh = false}) async {
    if (_userId.isEmpty) return;
    if (state.isLoading) return;

    final page = refresh ? 0 : state.currentPage;
    state = state.copyWith(isLoading: true);

    try {
      final userResult = await _api.getNotifications(_userId, page: page);
      final broadcastResult = await _api.getBroadcastNotifications(page: page);

      final userItems =
          (userResult['content'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final broadcastItems =
          (broadcastResult['content'] as List?)?.cast<Map<String, dynamic>>() ??
          [];

      final all = [...userItems, ...broadcastItems];
      all.sort((a, b) {
        final aTime = a['createdAt'] ?? '';
        final bTime = b['createdAt'] ?? '';
        return bTime.toString().compareTo(aTime.toString());
      });

      final existing = refresh
          ? <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(state.notifications);
      existing.addAll(all);

      state = state.copyWith(
        notifications: existing,
        isLoading: false,
        hasMore: userItems.length >= 20 || broadcastItems.length >= 20,
        currentPage: page + 1,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }
}

final notificationProvider =
    StateNotifierProvider.autoDispose<NotificationNotifier, NotificationState>((
      ref,
    ) {
      final userId = ref.watch(userProvider).user?.uid;
      if (userId == null || userId.isEmpty) {
        return NotificationNotifier(NotificationApiService(), '');
      }
      return NotificationNotifier(NotificationApiService(), userId);
    });
