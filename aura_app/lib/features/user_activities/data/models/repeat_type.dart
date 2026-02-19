import 'package:hive/hive.dart';

part 'repeat_type.g.dart';

@HiveType(typeId: 60)
enum RepeatType {
  @HiveField(0)
  none,

  @HiveField(1)
  daily,

  @HiveField(2)
  weekly,

  @HiveField(3)
  monthly,

  @HiveField(4)
  custom,
}

extension RepeatTypeExtension on RepeatType {
  String get displayName {
    switch (this) {
      case RepeatType.none:
        return 'One-time';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.custom:
        return 'Custom';
    }
  }

  static RepeatType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DAILY':
        return RepeatType.daily;
      case 'WEEKLY':
        return RepeatType.weekly;
      case 'MONTHLY':
        return RepeatType.monthly;
      case 'CUSTOM':
        return RepeatType.custom;
      default:
        return RepeatType.none;
    }
  }
}
