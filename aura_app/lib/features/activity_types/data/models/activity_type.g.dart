// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final int typeId = 51;

  @override
  ActivityType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityType(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      categoryName: fields[2] as String,
      name: fields[3] as String,
      description: fields[4] as String?,
      allowAlarm: fields[5] as bool,
      allowNotes: fields[6] as bool,
      requiresDuration: fields[7] as bool,
      requiresDistance: fields[8] as bool,
      requiresCalories: fields[9] as bool,
      isGymActivity: fields[10] as bool,
      icon: fields[11] as String?,
      isActive: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.categoryName)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.allowAlarm)
      ..writeByte(6)
      ..write(obj.allowNotes)
      ..writeByte(7)
      ..write(obj.requiresDuration)
      ..writeByte(8)
      ..write(obj.requiresDistance)
      ..writeByte(9)
      ..write(obj.requiresCalories)
      ..writeByte(10)
      ..write(obj.isGymActivity)
      ..writeByte(11)
      ..write(obj.icon)
      ..writeByte(12)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
