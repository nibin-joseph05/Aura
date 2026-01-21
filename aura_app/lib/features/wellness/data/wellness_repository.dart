import 'package:connectivity_plus/connectivity_plus.dart';
import 'wellness_local_datasource.dart';
import 'wellness_remote_datasource.dart';
import 'models/wellness_update.dart';
import 'models/wellness_category.dart';

class WellnessRepository {
  final WellnessLocalDataSource _localDataSource = WellnessLocalDataSource();
  final WellnessRemoteDataSource _remoteDataSource = WellnessRemoteDataSource();

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<List<WellnessUpdate>> getFeed({
    int page = 0,
    int size = 20,
    WellnessCategory? category,
  }) async {
    try {
      if (await _isOnline()) {
        final updates = await _remoteDataSource.getFeed(
          page: page,
          size: size,
          category: category,
        );
        if (page == 0) {
          await _localDataSource.cacheFeed(updates);
        }
        return updates;
      }
    } catch (_) {}
    return _localDataSource.getFeed();
  }

  Future<List<WellnessUpdate>> getMyUpdates(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      if (await _isOnline()) {
        final updates = await _remoteDataSource.getMyUpdates(
          page: page,
          size: size,
        );
        if (page == 0) {
          await _localDataSource.cacheMyUpdates(updates);
        }
        return updates;
      }
    } catch (_) {}
    return _localDataSource.getMyUpdates(userId);
  }

  Future<List<WellnessUpdate>> getTrending() async {
    try {
      if (await _isOnline()) {
        return await _remoteDataSource.getTrending();
      }
    } catch (_) {}
    return [];
  }

  Future<WellnessUpdate> createUpdate({
    required String content,
    required WellnessCategory category,
    String? imageUrl,
  }) async {
    final update = await _remoteDataSource.createUpdate(
      content: content,
      category: category,
      imageUrl: imageUrl,
    );
    await _localDataSource.addUpdate(update);
    return update;
  }

  Future<void> deleteUpdate(String id) async {
    await _remoteDataSource.deleteUpdate(id);
    await _localDataSource.removeUpdate(id);
  }

  Future<WellnessUpdate> likeUpdate(String id) async {
    final update = await _remoteDataSource.likeUpdate(id);
    await _localDataSource.updateLikeStatus(id, true, update.likesCount);
    return update;
  }

  Future<WellnessUpdate> unlikeUpdate(String id) async {
    final update = await _remoteDataSource.unlikeUpdate(id);
    await _localDataSource.updateLikeStatus(id, false, update.likesCount);
    return update;
  }
}
