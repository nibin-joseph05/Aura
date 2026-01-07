import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../auth/data/models/user_model.dart';
import '../../../user/data/datasources/user_remote_datasource.dart';

class UserState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const UserState({this.user, this.isLoading = false, this.error});

  UserState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserRemoteDataSource _dataSource;

  UserNotifier(this._dataSource) : super(const UserState());

  Future<void> syncCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _dataSource.getCurrentUser();
      await _saveUserLocally(user);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadUserFromLocal() async {
    try {
      final box = await Hive.openBox<UserModel>('user');
      final user = box.get('currentUser');
      if (user != null) {
        state = state.copyWith(user: user);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load user');
    }
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? username,
    String? gender,
    String? dob,
    String? profileImageUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await _dataSource.updateProfile(
        uid: uid,
        name: name,
        username: username,
        gender: gender,
        dob: dob,
        profileImageUrl: profileImageUrl,
      );
      await _saveUserLocally(updatedUser);
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> _saveUserLocally(UserModel user) async {
    final box = await Hive.openBox<UserModel>('user');
    await box.put('currentUser', user);
  }

  void clearUser() {
    state = const UserState();
    Hive.box<UserModel>('user').delete('currentUser');
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(UserRemoteDataSource());
});
