import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity/internet_status_provider.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../data/datasources/daily_activity_local_datasource.dart';
import '../../data/datasources/daily_activity_remote_datasource.dart';
import '../../data/models/daily_activity_model.dart';

class DailyActivityState {
  final List<DailyActivityModel> activities;
  final List<DailyActivityModel> todayActivities;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final int pendingSyncCount;

  const DailyActivityState({
    this.activities = const [],
    this.todayActivities = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.pendingSyncCount = 0,
  });

  DailyActivityState copyWith({
    List<DailyActivityModel>? activities,
    List<DailyActivityModel>? todayActivities,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    int? pendingSyncCount,
  }) {
    return DailyActivityState(
      activities: activities ?? this.activities,
      todayActivities: todayActivities ?? this.todayActivities,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }
}

class DailyActivityNotifier extends StateNotifier<DailyActivityState> {
  final DailyActivityLocalDataSource _localDataSource;
  final DailyActivityRemoteDataSource _remoteDataSource;
  final Ref _ref;

  DailyActivityNotifier(this._ref)
    : _localDataSource = DailyActivityLocalDataSource(),
      _remoteDataSource = DailyActivityRemoteDataSource(),
      super(const DailyActivityState()) {
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _ref.listen<AsyncValue<bool>>(internetStatusProvider, (previous, next) {
      final wasOffline = previous?.valueOrNull == false;
      final isOnline = next.valueOrNull == true;

      if (wasOffline && isOnline) {
        syncPendingActivities();
      }
    });
  }

  Future<void> loadActivities() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final activities = await _localDataSource.getAll();
      final today = DateTime.now();
      final todayActivities = await _localDataSource.getByDate(today);
      final pending = await _localDataSource.getPendingSync();

      state = state.copyWith(
        activities: activities,
        todayActivities: todayActivities,
        isLoading: false,
        pendingSyncCount: pending.length,
      );

      _tryFetchFromRemote();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _tryFetchFromRemote() async {
    final isOnline = _ref.read(internetStatusProvider).valueOrNull ?? false;
    if (!isOnline) return;

    try {
      final remoteActivities = await _remoteDataSource.fetchActivities();
      for (var activity in remoteActivities) {
        await _localDataSource.save(activity);
      }

      final activities = await _localDataSource.getAll();
      final today = DateTime.now();
      final todayActivities = await _localDataSource.getByDate(today);

      state = state.copyWith(
        activities: activities,
        todayActivities: todayActivities,
      );
    } catch (_) {}
  }

  Future<void> addActivity({
    required String activityType,
    required String title,
    String? description,
    int? intervalMinutes,
    int targetCompletions = 1,
  }) async {
    final now = DateTime.now();
    final activity = DailyActivityModel(
      id: '${now.millisecondsSinceEpoch}',
      date: now,
      activityType: activityType,
      title: title,
      description: description,
      isSynced: false,
      createdAt: now,
      intervalMinutes: intervalMinutes,
      targetCompletions: targetCompletions,
    );

    await _localDataSource.save(activity);

    final todayActivities = await _localDataSource.getByDate(now);
    final pending = await _localDataSource.getPendingSync();

    state = state.copyWith(
      todayActivities: todayActivities,
      pendingSyncCount: pending.length,
    );

    // Notify user that activity has been added
    await LocalNotificationService.instance.showActivityReminder(
      id: now.millisecondsSinceEpoch % 100000,
      activityName: title,
      description: description,
    );

    _trySyncActivity(activity);
  }

  Future<void> _trySyncActivity(DailyActivityModel activity) async {
    final isOnline = _ref.read(internetStatusProvider).valueOrNull ?? false;
    if (!isOnline) return;

    try {
      await _remoteDataSource.createActivity(activity);
      await _localDataSource.markAsSynced(activity.id);

      final pending = await _localDataSource.getPendingSync();
      state = state.copyWith(pendingSyncCount: pending.length);
    } catch (_) {}
  }

  Future<void> syncPendingActivities() async {
    final pending = await _localDataSource.getPendingSync();
    if (pending.isEmpty) return;

    state = state.copyWith(isSyncing: true);

    try {
      await _remoteDataSource.syncActivities(pending);

      for (var activity in pending) {
        await _localDataSource.markAsSynced(activity.id);
      }

      state = state.copyWith(isSyncing: false, pendingSyncCount: 0);
    } catch (_) {
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> completeActivity(String id) async {
    final activities = await _localDataSource.getAll();
    final activity = activities.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Activity not found'),
    );

    final updatedActivity = activity.copyWith(
      completedAt: DateTime.now(),
      isSynced: false,
    );

    await _localDataSource.save(updatedActivity);

    final todayActivities = await _localDataSource.getByDate(DateTime.now());
    final pending = await _localDataSource.getPendingSync();

    state = state.copyWith(
      todayActivities: todayActivities,
      pendingSyncCount: pending.length,
    );

    _trySyncActivity(updatedActivity);
  }

  Future<void> recordCompletion(String id) async {
    final activities = await _localDataSource.getAll();
    final activity = activities.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Activity not found'),
    );

    if (activity.isFullyCompleted) return;

    final now = DateTime.now();
    final updatedTimes = [...activity.completionTimes, now];
    final isNowFull = updatedTimes.length >= activity.targetCompletions;

    final updatedActivity = activity.copyWith(
      completionTimes: updatedTimes,
      completedAt: isNowFull ? now : activity.completedAt,
      isSynced: false,
    );

    await _localDataSource.save(updatedActivity);

    final todayActivities = await _localDataSource.getByDate(DateTime.now());
    final pending = await _localDataSource.getPendingSync();

    state = state.copyWith(
      todayActivities: todayActivities,
      pendingSyncCount: pending.length,
    );

    // Show completion notification when fully done
    if (updatedTimes.length >= activity.targetCompletions) {
      await LocalNotificationService.instance.showImmediate(
        id: activity.id.hashCode % 100000,
        title: '✅ Activity Complete!',
        body: '${activity.title} fully completed for today. Great job!',
      );
    }

    _trySyncActivity(updatedActivity);
  }

  Future<void> deleteActivity(String id) async {
    await _localDataSource.delete(id);

    final todayActivities = await _localDataSource.getByDate(DateTime.now());
    final pending = await _localDataSource.getPendingSync();

    state = state.copyWith(
      todayActivities: todayActivities,
      pendingSyncCount: pending.length,
    );
  }
}

final dailyActivityProvider =
    StateNotifierProvider<DailyActivityNotifier, DailyActivityState>((ref) {
      return DailyActivityNotifier(ref);
    });
