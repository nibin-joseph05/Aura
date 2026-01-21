import 'package:hive/hive.dart';

part 'wellness_category.g.dart';

@HiveType(typeId: 20)
enum WellnessCategory {
  @HiveField(0)
  progress,
  @HiveField(1)
  motivation,
  @HiveField(2)
  tip,
  @HiveField(3)
  achievement,
  @HiveField(4)
  general;

  String get displayName {
    switch (this) {
      case WellnessCategory.progress:
        return 'Progress';
      case WellnessCategory.motivation:
        return 'Motivation';
      case WellnessCategory.tip:
        return 'Tip';
      case WellnessCategory.achievement:
        return 'Achievement';
      case WellnessCategory.general:
        return 'General';
    }
  }

  String get emoji {
    switch (this) {
      case WellnessCategory.progress:
        return '📈';
      case WellnessCategory.motivation:
        return '💪';
      case WellnessCategory.tip:
        return '💡';
      case WellnessCategory.achievement:
        return '🏆';
      case WellnessCategory.general:
        return '✨';
    }
  }

  static WellnessCategory fromString(String value) {
    return WellnessCategory.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => WellnessCategory.general,
    );
  }
}
