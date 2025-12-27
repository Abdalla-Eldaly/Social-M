import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/utils/navigation/animated_page_wrapper.dart';
import '../login_view_model/login_view_model.dart';
import 'login_body.dart';

@RoutePage(name: 'LoginRoute')
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginViewModel>(),
      child: const AnimatedPageWrapper(
        transitionType: PageTransitionType.slideFromBottom,
        duration: Duration(milliseconds: 300),
        child: Scaffold(
          body: LoginBody(),
        ),
      ),
    );
  }
}