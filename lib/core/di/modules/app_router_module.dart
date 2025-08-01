import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../../config/router/app_router.dart';

final GetIt getIt = GetIt.instance;

@module
abstract class AppRouterModule {
  @lazySingleton
  AppRouter get appRouter => AppRouter();
}