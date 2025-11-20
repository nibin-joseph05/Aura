// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      uid: fields[0] as String,
      phone: fields[1] as String?,
      email: fields[2] as String?,
      phoneVerified: fields[3] as bool,
      emailVerified: fields[4] as bool,
      signupMethod: fields[5] as String,
      googleLinked: fields[6] as bool,
      emailPasswordLinked: fields[7] as bool,
      name: fields[8] as String?,
      username: fields[9] as String?,
      profileImageUrl: fields[10] as String?,
      gender: fields[11] as String?,
      dob: fields[12] as String?,
      profileCompleted: fields[13] as bool,
      createdAt: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneVerified)
      ..writeByte(4)
      ..write(obj.emailVerified)
      ..writeByte(5)
      ..write(obj.signupMethod)
      ..writeByte(6)
      ..write(obj.googleLinked)
      ..writeByte(7)
      ..write(obj.emailPasswordLinked)
      ..writeByte(8)
      ..write(obj.name)
      ..writeByte(9)
      ..write(obj.username)
      ..writeByte(10)
      ..write(obj.profileImageUrl)
      ..writeByte(11)
      ..write(obj.gender)
      ..writeByte(12)
      ..write(obj.dob)
      ..writeByte(13)
      ..write(obj.profileCompleted)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
