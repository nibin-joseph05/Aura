// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sos_event_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SOSEventStatusAdapter extends TypeAdapter<SOSEventStatus> {
  @override
  final int typeId = 12;

  @override
  SOSEventStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SOSEventStatus.triggered;
      case 1:
        return SOSEventStatus.delivered;
      case 2:
        return SOSEventStatus.acknowledged;
      case 3:
        return SOSEventStatus.resolved;
      case 4:
        return SOSEventStatus.cancelled;
      case 5:
        return SOSEventStatus.pendingSync;
      default:
        return SOSEventStatus.triggered;
    }
  }

  @override
  void write(BinaryWriter writer, SOSEventStatus obj) {
    switch (obj) {
      case SOSEventStatus.triggered:
        writer.writeByte(0);
        break;
      case SOSEventStatus.delivered:
        writer.writeByte(1);
        break;
      case SOSEventStatus.acknowledged:
        writer.writeByte(2);
        break;
      case SOSEventStatus.resolved:
        writer.writeByte(3);
        break;
      case SOSEventStatus.cancelled:
        writer.writeByte(4);
        break;
      case SOSEventStatus.pendingSync:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SOSEventStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
