import 'package:hive/hive.dart';

part 'activity_type.g.dart';

@HiveType(typeId: 11)
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
  final bool requiresDuration;

  @HiveField(8)
  final bool requiresDistance;

  @HiveField(9)
  final bool requiresCalories;

  @HiveField(10)
  final bool isGymActivity;

  @HiveField(11)
  final String? icon;

  @HiveField(12)
  final bool isActive;

  ActivityType({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.description,
    this.allowAlarm = false,
    this.allowNotes = true,
    this.requiresDuration = false,
    this.requiresDistance = false,
    this.requiresCalories = false,
    this.isGymActivity = false,
    this.icon,
    this.isActive = true,
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
      requiresDuration: json['requiresDuration'] as bool? ?? false,
      requiresDistance: json['requiresDistance'] as bool? ?? false,
      requiresCalories: json['requiresCalories'] as bool? ?? false,
      isGymActivity: json['isGymActivity'] as bool? ?? false,
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool? ?? true,
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
      'requiresDuration': requiresDuration,
      'requiresDistance': requiresDistance,
      'requiresCalories': requiresCalories,
      'isGymActivity': isGymActivity,
      'icon': icon,
      'isActive': isActive,
    };
  }
}
