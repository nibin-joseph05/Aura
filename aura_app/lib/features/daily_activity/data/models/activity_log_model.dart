import 'package:hive/hive.dart';

part 'activity_log_model.g.dart';

@HiveType(typeId: 2)
class ActivityLogModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userActivityId;

  @HiveField(2)
  final DateTime completedAt;

  @HiveField(3)
  final Map<String, String> metrics;

  @HiveField(4)
  final bool isSynced;

  ActivityLogModel({
    required this.id,
    required this.userActivityId,
    required this.completedAt,
    this.metrics = const {},
    this.isSynced = false,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'].toString(),
      userActivityId: json['userActivityId'].toString(),
      completedAt: DateTime.parse(json['completedAt']),
      metrics: json['metrics'] != null
          ? Map<String, String>.from(json['metrics'])
          : {},
      isSynced: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userActivityId': userActivityId,
      'completedAt': completedAt.toIso8601String(),
      'metrics': metrics,
    };
  }

  ActivityLogModel copyWith({
    String? id,
    String? userActivityId,
    DateTime? completedAt,
    Map<String, String>? metrics,
    bool? isSynced,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      userActivityId: userActivityId ?? this.userActivityId,
      completedAt: completedAt ?? this.completedAt,
      metrics: metrics ?? this.metrics,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
