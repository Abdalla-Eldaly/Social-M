import 'package:equatable/equatable.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';
import '../../../domain/entities/post_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileAuthenticated extends ProfileState {
  final User user;
  final List<Post>? posts;
  final String? postsError;

  const ProfileAuthenticated({
    required this.user,
    this.posts,
    this.postsError,
  });

  @override
  List<Object?> get props => [user, posts, postsError];
}

class ProfileGuest extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}