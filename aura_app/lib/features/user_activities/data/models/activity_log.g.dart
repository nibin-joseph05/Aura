// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLogAdapter extends TypeAdapter<ActivityLog> {
  @override
  final int typeId = 15;

  @override
  ActivityLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLog(
      id: fields[0] as String,
      userActivityId: fields[1] as String,
      activityTypeName: fields[2] as String,
      activityTypeIcon: fields[3] as String?,
      customTitle: fields[4] as String?,
      logDate: fields[5] as DateTime,
      status: fields[6] as ActivityStatus,
      metrics: (fields[7] as List?)?.cast<ActivityLogMetric>(),
      note: fields[8] as String?,
      completedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userActivityId)
      ..writeByte(2)
      ..write(obj.activityTypeName)
      ..writeByte(3)
      ..write(obj.activityTypeIcon)
      ..writeByte(4)
      ..write(obj.customTitle)
      ..writeByte(5)
      ..write(obj.logDate)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.metrics)
      ..writeByte(8)
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
