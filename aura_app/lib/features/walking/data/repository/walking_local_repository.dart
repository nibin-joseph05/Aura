import 'package:hive/hive.dart';

import '../model/walking_session_model.dart';

class WalkingLocalRepository {
  static const String _boxName = 'walking_sessions';

  Box<WalkingSessionModel>? _box;

  bool get isInitialized => _box != null && _box!.isOpen;

  Box<WalkingSessionModel> get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
        'WalkingLocalRepository not initialized. Call init() first.',
      );
    }
    return _box!;
  }

  Future<void> init() async {
    if (isInitialized) return;
    _box = await Hive.openBox<WalkingSessionModel>(_boxName);
  }

  Future<WalkingSessionModel> startSession() async {
    final session = WalkingSessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      isActive: true,
    );
    await box.put(session.id, session);
    return session;
  }

  Future<void> addRoutePoint(String sessionId, RoutePoint point) async {
    final session = box.get(sessionId);
    if (session != null && session.isActive) {
      session.routePoints.add(point);
      await session.save();
    }
  }

  Future<WalkingSessionModel?> endSession(
    String sessionId, {
    double? distance,
    int? steps,
  }) async {
    final session = box.get(sessionId);
    if (session != null) {
      session.endTime = DateTime.now();
      session.isActive = false;
      session.durationSeconds = session.endTime!
          .difference(session.startTime)
          .inSeconds;
      if (distance != null) session.distanceMeters = distance;
      if (steps != null) session.stepsCount = steps;
      session.caloriesBurned = (session.distanceMeters / 1000) * 50;
      await session.save();
      return session;
    }
    return null;
  }

  WalkingSessionModel? getActiveSession() {
    try {
      return box.values.firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  List<WalkingSessionModel> getCompletedSessions() {
    return box.values.where((s) => !s.isActive).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<WalkingSessionModel> getUnsyncedSessions() {
    return box.values.where((s) => !s.isActive && !s.isSynced).toList();
  }

  Future<void> markAsSynced(String sessionId, String remoteId) async {
    final session = box.get(sessionId);
    if (session != null) {
      session.isSynced = true;
      session.remoteId = remoteId;
      await session.save();
    }
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}
