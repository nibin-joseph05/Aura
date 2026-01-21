import 'package:hive/hive.dart';

part 'activity_status.g.dart';

@HiveType(typeId: 14)
enum ActivityStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  completed,

  @HiveField(3)
  skipped,

  @HiveField(4)
  missed,
}

extension ActivityStatusExtension on ActivityStatus {
  String get displayName {
    switch (this) {
      case ActivityStatus.pending:
        return 'Pending';
      case ActivityStatus.inProgress:
        return 'In Progress';
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.skipped:
        return 'Skipped';
      case ActivityStatus.missed:
        return 'Missed';
    }
  }

  static ActivityStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'IN_PROGRESS':
        return ActivityStatus.inProgress;
      case 'COMPLETED':
        return ActivityStatus.completed;
      case 'SKIPPED':
        return ActivityStatus.skipped;
      case 'MISSED':
        return ActivityStatus.missed;
      default:
        return ActivityStatus.pending;
    }
  }
}
