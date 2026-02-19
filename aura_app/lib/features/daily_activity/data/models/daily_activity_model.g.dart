// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_activity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyActivityModelAdapter extends TypeAdapter<DailyActivityModel> {
  @override
  final int typeId = 1;

  @override
  DailyActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyActivityModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      activityType: fields[2] as String,
      title: fields[3] as String,
      description: fields[4] as String?,
      completedAt: fields[5] as DateTime?,
      isSynced: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      intervalMinutes: fields[8] as int?,
      targetCompletions: (fields[9] as int?) ?? 1,
      completionTimes: (fields[10] as List?)?.cast<DateTime>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, DailyActivityModel obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.completionTimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
