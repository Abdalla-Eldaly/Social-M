import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:social_m_app/features/posts_feature/presentation/profile_screen/cubit/profile_cubit.dart';
 import '../../../../../core/utils/navigation/animated_page_wrapper.dart';
import '../cubit/posts_state.dart';
import '_widgets/authenticated_profile_view.dart';
import '_widgets/error_view.dart';
import '_widgets/guest_view.dart';
import '_widgets/loading_view.dart';

@RoutePage()
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ProfileCubit>(),
      child: AnimatedPageWrapper(
        transitionType: PageTransitionType.slideFromRight,
        duration: const Duration(milliseconds: 300),
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const LoadingView();
              } else if (state is ProfileAuthenticated) {
                return AuthenticatedProfileView(state: state);
              } else if (state is ProfileGuest) {
                return const GuestView();
              } else if (state is ProfileError) {
                return ErrorView(message: state.message);
              }
              return const GuestView();
            },
          ),
        ),
      ),
    );
  }
}




