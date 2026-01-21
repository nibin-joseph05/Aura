// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrustedContactAdapter extends TypeAdapter<TrustedContact> {
  @override
  final int typeId = 10;

  @override
  TrustedContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrustedContact(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      email: fields[3] as String?,
      relationship: fields[4] as String?,
      priority: fields[5] as int,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TrustedContact obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.relationship)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrustedContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
