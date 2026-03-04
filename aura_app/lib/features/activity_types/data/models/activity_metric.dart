import 'package:hive/hive.dart';

part 'activity_metric.g.dart';

@HiveType(typeId: 52)
enum MetricType {
  @HiveField(0)
  integer,
  @HiveField(1)
  decimal,
  @HiveField(2)
  boolean,
  @HiveField(3)
  timeMinutes,
  @HiveField(4)
  text,
}

@HiveType(typeId: 53)
class ActivityMetric extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final MetricType metricType;

  @HiveField(4)
  final bool isRequired;

  ActivityMetric({
    this.id,
    required this.name,
    required this.unit,
    required this.metricType,
    required this.isRequired,
  });

  factory ActivityMetric.fromJson(Map<String, dynamic> json) {
    return ActivityMetric(
      id: json['id'] as String?,
      name: json['name'] as String,
      unit: json['unit'] as String? ?? '',
      metricType: _parseMetricType(json['metricType'] as String?),
      isRequired: json['isRequired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'metricType': _formatMetricType(metricType),
      'isRequired': isRequired,
    };
  }

  static MetricType _parseMetricType(String? typeStr) {
    if (typeStr == null) return MetricType.integer;
    switch (typeStr.toUpperCase()) {
      case 'DECIMAL':
        return MetricType.decimal;
      case 'BOOLEAN':
        return MetricType.boolean;
      case 'TIME_MINUTES':
        return MetricType.timeMinutes;
      case 'TEXT':
        return MetricType.text;
      case 'INTEGER':
      default:
        return MetricType.integer;
    }
  }

  static String _formatMetricType(MetricType type) {
    switch (type) {
      case MetricType.integer:
        return 'INTEGER';
      case MetricType.decimal:
        return 'DECIMAL';
      case MetricType.boolean:
        return 'BOOLEAN';
      case MetricType.timeMinutes:
        return 'TIME_MINUTES';
      case MetricType.text:
        return 'TEXT';
    }
  }
}
