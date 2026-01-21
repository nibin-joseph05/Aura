import 'package:hive/hive.dart';

part 'sos_event_status.g.dart';

@HiveType(typeId: 12)
enum SOSEventStatus {
  @HiveField(0)
  triggered,

  @HiveField(1)
  delivered,

  @HiveField(2)
  acknowledged,

  @HiveField(3)
  resolved,

  @HiveField(4)
  cancelled,

  @HiveField(5)
  pendingSync,
}

extension SOSEventStatusExtension on SOSEventStatus {
  String get displayName {
    switch (this) {
      case SOSEventStatus.triggered:
        return 'Triggered';
      case SOSEventStatus.delivered:
        return 'Delivered';
      case SOSEventStatus.acknowledged:
        return 'Acknowledged';
      case SOSEventStatus.resolved:
        return 'Resolved';
      case SOSEventStatus.cancelled:
        return 'Cancelled';
      case SOSEventStatus.pendingSync:
        return 'Pending Sync';
    }
  }

  String get serverValue {
    switch (this) {
      case SOSEventStatus.triggered:
        return 'TRIGGERED';
      case SOSEventStatus.delivered:
        return 'DELIVERED';
      case SOSEventStatus.acknowledged:
        return 'ACKNOWLEDGED';
      case SOSEventStatus.resolved:
        return 'RESOLVED';
      case SOSEventStatus.cancelled:
        return 'CANCELLED';
      case SOSEventStatus.pendingSync:
        return 'TRIGGERED';
    }
  }

  static SOSEventStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'TRIGGERED':
        return SOSEventStatus.triggered;
      case 'DELIVERED':
        return SOSEventStatus.delivered;
      case 'ACKNOWLEDGED':
        return SOSEventStatus.acknowledged;
      case 'RESOLVED':
        return SOSEventStatus.resolved;
      case 'CANCELLED':
        return SOSEventStatus.cancelled;
      default:
        return SOSEventStatus.triggered;
    }
  }
}
