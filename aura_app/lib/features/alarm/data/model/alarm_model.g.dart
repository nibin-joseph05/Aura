// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmModelAdapter extends TypeAdapter<AlarmModel> {
  @override
  final int typeId = 30;

  @override
  AlarmModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmModel(
      id: fields[0] as String,
      hour: fields[1] as int,
      minute: fields[2] as int,
      label: fields[3] as String,
      repeatDays: (fields[4] as List?)?.cast<int>(),
      tone: fields[5] as String,
      isEnabled: fields[6] as bool,
      dismissType: fields[7] as String,
      mathDifficulty: fields[8] as int,
      vibrate: fields[9] as bool,
      snoozeMinutes: fields[10] as int,
      nextTriggerTime: fields[11] as DateTime?,
      createdAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.hour)
      ..writeByte(2)
      ..write(obj.minute)
      ..writeByte(3)
      ..write(obj.label)
      ..writeByte(4)
      ..write(obj.repeatDays)
      ..writeByte(5)
      ..write(obj.tone)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.dismissType)
      ..writeByte(8)
      ..write(obj.mathDifficulty)
      ..writeByte(9)
      ..write(obj.vibrate)
      ..writeByte(10)
      ..write(obj.snoozeMinutes)
      ..writeByte(11)
      ..write(obj.nextTriggerTime)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
