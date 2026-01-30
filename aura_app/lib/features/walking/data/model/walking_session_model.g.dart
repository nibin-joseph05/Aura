// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walking_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalkingSessionModelAdapter extends TypeAdapter<WalkingSessionModel> {
  @override
  final int typeId = 10;

  @override
  WalkingSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalkingSessionModel(
      id: fields[0] as String?,
      remoteId: fields[1] as String?,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      distanceMeters: fields[4] as double,
      durationSeconds: fields[5] as int,
      stepsCount: fields[6] as int,
      caloriesBurned: fields[7] as double,
      isActive: fields[8] as bool,
      routePoints: (fields[9] as List?)?.cast<RoutePoint>(),
      isSynced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WalkingSessionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.remoteId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.distanceMeters)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.stepsCount)
      ..writeByte(7)
      ..write(obj.caloriesBurned)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.routePoints)
      ..writeByte(10)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalkingSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoutePointAdapter extends TypeAdapter<RoutePoint> {
  @override
  final int typeId = 11;

  @override
  RoutePoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutePoint(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      timestamp: fields[2] as int,
      altitude: fields[3] as double?,
      speed: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, RoutePoint obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.altitude)
      ..writeByte(4)
      ..write(obj.speed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutePointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
