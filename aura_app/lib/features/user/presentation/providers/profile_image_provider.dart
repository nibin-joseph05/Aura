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
  final int? uploadedAt;

  const ProfileImageState({
    this.status = ProfileImageUploadStatus.idle,
    this.imageUrl,
    this.errorMessage,
    this.wasRemoved = false,
    this.uploadedAt,
  });

  ProfileImageState copyWith({
    ProfileImageUploadStatus? status,
    String? imageUrl,
    String? errorMessage,
    bool clearError = false,
    bool clearUrl = false,
    bool? wasRemoved,
    int? uploadedAt,
  }) {
    return ProfileImageState(
      status: status ?? this.status,
      imageUrl: clearUrl ? null : (imageUrl ?? this.imageUrl),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      wasRemoved: wasRemoved ?? this.wasRemoved,
      uploadedAt: uploadedAt ?? this.uploadedAt,
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
    String uid =
        FirebaseAuth.instance.currentUser?.uid ??
        'temp_${DateTime.now().millisecondsSinceEpoch}';

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
        uploadedAt: DateTime.now().millisecondsSinceEpoch,
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
    state = const ProfileImageState(wasRemoved: true);
  }
}

final profileImageProvider =
    StateNotifierProvider.autoDispose<ProfileImageNotifier, ProfileImageState>(
      (ref) => ProfileImageNotifier(ProfileImageRemoteDataSource()),
    );
