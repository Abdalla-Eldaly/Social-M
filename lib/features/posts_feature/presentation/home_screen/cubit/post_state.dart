 import 'package:equatable/equatable.dart';
import 'package:social_m_app/core/utils/network/network_exception.dart';

import '../../../domain/entities/paginated_posts.dart';


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

  const PostError(this.failure);

  @override
  List<Object?> get props => [failure];
}