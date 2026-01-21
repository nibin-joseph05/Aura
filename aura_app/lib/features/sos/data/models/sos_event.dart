import 'package:hive/hive.dart';
import 'sos_event_status.dart';

part 'sos_event.g.dart';

@HiveType(typeId: 13)
class SOSEvent {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String oderId;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final String? address;

  @HiveField(5)
  final String message;

  @HiveField(6)
  final int contactsNotified;

  @HiveField(7)
  final SOSEventStatus status;

  @HiveField(8)
  final DateTime triggeredAt;

  @HiveField(9)
  final DateTime? resolvedAt;

  @HiveField(10)
  final bool syncedToServer;

  @HiveField(11)
  final String? deviceInfo;

  @HiveField(12)
  final String? mapsUrl;

  SOSEvent({
    required this.id,
    required this.oderId,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.message,
    this.contactsNotified = 0,
    this.status = SOSEventStatus.triggered,
    required this.triggeredAt,
    this.resolvedAt,
    this.syncedToServer = false,
    this.deviceInfo,
    this.mapsUrl,
  });

  factory SOSEvent.fromJson(Map<String, dynamic> json) {
    return SOSEvent(
      id: json['id'] ?? '',
      oderId: json['userId'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'],
      message: json['message'] ?? '',
      contactsNotified: json['contactsNotified'] ?? 0,
      status: SOSEventStatusExtension.fromString(json['status']),
      triggeredAt: json['triggeredAt'] != null
          ? DateTime.parse(json['triggeredAt'])
          : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      syncedToServer: json['syncedFromOffline'] != true,
      deviceInfo: json['deviceInfo'],
      mapsUrl: json['mapsUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': oderId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'message': message,
      'contactsNotified': contactsNotified,
      'status': status.serverValue,
      'triggeredAt': triggeredAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'syncedFromOffline': !syncedToServer,
      'deviceInfo': deviceInfo,
    };
  }

  Map<String, dynamic> toTriggerRequest() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'customMessage': message,
      'contactsNotified': contactsNotified,
      'syncedFromOffline': !syncedToServer,
      'triggeredAt': triggeredAt.toIso8601String(),
      'deviceInfo': deviceInfo,
    };
  }

  SOSEvent copyWith({
    String? id,
    String? oderId,
    double? latitude,
    double? longitude,
    String? address,
    String? message,
    int? contactsNotified,
    SOSEventStatus? status,
    DateTime? triggeredAt,
    DateTime? resolvedAt,
    bool? syncedToServer,
    String? deviceInfo,
    String? mapsUrl,
  }) {
    return SOSEvent(
      id: id ?? this.id,
      oderId: oderId ?? this.oderId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      message: message ?? this.message,
      contactsNotified: contactsNotified ?? this.contactsNotified,
      status: status ?? this.status,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      syncedToServer: syncedToServer ?? this.syncedToServer,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      mapsUrl: mapsUrl ?? this.mapsUrl,
    );
  }

  String get googleMapsUrl =>
      'https://www.google.com/maps?q=$latitude,$longitude';
}
