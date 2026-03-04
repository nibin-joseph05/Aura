// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLogModelAdapter extends TypeAdapter<ActivityLogModel> {
  @override
  final int typeId = 2;

  @override
  ActivityLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLogModel(
      id: fields[0] as String,
      userActivityId: fields[1] as String,
      completedAt: fields[2] as DateTime,
      metrics: (fields[3] as Map).cast<String, String>(),
      isSynced: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLogModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userActivityId)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.metrics)
      ..writeByte(4)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
