import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../model/comment_model.dart';

final commentsProvider =
    StateNotifierProvider.family<CommentsNotifier, CommentsState, String>(
      (ref, postId) => CommentsNotifier(postId),
    );

class CommentsState {
  final List<CommentModel> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;

  CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
  });

  CommentsState copyWith({
    List<CommentModel>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  final String postId;
  final ApiClient _apiClient = ApiClient();

  CommentsNotifier(this.postId) : super(CommentsState());

  Future<void> loadComments() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiClient.get('/api/wellness/$postId/comments');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        final comments = data
            .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
            .toList();
        state = state.copyWith(comments: comments, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load comments',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addComment(String content) async {
    try {
      final response = await _apiClient.post(
        '/api/wellness/$postId/comments',
        body: {'content': content},
      );
      if (response['success'] == true && response['data'] != null) {
        final comment = CommentModel.fromJson(
          response['data'] as Map<String, dynamic>,
        );
        state = state.copyWith(comments: [comment, ...state.comments]);
        return true;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
    return false;
  }

  Future<void> translateComment(String commentId) async {
    try {
      final response = await _apiClient.post(
        '/api/wellness/comments/$commentId/translate',
      );
      if (response['success'] == true && response['data'] != null) {
        final updated = CommentModel.fromJson(
          response['data'] as Map<String, dynamic>,
        );
        final updatedList = state.comments.map((c) {
          if (c.id == commentId) return updated;
          return c;
        }).toList();
        state = state.copyWith(comments: updatedList);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
