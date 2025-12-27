import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/posts_state.dart';
import '../../cubit/profile_cubit.dart';
import 'followers_following_widgets.dart';
import 'profile_ui_components.dart';
import 'profile_dialogs.dart';

class AuthenticatedProfileView extends StatelessWidget {
  final ProfileAuthenticated state;

  const AuthenticatedProfileView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().refreshUserData(),
      child: CustomScrollView(
        slivers: [
          buildSliverAppBar(context, onLogout: () => showLogoutDialog(context)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                buildProfileHeader(context, state),
                buildStatsSection(context, state),
                buildActionButtons(context,
                    onShare: () => showShareOptions(context),
                    onMore: () => showMoreOptions(context)
                ),
                buildPostsSection(context, state),
              ],
            ),
          )
        ],
      ),
    );
  }
}