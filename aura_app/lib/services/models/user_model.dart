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
  final bool googleLinked;

  @HiveField(7)
  final bool emailPasswordLinked;

  @HiveField(8)
  final String? name;

  @HiveField(9)
  final String? username;

  @HiveField(10)
  final String? profileImageUrl;

  @HiveField(11)
  final String? gender;

  @HiveField(12)
  final String? dob;

  @HiveField(13)
  final bool profileCompleted;

  @HiveField(14)
  final DateTime? createdAt;

  @HiveField(15)
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    this.phone,
    this.email,
    this.phoneVerified = false,
    this.emailVerified = false,
    this.signupMethod = "phone",
    this.googleLinked = false,
    this.emailPasswordLinked = false,
    this.name,
    this.username,
    this.profileImageUrl,
    this.gender,
    this.dob,
    this.profileCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json["uid"],
      phone: json["phone"],
      email: json["email"],
      phoneVerified: json["phoneVerified"] ?? false,
      emailVerified: json["emailVerified"] ?? false,
      signupMethod: json["signupMethod"] ?? "phone",
      googleLinked: json["googleLinked"] ?? false,
      emailPasswordLinked: json["emailPasswordLinked"] ?? false,
      name: json["name"],
      username: json["username"],
      profileImageUrl: json["profileImageUrl"],
      gender: json["gender"],
      dob: json["dob"],
      profileCompleted: json["profileCompleted"] ?? false,
      createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
      updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
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
      "googleLinked": googleLinked,
      "emailPasswordLinked": emailPasswordLinked,
      "name": name,
      "username": username,
      "profileImageUrl": profileImageUrl,
      "gender": gender,
      "dob": dob,
      "profileCompleted": profileCompleted,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}
