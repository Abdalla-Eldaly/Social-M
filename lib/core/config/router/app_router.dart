import 'package:auto_route/auto_route.dart';
import '../../../features/authentication/presentation/login_screen/view/login_view.dart';
import '../../../features/authentication/presentation/register_screen/view/register_view.dart';
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
      initial: true,
      path: '/login',
    ),
    AutoRoute(
      page: RegisterRoute.page,
      path: '/register',
    ),


  ];
}