import 'package:hive/hive.dart';
import 'repeat_type.dart';

part 'user_activity.g.dart';

@HiveType(typeId: 13)
class UserActivity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String activityTypeId;

  @HiveField(3)
  final String activityTypeName;

  @HiveField(4)
  final String? activityTypeIcon;

  @HiveField(5)
  final String categoryName;

  @HiveField(6)
  final bool isGymActivity;

  @HiveField(7)
  final String? customTitle;

  @HiveField(8)
  final String? scheduledTime;

  @HiveField(9)
  final RepeatType repeatType;

  @HiveField(10)
  final String? repeatDays;

  @HiveField(11)
  final DateTime startDate;

  @HiveField(12)
  final DateTime? endDate;

  @HiveField(13)
  final bool isActive;

  UserActivity({
    required this.id,
    required this.userId,
    required this.activityTypeId,
    required this.activityTypeName,
    this.activityTypeIcon,
    required this.categoryName,
    this.isGymActivity = false,
    this.customTitle,
    this.scheduledTime,
    this.repeatType = RepeatType.none,
    this.repeatDays,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  String get displayName =>
      customTitle?.isNotEmpty == true ? customTitle! : activityTypeName;

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      activityTypeId: json['activityTypeId'] as String,
      activityTypeName: json['activityTypeName'] as String? ?? '',
      activityTypeIcon: json['activityTypeIcon'] as String?,
      categoryName: json['categoryName'] as String? ?? '',
      isGymActivity: json['isGymActivity'] as bool? ?? false,
      customTitle: json['customTitle'] as String?,
      scheduledTime: json['scheduledTime'] as String?,
      repeatType: RepeatTypeExtension.fromString(
        json['repeatType'] as String? ?? 'NONE',
      ),
      repeatDays: json['repeatDays'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'activityTypeId': activityTypeId,
      'activityTypeName': activityTypeName,
      'activityTypeIcon': activityTypeIcon,
      'categoryName': categoryName,
      'isGymActivity': isGymActivity,
      'customTitle': customTitle,
      'scheduledTime': scheduledTime,
      'repeatType': repeatType.name.toUpperCase(),
      'repeatDays': repeatDays,
      'startDate': startDate.toIso8601String().split('T').first,
      'endDate': endDate?.toIso8601String().split('T').first,
      'isActive': isActive,
    };
  }

  UserActivity copyWith({
    String? customTitle,
    String? scheduledTime,
    RepeatType? repeatType,
    String? repeatDays,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return UserActivity(
      id: id,
      userId: userId,
      activityTypeId: activityTypeId,
      activityTypeName: activityTypeName,
      activityTypeIcon: activityTypeIcon,
      categoryName: categoryName,
      isGymActivity: isGymActivity,
      customTitle: customTitle ?? this.customTitle,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
