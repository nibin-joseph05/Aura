// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_metric.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityMetricAdapter extends TypeAdapter<ActivityMetric> {
  @override
  final int typeId = 53;

  @override
  ActivityMetric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityMetric(
      id: fields[0] as String?,
      name: fields[1] as String,
      unit: fields[2] as String,
      metricType: fields[3] as MetricType,
      isRequired: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityMetric obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.metricType)
      ..writeByte(4)
      ..write(obj.isRequired);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityMetricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MetricTypeAdapter extends TypeAdapter<MetricType> {
  @override
  final int typeId = 52;

  @override
  MetricType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MetricType.integer;
      case 1:
        return MetricType.decimal;
      case 2:
        return MetricType.boolean;
      case 3:
        return MetricType.timeMinutes;
      case 4:
        return MetricType.text;
      default:
        return MetricType.integer;
    }
  }

  @override
  void write(BinaryWriter writer, MetricType obj) {
    switch (obj) {
      case MetricType.integer:
        writer.writeByte(0);
        break;
      case MetricType.decimal:
        writer.writeByte(1);
        break;
      case MetricType.boolean:
        writer.writeByte(2);
        break;
      case MetricType.timeMinutes:
        writer.writeByte(3);
        break;
      case MetricType.text:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
