import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/network/sync/sync_manager.dart';
import 'wellness_local_datasource.dart';
import 'wellness_remote_datasource.dart';
import 'models/wellness_update.dart';
import 'models/wellness_comment.dart';
import 'models/wellness_category.dart';
import 'models/pending_wellness_operation.dart';

class WellnessRepository {
  final WellnessLocalDataSource _localDataSource = WellnessLocalDataSource();
  final WellnessRemoteDataSource _remoteDataSource = WellnessRemoteDataSource();
  final SyncManager _syncManager = SyncManager();

  WellnessRepository() {
    _syncManager.registerSyncFunction(syncPendingOperations);
    _updatePendingCount();
  }

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> _updatePendingCount() async {
    final count = await _localDataSource.getPendingCount();
    _syncManager.updatePendingCount(wellness: count);
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

  Future<List<WellnessUpdate>> getUserPosts(
    String userId, {
    int page = 0,
  }) async {
    try {
      if (await _isOnline()) {
        return await _remoteDataSource.getUserPosts(userId, page: page);
      }
    } catch (_) {}
    return [];
  }

  Future<List<WellnessUpdate>> getTrending() async {
    try {
      if (await _isOnline()) {
        return await _remoteDataSource.getTrending();
      }
    } catch (_) {}
    return [];
  }

  Future<String> uploadImage(File imageFile) async {
    return await _remoteDataSource.uploadImage(imageFile);
  }

  Future<WellnessUpdate?> createUpdate({
    required String content,
    required WellnessCategory category,
    String? imageUrl,
  }) async {
    try {
      if (await _isOnline()) {
        final update = await _remoteDataSource.createUpdate(
          content: content,
          category: category,
          imageUrl: imageUrl,
        );
        await _localDataSource.addUpdate(update);
        return update;
      }
    } catch (_) {}

    final pendingOp = PendingWellnessOperation.createUpdate(
      content: content,
      category: category.name.toUpperCase(),
      imageUrl: imageUrl,
    );
    await _localDataSource.addPendingOperation(pendingOp);
    await _updatePendingCount();
    return null;
  }

  Future<WellnessUpdate?> editUpdate({
    required String id,
    required String content,
    required WellnessCategory category,
    String? imageUrl,
  }) async {
    return await _remoteDataSource.editUpdate(
      id: id,
      content: content,
      category: category,
      imageUrl: imageUrl,
    );
  }

  Future<void> deleteUpdate(String id) async {
    if (await _isOnline()) {
      await _remoteDataSource.deleteUpdate(id);
    }
    await _localDataSource.removeUpdate(id);
  }

  Future<WellnessUpdate?> likeUpdate(String id) async {
    try {
      if (await _isOnline()) {
        final update = await _remoteDataSource.likeUpdate(id);
        await _localDataSource.updateLikeStatus(id, true, update.likesCount);
        return update;
      }
    } catch (_) {}

    final pendingOp = PendingWellnessOperation.like(id);
    await _localDataSource.addPendingOperation(pendingOp);
    await _updatePendingCount();
    return null;
  }

  Future<WellnessUpdate?> unlikeUpdate(String id) async {
    try {
      if (await _isOnline()) {
        final update = await _remoteDataSource.unlikeUpdate(id);
        await _localDataSource.updateLikeStatus(id, false, update.likesCount);
        return update;
      }
    } catch (_) {}

    final pendingOp = PendingWellnessOperation.unlike(id);
    await _localDataSource.addPendingOperation(pendingOp);
    await _updatePendingCount();
    return null;
  }

  Future<List<WellnessComment>> getComments(String postId) async {
    return await _remoteDataSource.getComments(postId);
  }

  Future<WellnessComment> createComment(String postId, String content) async {
    return await _remoteDataSource.createComment(postId, content);
  }

  Future<void> deleteComment(String commentId) async {
    await _remoteDataSource.deleteComment(commentId);
  }

  Future<void> syncPendingOperations() async {
    if (!await _isOnline()) return;

    final pendingOps = await _localDataSource.getPendingOperations();
    for (final op in pendingOps) {
      try {
        switch (op.operationType) {
          case 'CREATE':
            if (op.content != null && op.category != null) {
              await _remoteDataSource.createUpdate(
                content: op.content!,
                category: WellnessCategory.fromString(op.category!),
                imageUrl: op.imageUrl,
              );
            }
            break;
          case 'LIKE':
            if (op.updateId != null) {
              await _remoteDataSource.likeUpdate(op.updateId!);
            }
            break;
          case 'UNLIKE':
            if (op.updateId != null) {
              await _remoteDataSource.unlikeUpdate(op.updateId!);
            }
            break;
        }
        await _localDataSource.removePendingOperation(op.id);
      } catch (_) {}
    }
    await _updatePendingCount();
  }

  Future<int> getPendingCount() async {
    return await _localDataSource.getPendingCount();
  }
}
