import 'package:hive/hive.dart';

part 'comment_model.g.dart';

@HiveType(typeId: 20)
class CommentModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String postId;

  @HiveField(2)
  String userId;

  @HiveField(3)
  String originalContent;

  @HiveField(4)
  String? translatedContent;

  @HiveField(5)
  String? detectedLanguage;

  @HiveField(6)
  String translationStatus;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool isSynced;

  @HiveField(9)
  bool isPending;

  CommentModel({
    this.id,
    required this.postId,
    required this.userId,
    required this.originalContent,
    this.translatedContent,
    this.detectedLanguage,
    this.translationStatus = 'PENDING',
    required this.createdAt,
    this.isSynced = false,
    this.isPending = false,
  });

  bool get isEnglish =>
      detectedLanguage?.toLowerCase() == 'en' ||
      translationStatus == 'NOT_NEEDED';

  bool get canTranslate => translationStatus == 'PENDING' && !isEnglish;

  bool get hasTranslation =>
      translatedContent != null && translationStatus == 'TRANSLATED';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'originalContent': originalContent,
      'translatedContent': translatedContent,
      'detectedLanguage': detectedLanguage,
      'translationStatus': translationStatus,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String?,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      originalContent: json['originalContent'] as String,
      translatedContent: json['translatedContent'] as String?,
      detectedLanguage: json['detectedLanguage'] as String?,
      translationStatus: json['translationStatus'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }
}
