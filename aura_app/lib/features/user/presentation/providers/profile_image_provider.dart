import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/profile_image_remote_datasource.dart';

enum ProfileImageUploadStatus { idle, uploading, success, error }

class ProfileImageState {
  final ProfileImageUploadStatus status;
  final String? imageUrl;
  final String? errorMessage;
  final bool wasRemoved;

  const ProfileImageState({
    this.status = ProfileImageUploadStatus.idle,
    this.imageUrl,
    this.errorMessage,
    this.wasRemoved = false,
  });

  ProfileImageState copyWith({
    ProfileImageUploadStatus? status,
    String? imageUrl,
    String? errorMessage,
    bool clearError = false,
    bool clearUrl = false,
    bool? wasRemoved,
  }) {
    return ProfileImageState(
      status: status ?? this.status,
      imageUrl: clearUrl ? null : (imageUrl ?? this.imageUrl),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      wasRemoved: wasRemoved ?? this.wasRemoved,
    );
  }

  bool get isUploading => status == ProfileImageUploadStatus.uploading;
  bool get hasError => status == ProfileImageUploadStatus.error;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

class ProfileImageNotifier extends StateNotifier<ProfileImageState> {
  final ProfileImageRemoteDataSource _dataSource;

  ProfileImageNotifier(this._dataSource) : super(const ProfileImageState());

  void initializeWithUrl(String? url) {
    if (url != null && url.isNotEmpty) {
      state = state.copyWith(
        imageUrl: url,
        status: ProfileImageUploadStatus.success,
        wasRemoved: false,
      );
    }
  }

  Future<void> uploadImage(File imageFile) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = state.copyWith(
        status: ProfileImageUploadStatus.error,
        errorMessage: 'User not authenticated',
      );
      return;
    }

    state = state.copyWith(
      status: ProfileImageUploadStatus.uploading,
      clearError: true,
      wasRemoved: false,
    );

    try {
      final response = await _dataSource.uploadProfileImage(
        imageFile: imageFile,
        userId: uid,
      );

      state = state.copyWith(
        status: ProfileImageUploadStatus.success,
        imageUrl: response.url,
        wasRemoved: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileImageUploadStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void removeImage() {
    if (state.imageUrl != null) {
      _dataSource.deleteProfileImage(state.imageUrl!);
    }
    state = state.copyWith(
      status: ProfileImageUploadStatus.idle,
      clearUrl: true,
      clearError: true,
      wasRemoved: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const ProfileImageState();
  }
}

final profileImageProvider =
    StateNotifierProvider.autoDispose<ProfileImageNotifier, ProfileImageState>(
      (ref) => ProfileImageNotifier(ProfileImageRemoteDataSource()),
    );
