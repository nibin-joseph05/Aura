import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/wellness_repository.dart';
import '../../data/models/wellness_update.dart';
import '../../data/models/wellness_category.dart';

final wellnessRepositoryProvider = Provider<WellnessRepository>((ref) {
  return WellnessRepository();
});

final wellnessFeedProvider =
    FutureProvider.family<List<WellnessUpdate>, WellnessCategory?>((
      ref,
      category,
    ) async {
      final repository = ref.watch(wellnessRepositoryProvider);
      return repository.getFeed(category: category);
    });

final myWellnessUpdatesProvider =
    FutureProvider.family<List<WellnessUpdate>, String>((ref, userId) async {
      final repository = ref.watch(wellnessRepositoryProvider);
      return repository.getMyUpdates(userId);
    });

final trendingUpdatesProvider = FutureProvider<List<WellnessUpdate>>((
  ref,
) async {
  final repository = ref.watch(wellnessRepositoryProvider);
  return repository.getTrending();
});

class WellnessNotifier extends StateNotifier<AsyncValue<void>> {
  final WellnessRepository _repository;
  final Ref _ref;

  WellnessNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<WellnessUpdate?> createUpdate({
    required String content,
    required WellnessCategory category,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final update = await _repository.createUpdate(
        content: content,
        category: category,
        imageUrl: imageUrl,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(wellnessFeedProvider);
      _ref.invalidate(myWellnessUpdatesProvider);
      return update;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> deleteUpdate(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteUpdate(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(wellnessFeedProvider);
      _ref.invalidate(myWellnessUpdatesProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<WellnessUpdate?> toggleLike(WellnessUpdate update) async {
    try {
      if (update.likedByCurrentUser) {
        return await _repository.unlikeUpdate(update.id);
      } else {
        return await _repository.likeUpdate(update.id);
      }
    } catch (_) {
      return null;
    }
  }
}

final wellnessNotifierProvider =
    StateNotifierProvider<WellnessNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(wellnessRepositoryProvider);
      return WellnessNotifier(repository, ref);
    });

final selectedCategoryProvider = StateProvider<WellnessCategory?>(
  (ref) => null,
);
