import 'package:equatable/equatable.dart';
import '../../../../../core/utils/network/network_exception.dart';
import '../../../domain/entities/paginated_posts.dart';
import '../../../domain/entities/post_entity.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {
  final bool isFirstFetch;

  const PostLoading({this.isFirstFetch = false});

  @override
  List<Object?> get props => [isFirstFetch];
}

class PostLoadingMore extends PostState {
  final List<Post> currentPosts;

  const PostLoadingMore({required this.currentPosts});

  @override
  List<Object?> get props => [currentPosts];
}

class PostLoaded extends PostState {
  final PaginatedPosts paginatedPosts;
  final bool hasReachedMax;

  const PostLoaded({
    required this.paginatedPosts,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [paginatedPosts, hasReachedMax];
}

class PostError extends PostState {
  final NetworkException failure;
  final List<Post> currentPosts;

  const PostError(this.failure, {this.currentPosts = const []});

  String get message => failure.message;

  @override
  List<Object?> get props => [failure, currentPosts];
}