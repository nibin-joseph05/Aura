// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellness_update.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WellnessUpdateAdapter extends TypeAdapter<WellnessUpdate> {
  @override
  final int typeId = 21;

  @override
  WellnessUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WellnessUpdate(
      id: fields[0] as String,
      userId: fields[1] as String,
      userName: fields[2] as String?,
      userProfileImage: fields[3] as String?,
      content: fields[4] as String,
      imageUrl: fields[5] as String?,
      category: fields[6] as WellnessCategory,
      likesCount: fields[7] as int,
      likedByCurrentUser: fields[8] as bool,
      isApproved: fields[9] as bool,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WellnessUpdate obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.userProfileImage)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.likesCount)
      ..writeByte(8)
      ..write(obj.likedByCurrentUser)
      ..writeByte(9)
      ..write(obj.isApproved)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WellnessUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
