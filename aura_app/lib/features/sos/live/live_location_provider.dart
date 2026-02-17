import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';

class LiveLocationState {
  final String? sessionId;
  final bool isSharing;
  final int? durationMinutes;
  final DateTime? startedAt;
  final List<Map<String, double>> points;
  final String? error;

  const LiveLocationState({
    this.sessionId,
    this.isSharing = false,
    this.durationMinutes,
    this.startedAt,
    this.points = const [],
    this.error,
  });

  LiveLocationState copyWith({
    String? sessionId,
    bool? isSharing,
    int? durationMinutes,
    DateTime? startedAt,
    List<Map<String, double>>? points,
    String? error,
  }) {
    return LiveLocationState(
      sessionId: sessionId ?? this.sessionId,
      isSharing: isSharing ?? this.isSharing,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startedAt: startedAt ?? this.startedAt,
      points: points ?? this.points,
      error: error,
    );
  }

  int get remainingSeconds {
    if (startedAt == null || durationMinutes == null) return 0;
    final elapsed = DateTime.now().difference(startedAt!).inSeconds;
    final total = durationMinutes! * 60;
    return (total - elapsed).clamp(0, total);
  }
}

class LiveLocationNotifier extends StateNotifier<LiveLocationState> {
  final String _userId;
  Timer? _locationTimer;
  Timer? _countdownTimer;
  StreamSubscription? _positionSubscription;

  LiveLocationNotifier(this._userId) : super(const LiveLocationState());

  Future<void> startSharing({
    required int durationMinutes,
    required List<String> contactIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/user/sos/live/start'),
        headers: {'Content-Type': 'application/json', 'X-User-Id': _userId},
        body: jsonEncode({
          'durationMinutes': durationMinutes == 0 ? null : durationMinutes,
          'allowedContactIds': contactIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(
          sessionId: data['id'],
          isSharing: true,
          durationMinutes: durationMinutes == 0 ? null : durationMinutes,
          startedAt: DateTime.now(),
          error: null,
        );
        _startLocationTracking();
        if (durationMinutes > 0) {
          _startCountdown(durationMinutes);
        }
      } else {
        state = state.copyWith(error: 'Failed to start sharing');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> stopSharing() async {
    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/user/sos/live/stop'),
        headers: {'Content-Type': 'application/json', 'X-User-Id': _userId},
      );
    } catch (_) {}

    _locationTimer?.cancel();
    _countdownTimer?.cancel();
    _positionSubscription?.cancel();
    state = const LiveLocationState();
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        final newPoints = List<Map<String, double>>.from(state.points)
          ..add({'lat': position.latitude, 'lng': position.longitude});
        state = state.copyWith(points: newPoints);

        if (state.sessionId != null) {
          await http.post(
            Uri.parse(
              '${AppConfig.baseUrl}/api/user/sos/live/${state.sessionId}/location',
            ),
            headers: {'Content-Type': 'application/json', 'X-User-Id': _userId},
            body: jsonEncode({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'altitude': position.altitude,
              'speed': position.speed,
            }),
          );
        }
      } catch (_) {}
    });
  }

  void _startCountdown(int durationMinutes) {
    _countdownTimer = Timer(
      Duration(minutes: durationMinutes),
      () => stopSharing(),
    );
  }

  void addReceivedPoint(double lat, double lng) {
    final newPoints = List<Map<String, double>>.from(state.points)
      ..add({'lat': lat, 'lng': lng});
    state = state.copyWith(points: newPoints);
  }

  Future<void> checkActiveSession() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/user/sos/live/active'),
        headers: {'X-User-Id': _userId},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(
          sessionId: data['id'],
          isSharing: data['active'] == true,
          startedAt: DateTime.tryParse(data['startedAt'] ?? ''),
          durationMinutes: data['durationMinutes'],
        );
        if (state.isSharing) {
          _startLocationTracking();
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _countdownTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}

final liveLocationProvider =
    StateNotifierProvider.family<
      LiveLocationNotifier,
      LiveLocationState,
      String
    >((ref, userId) => LiveLocationNotifier(userId));
