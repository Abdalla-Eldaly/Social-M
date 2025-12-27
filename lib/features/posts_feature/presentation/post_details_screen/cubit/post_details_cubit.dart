// post_details_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/core/providers/user_provider.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/comment.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';
import 'package:social_m_app/features/posts_feature/domain/usecases/add_comment_use_case.dart';
import '../../../../../core/utils/Functions/unauthorized_handler.dart';
import '../../../domain/usecases/get_single_post_use_case.dart';
import 'post_details_states.dart';

@injectable
class PostDetailsCubit extends Cubit<PostDetailsState> {
  final GetSinglePostUseCase getSinglePostUseCase;
  final AddCommentUseCase addCommentUseCase;
  final UserProvider userProvider;

  // Add context for unauthorized handling
  BuildContext? _context;

  PostDetailsCubit(
      this.getSinglePostUseCase,
      this.addCommentUseCase,
      this.userProvider,
      ) : super(PostDetailsInitial());

  // Set context for unauthorized handling
  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> loadPostDetails(int postId) async {
    emit(PostDetailsLoading());

    final result = await getSinglePostUseCase.execute(postId);

    result.fold(
          (failure) => emit(PostDetailsError(failure.message)),
          (post) => emit(PostDetailsLoaded(
        post: post,
        isLiked: post.isLikedByUser ?? false,
        isFollowing: post.user?.isFollowedByUser ?? false,
      )),
    );
  }

  void changeImageIndex(int index) {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      emit(currentState.copyWith(currentImageIndex: index));
    }
  }

  Future<void> toggleLike() async {
    if (_context == null) return;

    final isAuthorized = await UnauthorizedHandler.checkAuthorizationForAction(
      _context!,
      action: 'like this post',
      onLoginSuccess: () => toggleLike(),
      requiresAuth: true,
    );

    if (!isAuthorized) return;

    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      // Optimistic update - update like count too
      final newLikesCount = currentState.isLiked
          ? (currentState.post.likesCount ?? 1) - 1
          : (currentState.post.likesCount ?? 0) + 1;

      final updatedPost = currentState.post.copyWith(
        likesCount: newLikesCount,
        isLikedByUser: !currentState.isLiked,
      );

      emit(currentState.copyWith(
        post: updatedPost,
        isLiked: !currentState.isLiked,
      ));

      // TODO: Implement like/unlike API call
      // final result = await likePostUseCase.execute(currentState.post.id);
      // Handle result and revert if failed...
    }
  }

  Future<void> toggleBookmark() async {
    if (_context == null) return;

    final isAuthorized = await UnauthorizedHandler.checkAuthorizationForAction(
      _context!,
      action: 'bookmark this post',
      onLoginSuccess: () => toggleBookmark(),
      requiresAuth: true,
    );

    if (!isAuthorized) return;

    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      // Optimistic update
      emit(currentState.copyWith(isBookmarked: !currentState.isBookmarked));

      // TODO: Implement bookmark/unbookmark API call
      // final result = await bookmarkPostUseCase.execute(currentState.post.id);
      // Handle result and revert if failed...
    }
  }

  Future<void> toggleFollow() async {
    if (_context == null) return;

    final isAuthorized = await UnauthorizedHandler.checkAuthorizationForAction(
      _context!,
      action: 'follow this user',
      onLoginSuccess: () => toggleFollow(),
      requiresAuth: true,
    );

    if (!isAuthorized) return;

    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      // Optimistic update
      emit(currentState.copyWith(isFollowing: !currentState.isFollowing));

      // TODO: Implement follow/unfollow API call
      // final result = await followUserUseCase.execute(currentState.post.user?.id);
      // Handle result and revert if failed...
    }
  }

  Future<void> addComment(String commentText) async {
    if (_context == null) return;

    final currentState = state;
    if (currentState is! PostDetailsLoaded) return;

    // Check authorization with proper error handling
    final isAuthorized = await UnauthorizedHandler.checkAuthorizationForAction(
      _context!,
      action: 'add a comment',
      onLoginSuccess: () => addComment(commentText),
      requiresAuth: true,
    );

    if (!isAuthorized) return;

    // Set comment adding state (for UI feedback like disabling send button briefly)
    emit(currentState.copyWith(isAddingComment: true));

    // Create pending comment with negative ID to distinguish from server comments
    final pendingCommentId = -DateTime.now().millisecondsSinceEpoch;
    final pendingComment = Comment(
      id: pendingCommentId,
      content: commentText,
      createdAt: DateTime.now(),
      user: userProvider.currentUser ?? _createGuestUser(),
    );

    // Add pending comment to the list
    final newPendingComments = [
      ...currentState.pendingComments,
      pendingComment,
    ];

    final newPendingIds = {
      ...currentState.pendingCommentIds,
      pendingCommentId,
    };

    // Emit state with pending comment
    emit(currentState.copyWith(
      pendingComments: newPendingComments,
      pendingCommentIds: newPendingIds,
      isAddingComment: false,
    ));

    // Make the actual API call
    final result = await addCommentUseCase.execute(commentText, currentState.post.id!);

    result.fold(
          (failure) {
        // Check if it's an unauthorized error
        if (_isUnauthorizedError(failure.message)) {
          // Remove pending comment first
          final filteredComments = currentState.pendingComments
              .where((comment) => comment.id != pendingCommentId)
              .toList();

          final filteredIds = Set<int>.from(currentState.pendingCommentIds)
            ..remove(pendingCommentId);

          emit(currentState.copyWith(
            pendingComments: filteredComments,
            pendingCommentIds: filteredIds,
          ));

          // Handle unauthorized error with dialog
          UnauthorizedHandler.handleUnauthorizedError(
            _context!,
            action: 'add a comment',
            onLoginSuccess: () => addComment(commentText),
          );
        } else {
          // Handle other errors normally
          final filteredComments = currentState.pendingComments
              .where((comment) => comment.id != pendingCommentId)
              .toList();

          final filteredIds = Set<int>.from(currentState.pendingCommentIds)
            ..remove(pendingCommentId);

          emit(PostDetailsCommentError(
            post: currentState.post,
            errorMessage: failure.message,
            failedCommentText: commentText,
            isLiked: currentState.isLiked,
            isBookmarked: currentState.isBookmarked,
            isFollowing: currentState.isFollowing,
            currentImageIndex: currentState.currentImageIndex,
            pendingComments: filteredComments,
            pendingCommentIds: filteredIds,
          ));
        }
      },
          (newComment) {
        // SUCCESS: Replace pending comment with actual comment from server
        _handleSuccessfulComment(pendingCommentId, newComment);
      },
    );
  }

  Future<void> sharePost() async {
    if (_context == null) return;

    // Sharing doesn't require auth, but you can add it if needed
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      // TODO: Implement share functionality
      // Share.share('Check out this post: ${currentState.post.caption}');
    }
  }

  Future<void> reportPost() async {
    if (_context == null) return;

    final isAuthorized = await UnauthorizedHandler.checkAuthorizationForAction(
      _context!,
      action: 'report this post',
      onLoginSuccess: () => reportPost(),
      requiresAuth: true,
    );

    if (!isAuthorized) return;

    // TODO: Implement report functionality
    // final result = await reportPostUseCase.execute(postId);
  }

  // Helper method to check if error is unauthorized
  bool _isUnauthorizedError(String errorMessage) {
    final unauthorizedKeywords = [
      'unauthorized',
      'unauthenticated',
      '401',
      'token expired',
      'invalid token',
      'authentication required',
    ];

    final lowerError = errorMessage.toLowerCase();
    return unauthorizedKeywords.any((keyword) => lowerError.contains(keyword));
  }

  // IMPROVED: Instead of reloading entire post, just update the comments
  void _handleSuccessfulComment(int pendingCommentId, Comment newComment) {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      // Remove the pending comment
      final filteredPendingComments = currentState.pendingComments
          .where((comment) => comment.id != pendingCommentId)
          .toList();

      final filteredPendingIds = Set<int>.from(currentState.pendingCommentIds)
        ..remove(pendingCommentId);

      // Add the new comment to the post's comment list
      final currentComments = currentState.post.comments ?? [];
      final updatedComments = [...currentComments, newComment];

      // Update the post with new comment list and increment comment count
      final updatedPost = currentState.post.copyWith(
        comments: updatedComments,

        commentsCount: (currentState.post.comments?.length ?? 0) + 1,
      );

      // Emit updated state with new comment - NO RELOAD!
      emit(currentState.copyWith(
        post: updatedPost,
        pendingComments: filteredPendingComments,
        pendingCommentIds: filteredPendingIds,
      ));
    }
  }

  void clearCommentError() {
    final currentState = state;
    if (currentState is PostDetailsCommentError) {
      emit(PostDetailsLoaded(
        post: currentState.post,
        isLiked: currentState.isLiked,
        isBookmarked: currentState.isBookmarked,
        isFollowing: currentState.isFollowing,
        currentImageIndex: currentState.currentImageIndex,
        pendingComments: currentState.pendingComments,
        pendingCommentIds: currentState.pendingCommentIds,
      ));
    }
  }

  void retryFailedComment(String commentText) {
    clearCommentError();
    addComment(commentText);
  }

  User _createGuestUser() {
    return User(
      id: -1,
      username: 'Guest',
      email: 'guest@app.com',
      profileImageUrl: null,
    );
  }

  // IMPROVED: Only refresh when explicitly needed (like pull-to-refresh)
  Future<void> refreshPost() async {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      // Show loading indicator but keep current data visible
      emit(currentState.copyWith(isRefreshing: true));

      final result = await getSinglePostUseCase.execute(currentState.post.id ?? -1);

      result.fold(
            (failure) {
          // Keep current state but remove loading indicator
          emit(currentState.copyWith(isRefreshing: false));
          // Could show a snackbar with error message
        },
            (refreshedPost) {
          // Update with fresh data
          emit(currentState.copyWith(
            post: refreshedPost,
            isRefreshing: false,
            // Reset pending comments since we got fresh data
            pendingComments: [],
            pendingCommentIds: {},
          ));
        },
      );
    }
  }
}