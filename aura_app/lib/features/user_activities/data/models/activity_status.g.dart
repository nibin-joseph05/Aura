// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityStatusAdapter extends TypeAdapter<ActivityStatus> {
  @override
  final int typeId = 14;

  @override
  ActivityStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityStatus.pending;
      case 1:
        return ActivityStatus.inProgress;
      case 2:
        return ActivityStatus.completed;
      case 3:
        return ActivityStatus.skipped;
      case 4:
        return ActivityStatus.missed;
      default:
        return ActivityStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityStatus obj) {
    switch (obj) {
      case ActivityStatus.pending:
        writer.writeByte(0);
        break;
      case ActivityStatus.inProgress:
        writer.writeByte(1);
        break;
      case ActivityStatus.completed:
        writer.writeByte(2);
        break;
      case ActivityStatus.skipped:
        writer.writeByte(3);
        break;
      case ActivityStatus.missed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
