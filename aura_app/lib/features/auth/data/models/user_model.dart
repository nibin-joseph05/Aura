import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String? phone;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final bool phoneVerified;

  @HiveField(4)
  final bool emailVerified;

  @HiveField(5)
  final String signupMethod;

  @HiveField(6)
  final String? name;

  @HiveField(7)
  final String? username;

  @HiveField(8)
  final String? profileImageUrl;

  @HiveField(9)
  final String? gender;

  @HiveField(10)
  final String? dob;

  @HiveField(11)
  final bool profileCompleted;

  @HiveField(12)
  final String? accountStatus;

  @HiveField(13)
  final DateTime? createdAt;

  @HiveField(14)
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    this.phone,
    this.email,
    this.phoneVerified = false,
    this.emailVerified = false,
    this.signupMethod = "PHONE",
    this.name,
    this.username,
    this.profileImageUrl,
    this.gender,
    this.dob,
    this.profileCompleted = false,
    this.accountStatus,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json["uid"],
      phone: json["phone"],
      email: json["email"],
      phoneVerified: json["phoneVerified"] ?? false,
      emailVerified: json["emailVerified"] ?? false,
      signupMethod: json["signupMethod"] ?? "PHONE",
      name: json["name"],
      username: json["username"],
      profileImageUrl: json["profileImageUrl"],
      gender: json["gender"],
      dob: json["dob"],
      profileCompleted: json["profileCompleted"] ?? false,
      accountStatus: json["accountStatus"],
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      lastLoginAt: json["lastLoginAt"] != null
          ? DateTime.parse(json["lastLoginAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "phone": phone,
      "email": email,
      "phoneVerified": phoneVerified,
      "emailVerified": emailVerified,
      "signupMethod": signupMethod,
      "name": name,
      "username": username,
      "profileImageUrl": profileImageUrl,
      "gender": gender,
      "dob": dob,
      "profileCompleted": profileCompleted,
      "accountStatus": accountStatus,
      "createdAt": createdAt?.toIso8601String(),
      "lastLoginAt": lastLoginAt?.toIso8601String(),
    };
  }
}