import 'package:hive/hive.dart';

part 'walking_session_model.g.dart';

@HiveType(typeId: 10)
class WalkingSessionModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? remoteId;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  double distanceMeters;

  @HiveField(5)
  int durationSeconds;

  @HiveField(6)
  int stepsCount;

  @HiveField(7)
  double caloriesBurned;

  @HiveField(8)
  bool isActive;

  @HiveField(9)
  List<RoutePoint> routePoints;

  @HiveField(10)
  bool isSynced;

  WalkingSessionModel({
    this.id,
    this.remoteId,
    required this.startTime,
    this.endTime,
    this.distanceMeters = 0.0,
    this.durationSeconds = 0,
    this.stepsCount = 0,
    this.caloriesBurned = 0.0,
    this.isActive = true,
    List<RoutePoint>? routePoints,
    this.isSynced = false,
  }) : routePoints = routePoints ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remoteId': remoteId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
      'stepsCount': stepsCount,
      'caloriesBurned': caloriesBurned,
      'isActive': isActive,
      'routePoints': routePoints.map((p) => p.toJson()).toList(),
      'isSynced': isSynced,
    };
  }

  factory WalkingSessionModel.fromJson(Map<String, dynamic> json) {
    return WalkingSessionModel(
      id: json['id'] as String?,
      remoteId: json['remoteId'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      stepsCount: json['stepsCount'] as int? ?? 0,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? false,
      routePoints:
          (json['routePoints'] as List?)
              ?.map((p) => RoutePoint.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
}

@HiveType(typeId: 11)
class RoutePoint {
  @HiveField(0)
  double latitude;

  @HiveField(1)
  double longitude;

  @HiveField(2)
  int timestamp;

  @HiveField(3)
  double? altitude;

  @HiveField(4)
  double? speed;

  RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.speed,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'altitude': altitude,
      'speed': speed,
    };
  }

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }
}
