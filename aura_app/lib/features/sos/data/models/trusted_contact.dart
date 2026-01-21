import 'package:hive/hive.dart';

part 'trusted_contact.g.dart';

@HiveType(typeId: 10)
class TrustedContact {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final String? relationship;

  @HiveField(5)
  final int priority;

  @HiveField(6)
  final bool isActive;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.relationship,
    this.priority = 1,
    this.isActive = true,
  });

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      relationship: json['relationship'],
      priority: json['priority'] ?? 1,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'priority': priority,
      'isActive': isActive,
    };
  }

  TrustedContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? relationship,
    int? priority,
    bool? isActive,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
    );
  }
}
