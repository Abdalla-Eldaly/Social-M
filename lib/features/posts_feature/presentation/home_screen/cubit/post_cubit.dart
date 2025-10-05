import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/utils/network/network_exception.dart';
import '../../../domain/entities/comment.dart';
import '../../../domain/entities/paginated_posts.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/usecases/get_posts_use_case.dart';
import 'post_state.dart';

@injectable
class PostCubit extends Cubit<PostState> {
  final GetPostsUseCase getPostsUseCase;
  final UserProvider userProvider; // Add UserProvider dependency

  PostCubit(this.getPostsUseCase, this.userProvider) : super(PostInitial());

  int _pageNumber = 1;
  static const int _pageSize = 10;
  List<Post> _posts = [];

  Future<void> fetchPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      _pageNumber = 1;
      _posts = [];
      emit(const PostLoading(isFirstFetch: true));
    } else if (state is PostLoaded && (state as PostLoaded).hasReachedMax) {
      return;
    } else if (state is PostLoaded) {
      emit(PostLoadingMore(currentPosts: _posts));
    } else if (state is PostError) {
      emit(const PostLoading(isFirstFetch: true));
    }

    // Ensure valid token before fetching posts (handles guest/authenticated users)
    final isTokenValid = await userProvider.ensureValidToken();
    if (!isTokenValid && !userProvider.isGuest) {
      emit(PostError(
        const NetworkException(message: 'Authentication failed'),
        currentPosts: _posts,
      ));
      return;
    }

    final result = await getPostsUseCase.execute(
      GetPostsInput(pageNumber: _pageNumber, pageSize: _pageSize),
    );

    result.fold(
          (failure) => emit(PostError(failure, currentPosts: _posts)),
          (paginatedPosts) {
        final newPosts = paginatedPosts.items ?? [];
        // Optionally enrich posts with current user info (e.g., for isLikedByUser)
        final enrichedPosts = newPosts.map((post) {
          return Post(
            id: post.id,
            caption: post.caption,
            imageUrl: post.imageUrl,
            createdAt: post.createdAt,
            user: post.user, // User info should come from GetPostsUseCase
            comments: post.comments,
            likesCount: post.likesCount,
            isLikedByUser: _checkIfLikedByUser(post), // Custom logic
          );
        }).toList();

        _posts = isRefresh ? enrichedPosts : [..._posts, ...enrichedPosts];
        _pageNumber++;
        emit(PostLoaded(
          paginatedPosts: PaginatedPosts(
            items: _posts,
            currentPage: paginatedPosts.currentPage,
            pageSize: paginatedPosts.pageSize,
            totalCount: paginatedPosts.totalCount,
          ),
          hasReachedMax: newPosts.length < _pageSize ||
              (paginatedPosts.totalCount != null &&
                  _posts.length >= paginatedPosts.totalCount!),
        ));
      },
    );
  }

  // Helper method to check if the current user liked the post
  bool _checkIfLikedByUser(Post post) {
    if (userProvider.isGuest) return false;
    // Example: Check if the current user's ID matches any likes
    // This assumes the backend provides like information or you fetch it separately
    // Modify based on your Post entity and backend API
    return post.isLikedByUser ?? false; // Fallback to existing value
  }

  Future<void> retryFetchPosts() async {
    await fetchPosts(isRefresh: true);
  }

  void updatePostWithNewComment(int postId, Comment newComment) {
    final updatedPosts = _posts.map((post) {
      if (post.id == postId) {
        return Post(
          id: post.id,
          caption: post.caption,
          imageUrl: post.imageUrl,
          createdAt: post.createdAt,
          user: post.user,
          comments: [...(post.comments ?? []), newComment],
          likesCount: post.likesCount,
          isLikedByUser: post.isLikedByUser,
        );
      }
      return post;
    }).toList();

    _posts = updatedPosts;

    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      emit(PostLoaded(
        paginatedPosts: PaginatedPosts(
          items: _posts,
          currentPage: currentState.paginatedPosts.currentPage,
          pageSize: currentState.paginatedPosts.pageSize,
          totalCount: currentState.paginatedPosts.totalCount,
        ),
        hasReachedMax: currentState.hasReachedMax,
      ));
    }
  }

  void togglePostLike(int postId, bool isLiked) {
    if (userProvider.isGuest) return; // Prevent guests from liking

    final updatedPosts = _posts.map((post) {
      if (post.id == postId) {
        return Post(
          id: post.id,
          caption: post.caption,
          imageUrl: post.imageUrl,
          createdAt: post.createdAt,
          user: post.user,
          comments: post.comments,
          likesCount: isLiked
              ? (post.likesCount ?? 0) + 1
              : (post.likesCount ?? 1) - 1,
          isLikedByUser: isLiked,
        );
      }
      return post;
    }).toList();

    _posts = updatedPosts;

    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      emit(PostLoaded(
        paginatedPosts: PaginatedPosts(
          items: _posts,
          currentPage: currentState.paginatedPosts.currentPage,
          pageSize: currentState.paginatedPosts.pageSize,
          totalCount: currentState.paginatedPosts.totalCount,
        ),
        hasReachedMax: currentState.hasReachedMax,
      ));
    }
  }

  void clearPosts() {
    _pageNumber = 1;
    _posts = [];
    emit(PostInitial());
  }
}