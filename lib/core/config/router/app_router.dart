import 'package:auto_route/auto_route.dart';
import '../../../features/authentication/presentation/login_screen/view/login_view.dart';
import '../../../features/authentication/presentation/register_screen/view/register_view.dart';
import '../../../features/posts_feature/presentation/create_post/view/create_post_screen.dart';
import '../../../features/posts_feature/presentation/home_screen/view/home_screen.dart';
import '../../../features/posts_feature/presentation/main_lay_out/view/main_lay_out_screen.dart';
import '../../../features/posts_feature/presentation/profile_screen/view/profile_screen.dart';
import '../../../features/posts_feature/presentation/story_screen/view/story_screen.dart';
import '../../utils/theme/app_dialogs.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View|Widget,Route')
class AppRouter extends RootStackRouter {
  AppRouter() : super(navigatorKey: AppDialogs.navigatorKey);

  @override
  List<AutoRoute> get routes => [
    // Authentications
    AutoRoute(
      page: LoginRoute.page,
      type: const RouteType.adaptive(opaque: true),
      path: '/login',
    ),
    AutoRoute(
      page: RegisterRoute.page,
      path: '/register',
      type: const RouteType.adaptive(opaque: true),

    ),

    AutoRoute(
      page: MainLayoutRoute.page,
      path: '/mainLayoutRoute',
      initial: true,

      // guards: [AuthGuard()],
      children: [
        AutoRoute(
          page: HomeRoute.page,
          path: 'home',
        ),
        AutoRoute(
          page: CreatePostRoute.page,
          path: 'createPostRoute',
        ),
        AutoRoute(
          page: StoryRoute.page,
          path: 'storyRoute',
        ),
        AutoRoute(
          page: ProfileRoute.page,
          path: 'profile',
        ),
      ],
    ),
  ];
}