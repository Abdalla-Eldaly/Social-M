import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/comment.dart';
import '../../../domain/entities/paginated_posts.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/usecases/get_posts_use_case.dart';
import 'post_state.dart';



@injectable
class PostCubit extends Cubit<PostState> {
  final GetPostsUseCase _getPostsUseCase;

  PostCubit(this._getPostsUseCase) : super(PostInitial());

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

    final result = await _getPostsUseCase.execute(
      GetPostsInput(pageNumber: _pageNumber, pageSize: _pageSize),
    );

    result.fold(
          (failure) => emit(PostError(failure, currentPosts: _posts)),
          (paginatedPosts) {
        final newPosts = paginatedPosts.items ?? [];
        _posts = isRefresh ? newPosts : [..._posts, ...newPosts];
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
        );
      }
      return post;
    }).toList();

    _posts = updatedPosts;

    emit(PostLoaded(
      paginatedPosts: PaginatedPosts(
        items: _posts,
        currentPage: 1,
        pageSize: _posts.length,
        totalCount: _posts.length,
      ),
      hasReachedMax: false,
    ));
  }
}
