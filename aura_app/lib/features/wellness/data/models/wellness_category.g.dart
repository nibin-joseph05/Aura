// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellness_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WellnessCategoryAdapter extends TypeAdapter<WellnessCategory> {
  @override
  final int typeId = 20;

  @override
  WellnessCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WellnessCategory.progress;
      case 1:
        return WellnessCategory.motivation;
      case 2:
        return WellnessCategory.tip;
      case 3:
        return WellnessCategory.achievement;
      case 4:
        return WellnessCategory.general;
      default:
        return WellnessCategory.progress;
    }
  }

  @override
  void write(BinaryWriter writer, WellnessCategory obj) {
    switch (obj) {
      case WellnessCategory.progress:
        writer.writeByte(0);
        break;
      case WellnessCategory.motivation:
        writer.writeByte(1);
        break;
      case WellnessCategory.tip:
        writer.writeByte(2);
        break;
      case WellnessCategory.achievement:
        writer.writeByte(3);
        break;
      case WellnessCategory.general:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WellnessCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
