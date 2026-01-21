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
      actualDuration: fields[7] as int?,
      distanceKm: fields[8] as double?,
      caloriesBurned: fields[9] as int?,
      note: fields[10] as String?,
      completedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLog obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.actualDuration)
      ..writeByte(8)
      ..write(obj.distanceKm)
      ..writeByte(9)
      ..write(obj.caloriesBurned)
      ..writeByte(10)
      ..write(obj.note)
      ..writeByte(11)
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
