import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/paginated_posts.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/usecases/add_comment_use_case.dart';
import '../../../domain/usecases/get_posts_use_case.dart';
import 'post_state.dart';

@injectable
class PostCubit extends Cubit<PostState> {
  final GetPostsUseCase _getPostsUseCase;
  final AddCommentUseCase _addCommentUseCase;

  PostCubit(this._getPostsUseCase, this._addCommentUseCase) : super(PostInitial());

  int _pageNumber = 1;
  static const int _pageSize = 10;
  List<Post> _posts = [];

  Future<void> fetchPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      _pageNumber = 1;
      _posts = [];
      emit(const PostLoading(isFirstFetch: true));
    } else if (state is PostLoaded && (state as PostLoaded).hasReachedMax) {
      return; // No more posts to fetch
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
}