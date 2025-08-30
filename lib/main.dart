import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/config/router/app_router.dart';
import 'core/di/di.dart';
import 'core/providers/user_provider.dart';

void main() async {
  await configureDependencies();
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

        routerDelegate: getIt<AppRouter>().delegate(),
        routeInformationParser: getIt<AppRouter>().defaultRouteParser(),
      ),
    );
  }
}