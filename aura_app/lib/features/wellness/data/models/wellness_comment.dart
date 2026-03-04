class WellnessComment {
  final String id;
  final String postId;
  final String userId;
  final String? userName;
  final String? userProfileImage;
  final String content;
  final DateTime createdAt;

  WellnessComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.userName,
    this.userProfileImage,
    required this.content,
    required this.createdAt,
  });

  factory WellnessComment.fromJson(Map<String, dynamic> json) {
    return WellnessComment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'],
      userProfileImage: json['userProfileImage'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
