import 'package:hive/hive.dart';
import 'wellness_category.dart';

part 'wellness_update.g.dart';

@HiveType(typeId: 21)
class WellnessUpdate extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String? userName;

  @HiveField(3)
  final String? userProfileImage;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final String? imageUrl;

  @HiveField(6)
  final WellnessCategory category;

  @HiveField(7)
  final int likesCount;

  @HiveField(8)
  final bool likedByCurrentUser;

  @HiveField(9)
  final bool isApproved;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final int commentsCount;

  WellnessUpdate({
    required this.id,
    required this.userId,
    this.userName,
    this.userProfileImage,
    required this.content,
    this.imageUrl,
    required this.category,
    this.likesCount = 0,
    this.likedByCurrentUser = false,
    this.isApproved = false,
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory WellnessUpdate.fromJson(Map<String, dynamic> json) {
    return WellnessUpdate(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'],
      userProfileImage: json['userProfileImage'],
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      category: WellnessCategory.fromString(json['category'] ?? 'GENERAL'),
      likesCount: json['likesCount'] ?? 0,
      likedByCurrentUser: json['likedByCurrentUser'] ?? false,
      isApproved: json['isApproved'] ?? false,
      commentsCount: json['commentsCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'content': content,
      'imageUrl': imageUrl,
      'category': category.name.toUpperCase(),
      'likesCount': likesCount,
      'likedByCurrentUser': likedByCurrentUser,
      'isApproved': isApproved,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WellnessUpdate copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? content,
    String? imageUrl,
    WellnessCategory? category,
    int? likesCount,
    bool? likedByCurrentUser,
    bool? isApproved,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return WellnessUpdate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      likesCount: likesCount ?? this.likesCount,
      likedByCurrentUser: likedByCurrentUser ?? this.likedByCurrentUser,
      isApproved: isApproved ?? this.isApproved,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
