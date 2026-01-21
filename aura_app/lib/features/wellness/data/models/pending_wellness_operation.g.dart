// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_wellness_operation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingWellnessOperationAdapter
    extends TypeAdapter<PendingWellnessOperation> {
  @override
  final int typeId = 22;

  @override
  PendingWellnessOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingWellnessOperation(
      id: fields[0] as String,
      operationType: fields[1] as String,
      updateId: fields[2] as String?,
      content: fields[3] as String?,
      category: fields[4] as String?,
      imageUrl: fields[5] as String?,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PendingWellnessOperation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.operationType)
      ..writeByte(2)
      ..write(obj.updateId)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingWellnessOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
