import 'package:hive/hive.dart';
import 'models/wellness_update.dart';

class WellnessLocalDataSource {
  static const String _feedBoxName = 'wellness_feed';
  static const String _myUpdatesBoxName = 'wellness_my_updates';

  Future<Box<WellnessUpdate>> _getFeedBox() async {
    return await Hive.openBox<WellnessUpdate>(_feedBoxName);
  }

  Future<Box<WellnessUpdate>> _getMyUpdatesBox() async {
    return await Hive.openBox<WellnessUpdate>(_myUpdatesBoxName);
  }

  Future<List<WellnessUpdate>> getFeed() async {
    final box = await _getFeedBox();
    final updates = box.values.toList();
    updates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return updates;
  }

  Future<void> cacheFeed(List<WellnessUpdate> updates) async {
    final box = await _getFeedBox();
    await box.clear();
    for (final update in updates) {
      await box.put(update.id, update);
    }
  }

  Future<List<WellnessUpdate>> getMyUpdates(String userId) async {
    final box = await _getMyUpdatesBox();
    final updates = box.values.where((u) => u.userId == userId).toList();
    updates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return updates;
  }

  Future<void> cacheMyUpdates(List<WellnessUpdate> updates) async {
    final box = await _getMyUpdatesBox();
    await box.clear();
    for (final update in updates) {
      await box.put(update.id, update);
    }
  }

  Future<void> addUpdate(WellnessUpdate update) async {
    final box = await _getMyUpdatesBox();
    await box.put(update.id, update);
  }

  Future<void> removeUpdate(String id) async {
    final feedBox = await _getFeedBox();
    final myBox = await _getMyUpdatesBox();
    await feedBox.delete(id);
    await myBox.delete(id);
  }

  Future<void> updateLikeStatus(String id, bool liked, int likesCount) async {
    final box = await _getFeedBox();
    final update = box.get(id);
    if (update != null) {
      final updated = update.copyWith(
        likedByCurrentUser: liked,
        likesCount: likesCount,
      );
      await box.put(id, updated);
    }
  }

  Future<void> clearAll() async {
    final feedBox = await _getFeedBox();
    final myBox = await _getMyUpdatesBox();
    await feedBox.clear();
    await myBox.clear();
  }
}
