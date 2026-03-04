import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../user/presentation/providers/user_provider.dart';
import '../../../../core/network/connectivity/internet_status_provider.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../data/datasources/daily_activity_local_datasource.dart';
import '../../data/datasources/daily_activity_remote_datasource.dart';
import '../../data/models/user_activity_model.dart';
import '../../data/models/activity_log_model.dart';
import '../../../activity_types/data/models/activity_metric.dart';

class DailyActivityState {
  final List<UserActivityModel> activities;
  final List<UserActivityModel> todayActivities;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final int pendingSyncCount;
  final int pendingLogCount;

  const DailyActivityState({
    this.activities = const [],
    this.todayActivities = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.pendingSyncCount = 0,
    this.pendingLogCount = 0,
  });

  DailyActivityState copyWith({
    List<UserActivityModel>? activities,
    List<UserActivityModel>? todayActivities,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    int? pendingSyncCount,
    int? pendingLogCount,
  }) {
    return DailyActivityState(
      activities: activities ?? this.activities,
      todayActivities: todayActivities ?? this.todayActivities,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      pendingLogCount: pendingLogCount ?? this.pendingLogCount,
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
        syncPendingLogs();
      }
    });
  }

  Future<void> loadActivities() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('[DailyActivityProvider] loadActivities - starting');
      await _updateState();
      print('[DailyActivityProvider] loadActivities - local data loaded');

      _tryFetchFromRemote();
    } catch (e) {
      print('[DailyActivityProvider] loadActivities ERROR: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _tryFetchFromRemote() async {
    try {
      final userId = _ref.read(currentUserProvider)?.uid;
      if (userId == null) {
        print(
          '[DailyActivityProvider] _tryFetchFromRemote - userId is null, skipping',
        );
        return;
      }

      final remoteActivities = await _remoteDataSource.fetchActivities(userId);
      print(
        '[DailyActivityProvider] fetchFromRemote - got ${remoteActivities.length} activities',
      );

      for (var activity in remoteActivities) {
        await _localDataSource.save(activity);
      }

      await _updateState();
    } catch (e) {
      print('[DailyActivityProvider] fetchFromRemote ERROR: $e');
    }
  }

  Future<void> addActivity({
    required String activityType,
    required String activityTypeId,
    required String title,
    String? description,
    int? intervalMinutes,
    int targetCompletions = 1,
    bool isAlarmEnabled = false,
    bool isPushEnabled = false,
    List<ActivityMetric> metrics = const [],
  }) async {
    final now = DateTime.now();
    final activity = UserActivityModel(
      id: '${now.millisecondsSinceEpoch}',
      date: now,
      activityType: activityType,
      activityTypeId: activityTypeId,
      title: title,
      description: description,
      isSynced: false,
      createdAt: now,
      intervalMinutes: intervalMinutes,
      targetCompletions: targetCompletions,
      isAlarmEnabled: isAlarmEnabled,
      isPushEnabled: isPushEnabled,
      metrics: metrics,
    );

    await _localDataSource.save(activity);
    print(
      '[DailyActivityProvider] addActivity - local save done: ${activity.title}',
    );

    await _updateState();

    await LocalNotificationService.instance.showActivityReminder(
      id: now.millisecondsSinceEpoch % 100000,
      activityName: title,
      description: description,
    );

    _trySyncActivity(activity);
  }

  Future<void> _trySyncActivity(UserActivityModel activity) async {
    try {
      final userId = _ref.read(currentUserProvider)?.uid;
      if (userId == null) {
        print(
          '[DailyActivityProvider] _trySyncActivity - userId is null, skipping',
        );
        return;
      }

      final syncedActivity = await _remoteDataSource.createActivity(
        userId,
        activity,
      );
      print(
        '[DailyActivityProvider] _trySyncActivity - sync SUCCESS: ${syncedActivity.id}',
      );

      await _localDataSource.delete(activity.id);
      await _localDataSource.save(syncedActivity);

      await _updateState();
    } catch (e) {
      print('[DailyActivityProvider] _trySyncActivity ERROR: $e');
    }
  }

  Future<void> syncPendingActivities() async {
    final pending = await _localDataSource.getPendingSync();
    if (pending.isEmpty) return;

    state = state.copyWith(isSyncing: true);

    try {
      for (var activity in pending) {
        await _trySyncActivity(activity);
      }
      state = state.copyWith(isSyncing: false);
    } catch (_) {
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> completeActivity(
    String id, {
    Map<String, String>? metricValues,
  }) async {
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

    final now = DateTime.now();
    final log = ActivityLogModel(
      id: now.millisecondsSinceEpoch.toString(),
      userActivityId: activity.id,
      completedAt: now,
      metrics: metricValues ?? {},
    );
    await _localDataSource.saveLog(log);
    print('[DailyActivityProvider] completeActivity - log saved locally');

    await _updateState();

    _trySyncActivity(updatedActivity);
    _trySyncLog(log);
  }

  Future<void> recordCompletion(
    String id, {
    Map<String, String>? metricValues,
  }) async {
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

    final log = ActivityLogModel(
      id: now.millisecondsSinceEpoch.toString(),
      userActivityId: activity.id,
      completedAt: now,
      metrics: metricValues ?? {},
    );
    await _localDataSource.saveLog(log);
    print('[DailyActivityProvider] recordCompletion - log saved locally');

    await _updateState();

    if (updatedTimes.length >= activity.targetCompletions) {
      await LocalNotificationService.instance.showImmediate(
        id: activity.id.hashCode % 100000,
        title: '✅ Activity Complete!',
        body: '${activity.title} fully completed for today. Great job!',
      );
    }

    _trySyncActivity(updatedActivity);
    _trySyncLog(log);
  }

  Future<void> deleteActivity(String id) async {
    await _localDataSource.delete(id);
    print('[DailyActivityProvider] deleteActivity - done: $id');
    await _updateState();
  }

  Future<void> _updateState() async {
    final allActivities = await _localDataSource.getAll();
    final today = DateTime.now();
    final todayActivities = await _localDataSource.getByDate(today);
    final pendingSync = await _localDataSource.getPendingSync();
    final pendingLogs = await _localDataSource.getPendingLogs();

    print(
      '[DailyActivityProvider] state update - all: ${allActivities.length}, today: ${todayActivities.length}',
    );

    state = state.copyWith(
      activities: allActivities,
      todayActivities: todayActivities,
      pendingSyncCount: pendingSync.length,
      pendingLogCount: pendingLogs.length,
      isLoading: false,
    );
  }

  Future<void> _trySyncLog(ActivityLogModel log) async {
    try {
      final userId = _ref.read(currentUserProvider)?.uid;
      if (userId == null) return;

      final syncedLog = await _remoteDataSource.createLog(userId, log);
      await _localDataSource.deleteLog(log.id);
      await _localDataSource.saveLog(syncedLog);

      final pendingLogs = await _localDataSource.getPendingLogs();
      state = state.copyWith(pendingLogCount: pendingLogs.length);
    } catch (_) {}
  }

  Future<void> syncPendingLogs() async {
    final pending = await _localDataSource.getPendingLogs();
    if (pending.isEmpty) return;

    state = state.copyWith(isSyncing: true);

    try {
      for (var log in pending) {
        await _trySyncLog(log);
      }
      state = state.copyWith(isSyncing: false);
    } catch (_) {
      state = state.copyWith(isSyncing: false);
    }
  }
}

final dailyActivityProvider =
    StateNotifierProvider<DailyActivityNotifier, DailyActivityState>((ref) {
      return DailyActivityNotifier(ref);
    });
