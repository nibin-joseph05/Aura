import 'package:hive/hive.dart';
import 'trusted_contact.dart';

part 'sos_settings.g.dart';

@HiveType(typeId: 11)
class SOSSettings {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String customMessage;

  @HiveField(3)
  final bool isActive;

  @HiveField(4)
  final List<TrustedContact> contacts;

  @HiveField(5)
  final DateTime? lastUpdated;

  SOSSettings({
    required this.id,
    required this.userId,
    required this.customMessage,
    this.isActive = true,
    this.contacts = const [],
    this.lastUpdated,
  });

  factory SOSSettings.fromJson(Map<String, dynamic> json) {
    return SOSSettings(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      customMessage:
          json['customMessage'] ??
          'I need help! This is an emergency. Please contact me or call emergency services.',
      isActive: json['isActive'] ?? true,
      contacts:
          (json['contacts'] as List<dynamic>?)
              ?.map((c) => TrustedContact.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'customMessage': customMessage,
      'isActive': isActive,
      'contacts': contacts.map((c) => c.toJson()).toList(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  SOSSettings copyWith({
    String? id,
    String? userId,
    String? customMessage,
    bool? isActive,
    List<TrustedContact>? contacts,
    DateTime? lastUpdated,
  }) {
    return SOSSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customMessage: customMessage ?? this.customMessage,
      isActive: isActive ?? this.isActive,
      contacts: contacts ?? this.contacts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  static SOSSettings defaultSettings(String userId) {
    return SOSSettings(
      id: '',
      userId: userId,
      customMessage:
          'I need help! This is an emergency. Please contact me or call emergency services.',
      isActive: true,
      contacts: [],
    );
  }
}
