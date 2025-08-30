import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/core/providers/user_provider.dart';
import 'package:social_m_app/features/posts_feature/presentation/profile_screen/cubit/posts_state.dart';
import '../../../domain/usecases/get_user_posts.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final UserProvider _userProvider;
  final GetUserPostsUseCase _getUserPostsUseCase;

  ProfileCubit(this._userProvider, this._getUserPostsUseCase)
      : super(ProfileInitial()) {
     WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }

  Future<void> initialize() async {
    emit(ProfileLoading());
    await _userProvider.initializeAuth();

    if (_userProvider.isAuthenticated && _userProvider.currentUser != null) {
      await _fetchUserPosts(_userProvider.currentUser!.id ?? -1);
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
      )),
          (posts) => emit(ProfileAuthenticated(
        user: _userProvider.currentUser!,
        posts: posts,
      )),
    );
  }

  Future<void> refreshUserData() async {
    emit(ProfileLoading());
    await _userProvider.refreshUserData();

    if (_userProvider.isAuthenticated && _userProvider.currentUser != null) {
      await _fetchUserPosts(_userProvider.currentUser!.id ?? -1);
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