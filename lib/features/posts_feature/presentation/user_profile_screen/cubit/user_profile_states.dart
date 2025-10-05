import 'package:equatable/equatable.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';
import '../../../domain/entities/post_entity.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final User user;
  final List<Post>? posts;
  final String? postsError;
  final List<User>? followers;
  final String? followersError;
  final List<User>? following;
  final String? followingError;

  const UserProfileLoaded({
    required this.user,
    this.posts,
    this.postsError,
    this.followers,
    this.followersError,
    this.following,
    this.followingError,
  });

  @override
  List<Object?> get props => [
    user,
    posts,
    postsError,
    followers,
    followersError,
    following,
    followingError,
  ];
}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError(this.message);

  @override
  List<Object?> get props => [message];
}