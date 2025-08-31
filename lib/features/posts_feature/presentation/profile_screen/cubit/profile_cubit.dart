import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/core/providers/user_provider.dart';
import 'package:social_m_app/features/posts_feature/domain/usecases/get_user_followers.dart';
import 'package:social_m_app/features/posts_feature/domain/usecases/get_user_following.dart';
import 'package:social_m_app/features/posts_feature/domain/usecases/get_user_posts.dart';
import 'package:social_m_app/features/posts_feature/presentation/profile_screen/cubit/posts_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final UserProvider _userProvider;
  final GetUserPostsUseCase _getUserPostsUseCase;
  final GetUserFollowers _getUserFollowersUseCase;
  final GetUserFollowing _getUserFollowingUseCase;

  ProfileCubit(
      this._userProvider,
      this._getUserPostsUseCase,
      this._getUserFollowersUseCase,
      this._getUserFollowingUseCase,
      ) : super(ProfileInitial()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }

  Future<void> initialize() async {
    emit(ProfileLoading());
    await _userProvider.initializeAuth();

    if (_userProvider.isAuthenticated && _userProvider.currentUser != null) {
      final userId = _userProvider.currentUser!.id ?? -1;
      await Future.wait([
        _fetchUserPosts(userId),
        _fetchUserFollowers(userId),
        _fetchUserFollowing(userId),
      ]);
    } else if (_userProvider.isGuest) {
      emit(ProfileGuest());
    } else if (_userProvider.errorMessage != null) {
      emit(ProfileError(_userProvider.errorMessage!));
    } else {
      emit(ProfileGuest());
    }
  }

  Future<void> _fetchUserPosts(int userId) async {
    final result = await _getUserPostsUseCase.execute(userId);
    result.fold(
          (failure) => emit(ProfileAuthenticated(
        user: _userProvider.currentUser!,
        postsError: failure.message,
        followers: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followers : null,
        followersError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followersError : null,
        following: state is ProfileAuthenticated ? (state as ProfileAuthenticated).following : null,
        followingError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followingError : null,
      )),
          (posts) => emit(ProfileAuthenticated(
        user: _userProvider.currentUser!,
        posts: posts,
        followers: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followers : null,
        followersError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followersError : null,
        following: state is ProfileAuthenticated ? (state as ProfileAuthenticated).following : null,
        followingError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followingError : null,
      )),
    );
  }

  Future<void> _fetchUserFollowers(int userId) async {
    final result = await _getUserFollowersUseCase(userId);
    result.fold(
          (failure) => emit(ProfileAuthenticated(
        user: _userProvider.currentUser!,
        posts: state is ProfileAuthenticated ? (state as ProfileAuthenticated).posts : null,
        postsError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).postsError : null,
        followersError: failure.message,
        following: state is ProfileAuthenticated ? (state as ProfileAuthenticated).following : null,
        followingError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followingError : null,
      )),
          (followers) => emit(ProfileAuthenticated(
        user: _userProvider.currentUser!,
        posts: state is ProfileAuthenticated ? (state as ProfileAuthenticated).posts : null,
        postsError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).postsError : null,
        followers: followers,
        following: state is ProfileAuthenticated ? (state as ProfileAuthenticated).following : null,
        followingError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followingError : null,
      )),
    );
  }

  Future<void> _fetchUserFollowing(int userId) async {
    final result = await _getUserFollowingUseCase(userId);
    result.fold(
          (failure) => emit(ProfileAuthenticated(
        user: _userProvider.currentUser!,
        posts: state is ProfileAuthenticated ? (state as ProfileAuthenticated).posts : null,
        postsError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).postsError : null,
        followers: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followers : null,
        followersError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followersError : null,
        followingError: failure.message,
      )),
          (following) => emit(ProfileAuthenticated(
        user: _userProvider.currentUser!,
        posts: state is ProfileAuthenticated ? (state as ProfileAuthenticated).posts : null,
        postsError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).postsError : null,
        followers: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followers : null,
        followersError: state is ProfileAuthenticated ? (state as ProfileAuthenticated).followersError : null,
        following: following,
      )),
    );
  }

  Future<void> refreshUserData() async {
    emit(ProfileLoading());
    await _userProvider.refreshUserData();

    if (_userProvider.isAuthenticated && _userProvider.currentUser != null) {
      final userId = _userProvider.currentUser!.id ?? -1;
      await Future.wait([
        _fetchUserPosts(userId),
        _fetchUserFollowers(userId),
        _fetchUserFollowing(userId),
      ]);
    } else if (_userProvider.isGuest) {
      emit(ProfileGuest());
    } else if (_userProvider.errorMessage != null) {
      emit(ProfileError(_userProvider.errorMessage!));
    } else {
      emit(ProfileGuest());
    }
  }

  Future<void> logout() async {
    emit(ProfileLoading());
    await _userProvider.logout();
    emit(ProfileGuest());
  }
}