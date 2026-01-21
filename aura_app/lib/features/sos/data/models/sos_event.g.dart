// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sos_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SOSEventAdapter extends TypeAdapter<SOSEvent> {
  @override
  final int typeId = 13;

  @override
  SOSEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SOSEvent(
      id: fields[0] as String,
      oderId: fields[1] as String,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      address: fields[4] as String?,
      message: fields[5] as String,
      contactsNotified: fields[6] as int,
      status: fields[7] as SOSEventStatus,
      triggeredAt: fields[8] as DateTime,
      resolvedAt: fields[9] as DateTime?,
      syncedToServer: fields[10] as bool,
      deviceInfo: fields[11] as String?,
      mapsUrl: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SOSEvent obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.oderId)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.message)
      ..writeByte(6)
      ..write(obj.contactsNotified)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.triggeredAt)
      ..writeByte(9)
      ..write(obj.resolvedAt)
      ..writeByte(10)
      ..write(obj.syncedToServer)
      ..writeByte(11)
      ..write(obj.deviceInfo)
      ..writeByte(12)
      ..write(obj.mapsUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SOSEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
