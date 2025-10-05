// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';
// import 'package:social_m_app/features/posts_feature/domain/usecases/get_user_followers.dart';
// import 'package:social_m_app/features/posts_feature/domain/usecases/get_user_following.dart';
// import 'package:social_m_app/features/posts_feature/domain/usecases/get_user_posts.dart';
// import 'package:social_m_app/features/posts_feature/presentation/user_profile_screen/cubit/user_profile_states.dart';
//
//
// @injectable
// class UserProfileCubit extends Cubit<UserProfileState> {
//   final GetUserPostsUseCase _getUserPostsUseCase;
//   final GetUserFollowers _getUserFollowersUseCase;
//   final GetUserFollowing _getUserFollowingUseCase;
//   final GetUserByIdUseCase _getUserByIdUseCase; // Add this dependency
//
//   UserProfileCubit(
//       this._getUserPostsUseCase,
//       this._getUserFollowersUseCase,
//       this._getUserFollowingUseCase,
//       this._getUserByIdUseCase,
//       ) : super(UserProfileInitial());
//
//   Future<void> loadUserProfile(int userId) async {
//     emit(UserProfileLoading());
//
//     try {
//       // First, get the user details
//       final userResult = await _getUserByIdUseCase(userId);
//
//       await userResult.fold(
//             (failure) async => emit(UserProfileError(failure.message)),
//             (user) async {
//           // If user is found, fetch all related data
//           await Future.wait([
//             _fetchUserPosts(userId, user),
//             _fetchUserFollowers(userId, user),
//             _fetchUserFollowing(userId, user),
//           ]);
//         },
//       );
//     } catch (e) {
//       emit(UserProfileError('Failed to load user profile: ${e.toString()}'));
//     }
//   }
//
//   Future<void> _fetchUserPosts(int userId, User user) async {
//     final result = await _getUserPostsUseCase.execute(userId);
//     result.fold(
//           (failure) => emit(UserProfileLoaded(
//         user: user,
//         postsError: failure.message,
//         followers: state is UserProfileLoaded ? (state as UserProfileLoaded).followers : null,
//         followersError: state is UserProfileLoaded ? (state as UserProfileLoaded).followersError : null,
//         following: state is UserProfileLoaded ? (state as UserProfileLoaded).following : null,
//         followingError: state is UserProfileLoaded ? (state as UserProfileLoaded).followingError : null,
//       )),
//           (posts) => emit(UserProfileLoaded(
//         user: user,
//         posts: posts,
//         followers: state is UserProfileLoaded ? (state as UserProfileLoaded).followers : null,
//         followersError: state is UserProfileLoaded ? (state as UserProfileLoaded).followersError : null,
//         following: state is UserProfileLoaded ? (state as UserProfileLoaded).following : null,
//         followingError: state is UserProfileLoaded ? (state as UserProfileLoaded).followingError : null,
//       )),
//     );
//   }
//
//   Future<void> _fetchUserFollowers(int userId, User user) async {
//     final result = await _getUserFollowersUseCase(userId);
//     result.fold(
//           (failure) => emit(UserProfileLoaded(
//         user: user,
//         posts: state is UserProfileLoaded ? (state as UserProfileLoaded).posts : null,
//         postsError: state is UserProfileLoaded ? (state as UserProfileLoaded).postsError : null,
//         followersError: failure.message,
//         following: state is UserProfileLoaded ? (state as UserProfileLoaded).following : null,
//         followingError: state is UserProfileLoaded ? (state as UserProfileLoaded).followingError : null,
//       )),
//           (followers) => emit(UserProfileLoaded(
//         user: user,
//         posts: state is UserProfileLoaded ? (state as UserProfileLoaded).posts : null,
//         postsError: state is UserProfileLoaded ? (state as UserProfileLoaded).postsError : null,
//         followers: followers,
//         following: state is UserProfileLoaded ? (state as UserProfileLoaded).following : null,
//         followingError: state is UserProfileLoaded ? (state as UserProfileLoaded).followingError : null,
//       )),
//     );
//   }
//
//   Future<void> _fetchUserFollowing(int userId, User user) async {
//     final result = await _getUserFollowingUseCase(userId);
//     result.fold(
//           (failure) => emit(UserProfileLoaded(
//         user: user,
//         posts: state is UserProfileLoaded ? (state as UserProfileLoaded).posts : null,
//         postsError: state is UserProfileLoaded ? (state as UserProfileLoaded).postsError : null,
//         followers: state is UserProfileLoaded ? (state as UserProfileLoaded).followers : null,
//         followersError: state is UserProfileLoaded ? (state as UserProfileLoaded).followersError : null,
//         followingError: failure.message,
//       )),
//           (following) => emit(UserProfileLoaded(
//         user: user,
//         posts: state is UserProfileLoaded ? (state as UserProfileLoaded).posts : null,
//         postsError: state is UserProfileLoaded ? (state as UserProfileLoaded).postsError : null,
//         followers: state is UserProfileLoaded ? (state as UserProfileLoaded).followers : null,
//         followersError: state is UserProfileLoaded ? (state as UserProfileLoaded).followersError : null,
//         following: following,
//       )),
//     );
//   }
//
//   Future<void> refreshUserProfile(int userId) async {
//     await loadUserProfile(userId);
//   }
//
//   void clearProfile() {
//     emit(UserProfileInitial());
//   }
// }