 import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
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
    } else {
      emit(const PostLoading());
    }

    final result = await _getPostsUseCase.execute(
      GetPostsInput(pageNumber: _pageNumber, pageSize: _pageSize),
    );

    result.fold(
          (failure) => emit(PostError(failure)),
          (paginatedPosts) {
        _posts.addAll(paginatedPosts.items ?? []);
        _pageNumber++;
        emit(PostLoaded(
          paginatedPosts: PaginatedPosts(
            items: _posts,
            currentPage: paginatedPosts.currentPage,
            pageSize: paginatedPosts.pageSize,
            totalCount: paginatedPosts.totalCount,
          ),
          hasReachedMax: (paginatedPosts.items?.length ?? 0) < _pageSize ||
              (paginatedPosts.totalCount != null &&
                  _posts.length >= paginatedPosts.totalCount!),
        ));
      },
    );
  }
}