import 'package:hive/hive.dart';

part 'activity_log_metric.g.dart';

@HiveType(typeId: 16)
class ActivityLogMetric extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String metricId;

  @HiveField(2)
  final String metricName;

  @HiveField(3)
  final String metricUnit;

  @HiveField(4)
  final String metricType;

  @HiveField(5)
  final String metricValue;

  ActivityLogMetric({
    this.id,
    required this.metricId,
    required this.metricName,
    required this.metricUnit,
    required this.metricType,
    required this.metricValue,
  });

  factory ActivityLogMetric.fromJson(Map<String, dynamic> json) {
    return ActivityLogMetric(
      id: json['id'] as String?,
      metricId: json['metricId'] as String,
      metricName: json['metricName'] as String,
      metricUnit: json['metricUnit'] as String? ?? '',
      metricType: json['metricType'] as String,
      metricValue: json['metricValue'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metricId': metricId,
      'metricName': metricName,
      'metricUnit': metricUnit,
      'metricType': metricType,
      'metricValue': metricValue,
    };
  }
}
