// post_details_states.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/entities/comment.dart';

abstract class PostDetailsState extends Equatable {
  const PostDetailsState();

  @override
  List<Object?> get props => [];
}

class PostDetailsInitial extends PostDetailsState {}

class PostDetailsLoading extends PostDetailsState {}

class PostDetailsLoaded extends PostDetailsState {
  final Post post;
  final bool isLiked;
  final bool isBookmarked;
  final bool isFollowing;
  final int currentImageIndex;
  final List<Comment> pendingComments; // For optimistic updates
  final Set<int> pendingCommentIds; // Track which comments are pending
  final bool isAddingComment; // For comment input state
  final bool isRefreshing; // For pull-to-refresh without full reload

  const PostDetailsLoaded({
    required this.post,
    this.isLiked = false,
    this.isBookmarked = false,
    this.isFollowing = false,
    this.currentImageIndex = 0,
    this.pendingComments = const [],
    this.pendingCommentIds = const {},
    this.isAddingComment = false,
    this.isRefreshing = false,
  });

  // Get combined comments (original + pending)
  List<Comment> get allComments {
    final originalComments = post.comments ?? [];
    return [...originalComments, ...pendingComments];
  }

  // Get total comment count including pending
  int get totalCommentCount {
    final originalCount = (post.comments?.length ?? 0);
    return originalCount + pendingComments.length;
  }

  // Check if a comment is pending
  bool isCommentPending(int commentId) {
    return pendingCommentIds.contains(commentId);
  }

  PostDetailsLoaded copyWith({
    Post? post,
    bool? isLiked,
    bool? isBookmarked,
    bool? isFollowing,
    int? currentImageIndex,
    List<Comment>? pendingComments,
    Set<int>? pendingCommentIds,
    bool? isAddingComment,
    bool? isRefreshing,
  }) {
    return PostDetailsLoaded(
      post: post ?? this.post,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFollowing: isFollowing ?? this.isFollowing,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      pendingComments: pendingComments ?? this.pendingComments,
      pendingCommentIds: pendingCommentIds ?? this.pendingCommentIds,
      isAddingComment: isAddingComment ?? this.isAddingComment,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    post,
    isLiked,
    isBookmarked,
    isFollowing,
    currentImageIndex,
    pendingComments,
    pendingCommentIds,
    isAddingComment,
    isRefreshing,
  ];
}

class PostDetailsError extends PostDetailsState {
  final String message;

  const PostDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

// New state for handling comment errors without disrupting the main UI
class PostDetailsCommentError extends PostDetailsLoaded {
  final String errorMessage;
  final String failedCommentText; // To restore the text input

  const PostDetailsCommentError({
    required Post post,
    required this.errorMessage,
    required this.failedCommentText,
    bool isLiked = false,
    bool isBookmarked = false,
    bool isFollowing = false,
    int currentImageIndex = 0,
    List<Comment> pendingComments = const [],
    Set<int> pendingCommentIds = const {},
    bool isRefreshing = false,
  }) : super(
    post: post,
    isLiked: isLiked,
    isBookmarked: isBookmarked,
    isFollowing: isFollowing,
    currentImageIndex: currentImageIndex,
    pendingComments: pendingComments,
    pendingCommentIds: pendingCommentIds,
    isRefreshing: isRefreshing,
  );

  @override
  List<Object?> get props => [...super.props, errorMessage, failedCommentText];
}