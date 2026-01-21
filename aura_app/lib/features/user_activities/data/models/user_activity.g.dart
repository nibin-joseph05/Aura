// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserActivityAdapter extends TypeAdapter<UserActivity> {
  @override
  final int typeId = 13;

  @override
  UserActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserActivity(
      id: fields[0] as String,
      userId: fields[1] as String,
      activityTypeId: fields[2] as String,
      activityTypeName: fields[3] as String,
      activityTypeIcon: fields[4] as String?,
      categoryName: fields[5] as String,
      isGymActivity: fields[6] as bool,
      customTitle: fields[7] as String?,
      scheduledTime: fields[8] as String?,
      repeatType: fields[9] as RepeatType,
      repeatDays: fields[10] as String?,
      startDate: fields[11] as DateTime,
      endDate: fields[12] as DateTime?,
      isActive: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserActivity obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.activityTypeId)
      ..writeByte(3)
      ..write(obj.activityTypeName)
      ..writeByte(4)
      ..write(obj.activityTypeIcon)
      ..writeByte(5)
      ..write(obj.categoryName)
      ..writeByte(6)
      ..write(obj.isGymActivity)
      ..writeByte(7)
      ..write(obj.customTitle)
      ..writeByte(8)
      ..write(obj.scheduledTime)
      ..writeByte(9)
      ..write(obj.repeatType)
      ..writeByte(10)
      ..write(obj.repeatDays)
      ..writeByte(11)
      ..write(obj.startDate)
      ..writeByte(12)
      ..write(obj.endDate)
      ..writeByte(13)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
