import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:social_m_app/core/utils/theme/app_color.dart';
import 'core/config/router/app_router.dart';
import 'core/di/di.dart';
import 'core/providers/user_provider.dart';

void main() async {
  await configureDependencies();
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>(
      create: (context) => getIt<UserProvider>(),
      child: MaterialApp.router(
        title: 'Social M',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            textSelectionTheme: TextSelectionThemeData(
                cursorColor: AppColors.black,
                selectionColor: AppColors.grey.withOpacity(.2),
                selectionHandleColor: AppColors.primary)),
        routerDelegate: getIt<AppRouter>().delegate(),
        routeInformationParser: getIt<AppRouter>().defaultRouteParser(),
      ),
    );
  }
}
