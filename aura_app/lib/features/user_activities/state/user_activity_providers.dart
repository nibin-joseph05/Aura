import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_activity_repository.dart';
import '../data/models/user_activity.dart';
import '../data/models/activity_log.dart';

final userActivityRepositoryProvider = Provider<UserActivityRepository>((ref) {
  return UserActivityRepository();
});

final userActivitiesProvider =
    FutureProvider.family<List<UserActivity>, String>((ref, userId) async {
      final repository = ref.read(userActivityRepositoryProvider);
      return await repository.getUserActivities(userId);
    });

final activitiesForDateProvider =
    FutureProvider.family<List<UserActivity>, ({String userId, DateTime date})>(
      (ref, params) async {
        final repository = ref.read(userActivityRepositoryProvider);
        return await repository.getActivitiesForDate(
          params.userId,
          params.date,
        );
      },
    );

final activityLogsForDateProvider =
    FutureProvider.family<List<ActivityLog>, ({String userId, DateTime date})>((
      ref,
      params,
    ) async {
      final repository = ref.read(userActivityRepositoryProvider);
      return await repository.getLogsForDate(params.userId, params.date);
    });

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

class UserActivityNotifier
    extends StateNotifier<AsyncValue<List<UserActivity>>> {
  final UserActivityRepository _repository;
  final String userId;

  UserActivityNotifier(this._repository, this.userId)
    : super(const AsyncValue.loading()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    state = const AsyncValue.loading();
    try {
      final activities = await _repository.getUserActivities(userId);
      state = AsyncValue.data(activities);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final activities = await _repository.getUserActivities(
        userId,
        forceRefresh: true,
      );
      state = AsyncValue.data(activities);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<UserActivity?> createActivity(Map<String, dynamic> data) async {
    try {
      final activity = await _repository.createActivity(userId, data);
      await loadActivities();
      return activity;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteActivity(String activityId) async {
    try {
      await _repository.deleteActivity(activityId);
      await loadActivities();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final userActivityNotifierProvider =
    StateNotifierProvider.family<
      UserActivityNotifier,
      AsyncValue<List<UserActivity>>,
      String
    >((ref, userId) {
      final repository = ref.read(userActivityRepositoryProvider);
      return UserActivityNotifier(repository, userId);
    });
