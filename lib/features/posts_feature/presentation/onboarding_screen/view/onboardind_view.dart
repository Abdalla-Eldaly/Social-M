import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:social_m_app/core/config/router/app_router.dart';
import 'package:social_m_app/core/utils/theme/app_images.dart';
import '../../../../../core/di/di.dart';
import '../cubit/start_cubit.dart';
import '../cubit/start_states.dart';


@RoutePage()
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OnboardingCubit>()..initializeOnboarding(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: BlocConsumer<OnboardingCubit, OnboardingState>(
          listener: (context, state) {
            // Handle navigation based on state
            switch (state.status) {
              case AuthStatus.authenticated:
                context.router.replace(const MainLayoutRoute());
                break;
              case AuthStatus.unauthenticated:
                context.router.replace(const LoginRoute());
                break;
              case AuthStatus.guest:
                context.router.replace(const MainLayoutRoute());

                break;
              default:
                break;
            }
          },
          builder: (context, state) {
            return Center(child: Lottie.asset(LottiePath.sandyLoading),);
          },
        ),
      ),
    );
  }

}