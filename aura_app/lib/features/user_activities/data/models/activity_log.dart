import 'package:hive/hive.dart';
import 'activity_status.dart';

part 'activity_log.g.dart';

@HiveType(typeId: 15)
class ActivityLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userActivityId;

  @HiveField(2)
  final String activityTypeName;

  @HiveField(3)
  final String? activityTypeIcon;

  @HiveField(4)
  final String? customTitle;

  @HiveField(5)
  final DateTime logDate;

  @HiveField(6)
  final ActivityStatus status;

  @HiveField(7)
  final int? actualDuration;

  @HiveField(8)
  final double? distanceKm;

  @HiveField(9)
  final int? caloriesBurned;

  @HiveField(10)
  final String? note;

  @HiveField(11)
  final DateTime? completedAt;

  ActivityLog({
    required this.id,
    required this.userActivityId,
    required this.activityTypeName,
    this.activityTypeIcon,
    this.customTitle,
    required this.logDate,
    this.status = ActivityStatus.pending,
    this.actualDuration,
    this.distanceKm,
    this.caloriesBurned,
    this.note,
    this.completedAt,
  });

  String get displayName =>
      customTitle?.isNotEmpty == true ? customTitle! : activityTypeName;

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      userActivityId: json['userActivityId'] as String,
      activityTypeName: json['activityTypeName'] as String? ?? '',
      activityTypeIcon: json['activityTypeIcon'] as String?,
      customTitle: json['customTitle'] as String?,
      logDate: DateTime.parse(json['logDate'] as String),
      status: ActivityStatusExtension.fromString(
        json['status'] as String? ?? 'PENDING',
      ),
      actualDuration: json['actualDuration'] as int?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      caloriesBurned: json['caloriesBurned'] as int?,
      note: json['note'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userActivityId': userActivityId,
      'activityTypeName': activityTypeName,
      'activityTypeIcon': activityTypeIcon,
      'customTitle': customTitle,
      'logDate': logDate.toIso8601String().split('T').first,
      'status': status.name.toUpperCase(),
      'actualDuration': actualDuration,
      'distanceKm': distanceKm,
      'caloriesBurned': caloriesBurned,
      'note': note,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  ActivityLog copyWith({
    ActivityStatus? status,
    int? actualDuration,
    double? distanceKm,
    int? caloriesBurned,
    String? note,
    DateTime? completedAt,
  }) {
    return ActivityLog(
      id: id,
      userActivityId: userActivityId,
      activityTypeName: activityTypeName,
      activityTypeIcon: activityTypeIcon,
      customTitle: customTitle,
      logDate: logDate,
      status: status ?? this.status,
      actualDuration: actualDuration ?? this.actualDuration,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      note: note ?? this.note,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
