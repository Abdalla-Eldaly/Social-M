// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/authentication/data/auth_data_source/contract/auth_online_date_source.dart'
    as _i66;
import '../../features/authentication/data/auth_data_source/impl/auth_online_date_source_impl.dart'
    as _i790;
import '../../features/authentication/data/auth_repository_impl/auth_repository_impl.dart'
    as _i620;
import '../../features/authentication/domain/auth_repository/auth_repository.dart'
    as _i337;
import '../../features/authentication/domain/usecases/login_usecases.dart'
    as _i959;
import '../../features/authentication/domain/usecases/refresh_usecase.dart'
    as _i928;
import '../../features/authentication/domain/usecases/register_usecases.dart'
    as _i1015;
import '../../features/authentication/presentation/login_screen/login_view_model/login_view_model.dart'
    as _i998;
import '../../features/authentication/presentation/register_screen/register_view_model/register_view_model.dart'
    as _i559;
import '../../features/posts_feature/data/data_source/contract/post_data_source.dart'
    as _i354;
import '../../features/posts_feature/data/data_source/post_data_source_impl.dart'
    as _i891;
import '../../features/posts_feature/domain/repositories/post_repository.dart'
    as _i160;
import '../../features/posts_feature/domain/repositories/post_repository_impl.dart'
    as _i712;
import '../../features/posts_feature/domain/usecases/add_comment_use_case.dart'
    as _i37;
import '../../features/posts_feature/domain/usecases/create_post_use_case.dart'
    as _i334;
import '../../features/posts_feature/domain/usecases/get_posts_use_case.dart'
    as _i252;
import '../../features/posts_feature/domain/usecases/get_single_post_use_case.dart'
    as _i194;
import '../../features/posts_feature/domain/usecases/get_user_followers.dart'
    as _i689;
import '../../features/posts_feature/domain/usecases/get_user_following.dart'
    as _i786;
import '../../features/posts_feature/domain/usecases/get_user_posts.dart'
    as _i1004;
import '../../features/posts_feature/domain/usecases/get_user_use_case.dart'
    as _i881;
import '../../features/posts_feature/domain/usecases/search_hastags_use_case.dart'
    as _i720;
import '../../features/posts_feature/domain/usecases/search_posts_use_case.dart'
    as _i747;
import '../../features/posts_feature/domain/usecases/search_users_use_case.dart'
    as _i610;
import '../../features/posts_feature/presentation/create_post/cubit/create_post_cubit.dart'
    as _i404;
import '../../features/posts_feature/presentation/home_screen/cubit/comment_cubit.dart'
    as _i1058;
import '../../features/posts_feature/presentation/home_screen/cubit/post_cubit.dart'
    as _i271;
import '../../features/posts_feature/presentation/onboarding_screen/cubit/start_cubit.dart'
    as _i168;
import '../../features/posts_feature/presentation/post_details_screen/cubit/post_details_cubit.dart'
    as _i997;
import '../../features/posts_feature/presentation/profile_screen/cubit/profile_cubit.dart'
    as _i102;
import '../../features/posts_feature/presentation/search_screen/cubit/search_cubit.dart'
    as _i832;
import '../config/router/app_router.dart' as _i351;
import '../providers/user_provider.dart' as _i26;
import '../utils/network/api_client.dart' as _i759;
import '../utils/network/connectivity_service.dart' as _i279;
import '../utils/storage/secure_storage.dart' as _i303;
import 'modules/app_router_module.dart' as _i630;
import 'modules/connectivity_plus_module.dart' as _i524;
import 'modules/dio_module.dart' as _i983;
import 'modules/secure_storage_module.dart' as _i590;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appRouterModule = _$AppRouterModule();
    final connectivityModule = _$ConnectivityModule();
    final registerModule = _$RegisterModule();
    final dioModule = _$DioModule();
    gh.lazySingleton<_i351.AppRouter>(() => appRouterModule.appRouter);
    gh.lazySingleton<_i895.Connectivity>(() => connectivityModule.connectivity);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.factory<_i279.ConnectivityService>(
        () => _i279.ConnectivityServiceImpl(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i303.SecureStorage>(
        () => _i303.SecureStorage(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio(gh<_i303.SecureStorage>()));
    gh.factory<_i759.ApiClient>(() => _i759.ApiClient(
          gh<_i361.Dio>(),
          gh<_i303.SecureStorage>(),
        ));
    gh.factory<_i66.DataSource>(() => _i790.DataSourceImpl(
          gh<_i759.ApiClient>(),
          gh<_i279.ConnectivityService>(),
        ));
    gh.factory<_i354.PostDataSource>(() => _i891.PostDataSourceImpl(
          gh<_i759.ApiClient>(),
          gh<_i279.ConnectivityService>(),
        ));
    gh.factory<_i337.Repository>(
        () => _i620.RepositoryImpl(gh<_i66.DataSource>()));
    gh.factory<_i160.PostRepository>(
        () => _i712.PostRepositoryImpl(gh<_i354.PostDataSource>()));
    gh.factory<_i959.LoginUseCase>(
        () => _i959.LoginUseCase(gh<_i337.Repository>()));
    gh.factory<_i928.RefreshTokenUseCase>(
        () => _i928.RefreshTokenUseCase(gh<_i337.Repository>()));
    gh.factory<_i1015.RegisterUseCase>(
        () => _i1015.RegisterUseCase(gh<_i337.Repository>()));
    gh.factory<_i37.AddCommentUseCase>(
        () => _i37.AddCommentUseCase(gh<_i160.PostRepository>()));
    gh.factory<_i334.CreatePostUseCase>(
        () => _i334.CreatePostUseCase(gh<_i160.PostRepository>()));
    gh.factory<_i720.SearchHashTagsUseCase>(
        () => _i720.SearchHashTagsUseCase(gh<_i160.PostRepository>()));
    gh.factory<_i747.SearchPostsUseCase>(
        () => _i747.SearchPostsUseCase(gh<_i160.PostRepository>()));
    gh.factory<_i610.SearchUsersUseCase>(
        () => _i610.SearchUsersUseCase(gh<_i160.PostRepository>()));
    gh.factory<_i559.RegisterViewModel>(
        () => _i559.RegisterViewModel(gh<_i1015.RegisterUseCase>()));
    gh.factory<_i252.GetPostsUseCase>(
        () => _i252.GetPostsUseCase(gh<_i160.PostRepository>()));
    gh.factory<_i1004.GetUserPostsUseCase>(
        () => _i1004.GetUserPostsUseCase(gh<_i160.PostRepository>()));
    gh.factory<_i881.GetUserInfoUseCase>(
        () => _i881.GetUserInfoUseCase(gh<_i160.PostRepository>()));
    gh.factory<_i194.GetSinglePostUseCase>(
        () => _i194.GetSinglePostUseCase(gh<_i160.PostRepository>()));
    gh.factory<_i689.GetUserFollowers>(
        () => _i689.GetUserFollowers(gh<_i160.PostRepository>()));
    gh.factory<_i786.GetUserFollowing>(
        () => _i786.GetUserFollowing(gh<_i160.PostRepository>()));
    gh.factory<_i404.CreatePostCubit>(
        () => _i404.CreatePostCubit(gh<_i334.CreatePostUseCase>()));
    gh.factory<_i168.OnboardingCubit>(() => _i168.OnboardingCubit(
          gh<_i928.RefreshTokenUseCase>(),
          gh<_i303.SecureStorage>(),
        ));
    gh.factory<_i1058.CommentCubit>(
        () => _i1058.CommentCubit(gh<_i37.AddCommentUseCase>()));
    gh.factory<_i832.SearchCubit>(() => _i832.SearchCubit(
          gh<_i747.SearchPostsUseCase>(),
          gh<_i610.SearchUsersUseCase>(),
          gh<_i720.SearchHashTagsUseCase>(),
        ));
    gh.factory<_i998.LoginViewModel>(() => _i998.LoginViewModel(
          gh<_i959.LoginUseCase>(),
          gh<_i928.RefreshTokenUseCase>(),
          gh<_i303.SecureStorage>(),
        ));
    gh.singleton<_i26.UserProvider>(() => _i26.UserProvider(
          gh<_i928.RefreshTokenUseCase>(),
          gh<_i881.GetUserInfoUseCase>(),
          gh<_i303.SecureStorage>(),
        ));
    gh.factory<_i997.PostDetailsCubit>(() => _i997.PostDetailsCubit(
          gh<_i194.GetSinglePostUseCase>(),
          gh<_i37.AddCommentUseCase>(),
          gh<_i26.UserProvider>(),
        ));
    gh.factory<_i102.ProfileCubit>(() => _i102.ProfileCubit(
          gh<_i26.UserProvider>(),
          gh<_i1004.GetUserPostsUseCase>(),
          gh<_i689.GetUserFollowers>(),
          gh<_i786.GetUserFollowing>(),
        ));
    gh.factory<_i271.PostCubit>(() => _i271.PostCubit(
          gh<_i252.GetPostsUseCase>(),
          gh<_i26.UserProvider>(),
        ));
    return this;
  }
}

class _$AppRouterModule extends _i630.AppRouterModule {}

class _$ConnectivityModule extends _i524.ConnectivityModule {}

class _$RegisterModule extends _i590.RegisterModule {}

class _$DioModule extends _i983.DioModule {}
