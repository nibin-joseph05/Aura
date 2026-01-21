import 'package:hive/hive.dart';

part 'pending_wellness_operation.g.dart';

@HiveType(typeId: 22)
class PendingWellnessOperation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String operationType;

  @HiveField(2)
  final String? updateId;

  @HiveField(3)
  final String? content;

  @HiveField(4)
  final String? category;

  @HiveField(5)
  final String? imageUrl;

  @HiveField(6)
  final DateTime createdAt;

  PendingWellnessOperation({
    required this.id,
    required this.operationType,
    this.updateId,
    this.content,
    this.category,
    this.imageUrl,
    required this.createdAt,
  });

  factory PendingWellnessOperation.createUpdate({
    required String content,
    required String category,
    String? imageUrl,
  }) {
    return PendingWellnessOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operationType: 'CREATE',
      content: content,
      category: category,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
  }

  factory PendingWellnessOperation.like(String updateId) {
    return PendingWellnessOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operationType: 'LIKE',
      updateId: updateId,
      createdAt: DateTime.now(),
    );
  }

  factory PendingWellnessOperation.unlike(String updateId) {
    return PendingWellnessOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operationType: 'UNLIKE',
      updateId: updateId,
      createdAt: DateTime.now(),
    );
  }
}
