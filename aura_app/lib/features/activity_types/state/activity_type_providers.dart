import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/activity_type_repository.dart';
import '../data/models/activity_category.dart';
import '../data/models/activity_type.dart';

final activityTypeRepositoryProvider = Provider<ActivityTypeRepository>((ref) {
  return ActivityTypeRepository();
});

final categoriesProvider = FutureProvider<List<ActivityCategory>>((ref) async {
  final repository = ref.read(activityTypeRepositoryProvider);
  return await repository.getCategories();
});

final activityTypesProvider = FutureProvider<List<ActivityType>>((ref) async {
  final repository = ref.read(activityTypeRepositoryProvider);
  return await repository.getActivityTypes();
});

final typesByCategoryProvider =
    FutureProvider.family<List<ActivityType>, String>((ref, categoryId) async {
      final repository = ref.read(activityTypeRepositoryProvider);
      return await repository.getTypesByCategory(categoryId);
    });

final refreshCategoriesProvider = FutureProvider<List<ActivityCategory>>((
  ref,
) async {
  final repository = ref.read(activityTypeRepositoryProvider);
  return await repository.getCategories(forceRefresh: true);
});

final refreshActivityTypesProvider = FutureProvider<List<ActivityType>>((
  ref,
) async {
  final repository = ref.read(activityTypeRepositoryProvider);
  return await repository.getActivityTypes(forceRefresh: true);
});
