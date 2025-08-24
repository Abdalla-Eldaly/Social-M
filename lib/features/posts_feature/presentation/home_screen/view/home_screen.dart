import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_m_app/core/di/di.dart';
import '../cubit/post_cubit.dart';
import '_widgets/post_list_widget.dart';
import '_widgets/post_interaction_handler.dart';

@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return PostInteractionHandler(
      child: BlocProvider(
        create: (context) => getIt<PostCubit>()..fetchPosts(isRefresh: true),
        child: Scaffold(
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: () async {
              await context.read<PostCubit>().fetchPosts(isRefresh: true);
            },
            child: const PostListWidget(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'SocialM',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.black),
          onPressed: () {
            // TODO: Navigate to activity screen
          },
        ),
        IconButton(
          icon: const Icon(Icons.send_outlined, color: Colors.black),
          onPressed: () {
            // TODO: Navigate to messages
          },
        ),
      ],
    );
  }
}