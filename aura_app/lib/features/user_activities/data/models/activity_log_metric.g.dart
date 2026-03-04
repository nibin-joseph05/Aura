// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_metric.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLogMetricAdapter extends TypeAdapter<ActivityLogMetric> {
  @override
  final int typeId = 16;

  @override
  ActivityLogMetric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLogMetric(
      id: fields[0] as String?,
      metricId: fields[1] as String,
      metricName: fields[2] as String,
      metricUnit: fields[3] as String,
      metricType: fields[4] as String,
      metricValue: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLogMetric obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.metricId)
      ..writeByte(2)
      ..write(obj.metricName)
      ..writeByte(3)
      ..write(obj.metricUnit)
      ..writeByte(4)
      ..write(obj.metricType)
      ..writeByte(5)
      ..write(obj.metricValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogMetricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
