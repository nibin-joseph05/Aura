import 'package:hive/hive.dart';
import 'activity_metric.dart';

part 'activity_type.g.dart';

@HiveType(typeId: 51)
class ActivityType extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String categoryName;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final bool allowAlarm;

  @HiveField(6)
  final bool allowNotes;

  @HiveField(7)
  final List<ActivityMetric> metrics;

  @HiveField(8)
  final bool isGymActivity;

  @HiveField(9)
  final String icon;

  @HiveField(10)
  final bool isActive;

  @HiveField(11)
  final String color;

  @HiveField(12)
  final int? defaultIntervalMinutes;

  @HiveField(13)
  final int? defaultTargetCompletions;

  ActivityType({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.description,
    this.allowAlarm = false,
    this.allowNotes = true,
    this.metrics = const [],
    this.isGymActivity = false,
    this.icon = '',
    this.isActive = true,
    this.color = '#7C3AED',
    this.defaultIntervalMinutes,
    this.defaultTargetCompletions,
  });

  factory ActivityType.fromJson(Map<String, dynamic> json) {
    return ActivityType(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String?,
      allowAlarm: json['allowAlarm'] as bool? ?? false,
      allowNotes: json['allowNotes'] as bool? ?? true,
      metrics: json['metrics'] != null
          ? (json['metrics'] as List)
                .map((m) => ActivityMetric.fromJson(m))
                .toList()
          : [],
      isGymActivity: json['isGymActivity'] as bool? ?? false,
      icon: (json['icon'] as String? ?? '').trim(),
      isActive: json['isActive'] as bool? ?? true,
      color: json['color'] as String? ?? '#7C3AED',
      defaultIntervalMinutes: json['defaultIntervalMinutes'] as int?,
      defaultTargetCompletions: json['defaultTargetCompletions'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'name': name,
      'description': description,
      'allowAlarm': allowAlarm,
      'allowNotes': allowNotes,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'isGymActivity': isGymActivity,
      'icon': icon,
      'isActive': isActive,
      'color': color,
      if (defaultIntervalMinutes != null)
        'defaultIntervalMinutes': defaultIntervalMinutes,
      if (defaultTargetCompletions != null)
        'defaultTargetCompletions': defaultTargetCompletions,
    };
  }
}
