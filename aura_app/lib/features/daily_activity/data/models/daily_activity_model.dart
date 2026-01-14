import 'package:hive/hive.dart';

part 'daily_activity_model.g.dart';

@HiveType(typeId: 1)
class DailyActivityModel {
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

  DailyActivityModel({
    required this.id,
    required this.date,
    required this.activityType,
    required this.title,
    this.description,
    this.completedAt,
    this.isSynced = false,
    required this.createdAt,
  });

  factory DailyActivityModel.fromJson(Map<String, dynamic> json) {
    return DailyActivityModel(
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
    };
  }

  DailyActivityModel copyWith({
    String? id,
    DateTime? date,
    String? activityType,
    String? title,
    String? description,
    DateTime? completedAt,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return DailyActivityModel(
      id: id ?? this.id,
      date: date ?? this.date,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      description: description ?? this.description,
      completedAt: completedAt ?? this.completedAt,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
