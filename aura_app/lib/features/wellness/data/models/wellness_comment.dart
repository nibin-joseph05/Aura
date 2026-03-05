class WellnessComment {
  final String id;
  final String postId;
  final String userId;
  final String? userName;
  final String? userProfileImage;
  final String content;
  final String? translatedContent;
  final String? detectedLanguage;
  final String translationStatus;
  final DateTime createdAt;

  WellnessComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.userName,
    this.userProfileImage,
    required this.content,
    this.translatedContent,
    this.detectedLanguage,
    this.translationStatus = 'PENDING',
    required this.createdAt,
  });

  bool get isEnglish =>
      detectedLanguage?.toLowerCase() == 'en' ||
      translationStatus == 'NOT_NEEDED';

  bool get canTranslate => translationStatus == 'PENDING' && !isEnglish;

  bool get hasTranslation =>
      translatedContent != null && translationStatus == 'TRANSLATED';

  factory WellnessComment.fromJson(Map<String, dynamic> json) {
    return WellnessComment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'],
      userProfileImage: json['userProfileImage'],
      content: json['content'] ?? '',
      translatedContent: json['translatedContent'],
      detectedLanguage: json['detectedLanguage'],
      translationStatus: json['translationStatus'] ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
