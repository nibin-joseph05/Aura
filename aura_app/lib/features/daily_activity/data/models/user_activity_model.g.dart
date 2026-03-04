// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_activity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserActivityModelAdapter extends TypeAdapter<UserActivityModel> {
  @override
  final int typeId = 1;

  @override
  UserActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserActivityModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      activityType: fields[2] as String,
      title: fields[3] as String,
      description: fields[4] as String?,
      completedAt: fields[5] as DateTime?,
      isSynced: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      intervalMinutes: fields[8] as int?,
      targetCompletions: fields[9] as int,
      completionTimes: (fields[10] as List).cast<DateTime>(),
      isAlarmEnabled: fields[11] as bool,
      isPushEnabled: fields[12] as bool,
      categoryName: fields[13] as String,
      activityTypeIcon: fields[14] as String,
      isGymActivity: fields[15] as bool,
      activityTypeId: fields[16] as String,
      metrics:
          fields[17] == null ? [] : (fields[17] as List).cast<ActivityMetric>(),
      metricLogs:
          fields[18] == null ? {} : (fields[18] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserActivityModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.activityType)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.isSynced)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.intervalMinutes)
      ..writeByte(9)
      ..write(obj.targetCompletions)
      ..writeByte(10)
      ..write(obj.completionTimes)
      ..writeByte(11)
      ..write(obj.isAlarmEnabled)
      ..writeByte(12)
      ..write(obj.isPushEnabled)
      ..writeByte(13)
      ..write(obj.categoryName)
      ..writeByte(14)
      ..write(obj.activityTypeIcon)
      ..writeByte(15)
      ..write(obj.isGymActivity)
      ..writeByte(16)
      ..write(obj.activityTypeId)
      ..writeByte(17)
      ..write(obj.metrics)
      ..writeByte(18)
      ..write(obj.metricLogs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
