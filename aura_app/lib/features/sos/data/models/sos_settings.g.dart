// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sos_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SOSSettingsAdapter extends TypeAdapter<SOSSettings> {
  @override
  final int typeId = 11;

  @override
  SOSSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SOSSettings(
      id: fields[0] as String,
      userId: fields[1] as String,
      customMessage: fields[2] as String,
      isActive: fields[3] as bool,
      contacts: (fields[4] as List).cast<TrustedContact>(),
      lastUpdated: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SOSSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.customMessage)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.contacts)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SOSSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
