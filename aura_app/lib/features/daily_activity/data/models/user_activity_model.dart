import 'package:hive/hive.dart';
import '../../../../features/activity_types/data/models/activity_metric.dart';

part 'user_activity_model.g.dart';

@HiveType(typeId: 1)
class UserActivityModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String activityType;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final DateTime? completedAt;

  @HiveField(6)
  final bool isSynced;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final int? intervalMinutes;

  @HiveField(9)
  final int targetCompletions;

  @HiveField(10)
  final List<DateTime> completionTimes;

  @HiveField(11)
  final bool isAlarmEnabled;

  @HiveField(12)
  final bool isPushEnabled;

  @HiveField(13)
  final String categoryName;

  @HiveField(14)
  final String activityTypeIcon;

  @HiveField(15)
  final bool isGymActivity;

  @HiveField(16)
  final String activityTypeId;

  @HiveField(17, defaultValue: [])
  final List<ActivityMetric> metrics;

  @HiveField(18, defaultValue: {})
  final Map<String, String> metricLogs;

  UserActivityModel({
    required this.id,
    required this.date,
    required this.activityType,
    required this.title,
    this.description,
    this.completedAt,
    this.isSynced = false,
    required this.createdAt,
    this.intervalMinutes,
    this.targetCompletions = 1,
    this.completionTimes = const [],
    this.isAlarmEnabled = false,
    this.isPushEnabled = false,
    this.categoryName = '',
    this.activityTypeIcon = '',
    this.isGymActivity = false,
    required this.activityTypeId,
    this.metrics = const [],
    this.metricLogs = const {},
  });

  bool get isRepeating => targetCompletions > 1;
  bool get isFullyCompleted => completionTimes.length >= targetCompletions;
  int get completionsRemaining => targetCompletions - completionTimes.length;
  double get completionProgress =>
      targetCompletions > 0 ? completionTimes.length / targetCompletions : 0.0;

  DateTime? get nextDueAt {
    if (intervalMinutes == null || isFullyCompleted) return null;
    if (completionTimes.isEmpty) {
      return DateTime(date.year, date.month, date.day);
    }
    return completionTimes.last.add(Duration(minutes: intervalMinutes!));
  }

  bool get isDueNow {
    final next = nextDueAt;
    if (next == null) return false;
    return DateTime.now().isAfter(next);
  }

  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      activityType: json['activityType'],
      title: json['title'],
      description: json['description'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      isSynced: true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      intervalMinutes: json['intervalMinutes'],
      targetCompletions: json['targetCompletions'] ?? 1,
      completionTimes:
          (json['completionTimes'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      isAlarmEnabled: json['isAlarmEnabled'] ?? false,
      isPushEnabled: json['isPushEnabled'] ?? false,
      categoryName: json['categoryName'] ?? '',
      activityTypeIcon: json['activityTypeIcon'] ?? '',
      isGymActivity: json['isGymActivity'] ?? false,
      activityTypeId: json['activityTypeId'] ?? '',
      metrics: json['metrics'] != null
          ? (json['metrics'] as List)
                .map((m) => ActivityMetric.fromJson(m))
                .toList()
          : [],
      metricLogs: json['metricLogs'] != null
          ? Map<String, String>.from(json['metricLogs'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'activityType': activityType,
      'title': title,
      'description': description,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'intervalMinutes': intervalMinutes,
      'targetCompletions': targetCompletions,
      'completionTimes': completionTimes
          .map((t) => t.toIso8601String())
          .toList(),
      'isAlarmEnabled': isAlarmEnabled,
      'isPushEnabled': isPushEnabled,
      'categoryName': categoryName,
      'activityTypeIcon': activityTypeIcon,
      'isGymActivity': isGymActivity,
      'activityTypeId': activityTypeId,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'metricLogs': metricLogs,
    };
  }

  UserActivityModel copyWith({
    String? id,
    DateTime? date,
    String? activityType,
    String? title,
    String? description,
    DateTime? completedAt,
    bool? isSynced,
    DateTime? createdAt,
    int? intervalMinutes,
    int? targetCompletions,
    List<DateTime>? completionTimes,
    bool? isAlarmEnabled,
    bool? isPushEnabled,
    String? categoryName,
    String? activityTypeIcon,
    bool? isGymActivity,
    String? activityTypeId,
    List<ActivityMetric>? metrics,
    Map<String, String>? metricLogs,
  }) {
    return UserActivityModel(
      id: id ?? this.id,
      date: date ?? this.date,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      description: description ?? this.description,
      completedAt: completedAt ?? this.completedAt,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      targetCompletions: targetCompletions ?? this.targetCompletions,
      completionTimes: completionTimes ?? this.completionTimes,
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
      isPushEnabled: isPushEnabled ?? this.isPushEnabled,
      categoryName: categoryName ?? this.categoryName,
      activityTypeIcon: activityTypeIcon ?? this.activityTypeIcon,
      isGymActivity: isGymActivity ?? this.isGymActivity,
      activityTypeId: activityTypeId ?? this.activityTypeId,
      metrics: metrics ?? this.metrics,
      metricLogs: metricLogs ?? this.metricLogs,
    );
  }
}
