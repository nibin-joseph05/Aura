import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../connectivity/connectivity_service.dart';
import 'sync_status.dart';

typedef SyncFunction = Future<void> Function();

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final List<SyncFunction> _syncFunctions = [];
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  SyncStatus _currentStatus = const SyncStatus();
  SyncStatus get currentStatus => _currentStatus;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((result) async {
          final isOnline = result != ConnectivityResult.none;
          if (isOnline && _currentStatus.hasPending) {
            await syncAll();
          }
        });

    await refreshPendingCounts();
  }

  void registerSyncFunction(SyncFunction fn) {
    if (!_syncFunctions.contains(fn)) {
      _syncFunctions.add(fn);
    }
  }

  void unregisterSyncFunction(SyncFunction fn) {
    _syncFunctions.remove(fn);
  }

  Future<void> syncAll() async {
    if (_currentStatus.isSyncing) return;
    if (!await _connectivityService.hasConnection()) return;

    _updateStatus(_currentStatus.copyWith(isSyncing: true, lastError: null));

    try {
      for (final syncFn in _syncFunctions) {
        await syncFn();
      }
      _updateStatus(
        _currentStatus.copyWith(
          isSyncing: false,
          lastSyncTime: DateTime.now(),
          pendingSOS: 0,
          pendingWellness: 0,
          pendingActivities: 0,
        ),
      );
    } catch (e) {
      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastError: e.toString()),
      );
    }

    await refreshPendingCounts();
  }

  Future<void> refreshPendingCounts() async {}

  void updatePendingCount({int? sos, int? wellness, int? activities}) {
    _updateStatus(
      _currentStatus.copyWith(
        pendingSOS: sos ?? _currentStatus.pendingSOS,
        pendingWellness: wellness ?? _currentStatus.pendingWellness,
        pendingActivities: activities ?? _currentStatus.pendingActivities,
      ),
    );
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}
