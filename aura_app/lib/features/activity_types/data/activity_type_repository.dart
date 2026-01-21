import 'package:dio/dio.dart';
import '../../../core/network/connectivity/connectivity_service.dart';
import 'activity_type_local_datasource.dart';
import 'activity_type_remote_datasource.dart';
import 'models/activity_category.dart';
import 'models/activity_type.dart';

class ActivityTypeRepository {
  final ActivityTypeRemoteDataSource _remoteDataSource;
  final ActivityTypeLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;

  ActivityTypeRepository({
    ActivityTypeRemoteDataSource? remoteDataSource,
    ActivityTypeLocalDataSource? localDataSource,
    ConnectivityService? connectivityService,
  }) : _remoteDataSource = remoteDataSource ?? ActivityTypeRemoteDataSource(),
       _localDataSource = localDataSource ?? ActivityTypeLocalDataSource(),
       _connectivityService = connectivityService ?? ConnectivityService();

  Future<List<ActivityCategory>> getCategories({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || await _connectivityService.hasConnection()) {
      try {
        final categories = await _remoteDataSource.getActiveCategories();
        await _localDataSource.saveCategories(categories);
        return categories;
      } on DioException {
        return await _localDataSource.getCategories();
      }
    }
    return await _localDataSource.getCategories();
  }

  Future<List<ActivityType>> getActivityTypes({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || await _connectivityService.hasConnection()) {
      try {
        final types = await _remoteDataSource.getActiveTypes();
        await _localDataSource.saveTypes(types);
        return types;
      } on DioException {
        return await _localDataSource.getTypes();
      }
    }
    return await _localDataSource.getTypes();
  }

  Future<List<ActivityType>> getTypesByCategory(String categoryId) async {
    if (await _connectivityService.hasConnection()) {
      try {
        return await _remoteDataSource.getTypesByCategory(categoryId);
      } on DioException {
        return await _localDataSource.getTypesByCategory(categoryId);
      }
    }
    return await _localDataSource.getTypesByCategory(categoryId);
  }

  Future<ActivityType?> getTypeById(String id) async {
    return await _localDataSource.getTypeById(id);
  }
}
