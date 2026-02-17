import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/model/walking_session_model.dart';
import '../../data/repository/walking_local_repository.dart';

final walkingLocalRepositoryProvider = Provider<WalkingLocalRepository>((ref) {
  return WalkingLocalRepository();
});

final walkingProvider = StateNotifierProvider<WalkingNotifier, WalkingState>((
  ref,
) {
  return WalkingNotifier(ref.read(walkingLocalRepositoryProvider));
});

class WalkingState {
  final WalkingSessionModel? activeSession;
  final bool isTracking;
  final bool isInitialized;
  final Position? currentPosition;
  final double totalDistance;
  final int durationSeconds;
  final bool isLoading;
  final String? error;

  WalkingState({
    this.activeSession,
    this.isTracking = false,
    this.isInitialized = false,
    this.currentPosition,
    this.totalDistance = 0.0,
    this.durationSeconds = 0,
    this.isLoading = false,
    this.error,
  });

  WalkingState copyWith({
    WalkingSessionModel? activeSession,
    bool? isTracking,
    bool? isInitialized,
    Position? currentPosition,
    double? totalDistance,
    int? durationSeconds,
    bool? isLoading,
    String? error,
  }) {
    return WalkingState(
      activeSession: activeSession ?? this.activeSession,
      isTracking: isTracking ?? this.isTracking,
      isInitialized: isInitialized ?? this.isInitialized,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDistance: totalDistance ?? this.totalDistance,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WalkingNotifier extends StateNotifier<WalkingState> {
  final WalkingLocalRepository _repository;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _durationTimer;
  Position? _lastPosition;

  WalkingNotifier(this._repository) : super(WalkingState());

  Future<void> init() async {
    await _repository.init();
    final active = _repository.getActiveSession();
    if (active != null) {
      state = state.copyWith(
        activeSession: active,
        isTracking: true,
        isInitialized: true,
        totalDistance: active.distanceMeters,
        durationSeconds: DateTime.now().difference(active.startTime).inSeconds,
      );
      _startTracking();
    } else {
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<void> startWalking() async {
    state = state.copyWith(isLoading: true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location services are disabled. Please enable them.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            error: 'Location permission denied',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Location permission permanently denied. Please enable in app settings.',
        );
        await Geolocator.openAppSettings();
        return;
      }

      final session = await _repository.startSession();
      state = state.copyWith(
        activeSession: session,
        isTracking: true,
        isLoading: false,
        totalDistance: 0.0,
        durationSeconds: 0,
      );
      _startTracking();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start walking: $e',
      );
    }
  }

  void _startTracking() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(durationSeconds: state.durationSeconds + 1);
    });

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            _onPositionUpdate(position);
          },
        );
  }

  void _onPositionUpdate(Position position) {
    if (state.activeSession == null) return;

    double addedDistance = 0.0;
    if (_lastPosition != null) {
      addedDistance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
    }
    _lastPosition = position;

    final routePoint = RoutePoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      altitude: position.altitude,
      speed: position.speed,
    );

    _repository.addRoutePoint(state.activeSession!.id!, routePoint);

    state = state.copyWith(
      currentPosition: position,
      totalDistance: state.totalDistance + addedDistance,
    );
  }

  Future<WalkingSessionModel?> stopWalking() async {
    _positionSubscription?.cancel();
    _durationTimer?.cancel();
    _positionSubscription = null;
    _durationTimer = null;
    _lastPosition = null;

    if (state.activeSession == null) return null;

    final session = await _repository.endSession(
      state.activeSession!.id!,
      distance: state.totalDistance,
    );

    state = WalkingState();
    return session;
  }

  List<WalkingSessionModel> getHistory() {
    if (!_repository.isInitialized) return [];
    return _repository.getCompletedSessions();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}
