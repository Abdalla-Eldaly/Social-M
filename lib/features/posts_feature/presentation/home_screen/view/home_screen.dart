import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_m_app/core/di/di.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/cubit/post_cubit.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/cubit/post_state.dart';

import '_widget/post_widget.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  late PostCubit _postCubit;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_postCubit.state is! PostLoadingMore &&
          _postCubit.state is! PostLoading) {
        _postCubit.fetchPosts();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: BlocProvider(
        create: (context) {
          _postCubit = getIt<PostCubit>()..fetchPosts();
          return _postCubit;
        },
        child: BlocConsumer<PostCubit, PostState>(
          listener: (context, state) {
            if (state is PostError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is PostInitial ||
                (state is PostLoading && state.isFirstFetch)) {
              return const Center(child: CircularProgressIndicator());
            }

            final posts = state is PostLoaded
                ? state.paginatedPosts.items ?? []
                : state is PostLoadingMore
                ? state.currentPosts
                : state is PostError
                ? state.currentPosts
                : <Post>[];

            if (posts.isEmpty && state is PostError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: ${state.failure.message}"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<PostCubit>().retryFetchPosts(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<PostCubit>().fetchPosts(isRefresh: true),
              child: ListView.separated(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (index < posts.length) {
                    final post = posts[index];
                    final currentUser = User(
                      id: 1,
                      username: "omarafifi",
                      profileImageUrl:
                      "https://socialm.runasp.net/Uploads/Images/PostImage/3610dcff-4b4d-4933-8c33-1fd931060bbf.jpg",
                    );
                    return PostCard(post: post, currentUser: currentUser);
                  } else {
                    return (state is PostLoadingMore ||
                        (state is PostLoaded && !state.hasReachedMax))
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                        : const SizedBox.shrink();
                  }
                },
                separatorBuilder: (context, index) =>
                const SizedBox(height: 10),
                itemCount: posts.length +
                    (state is PostLoaded && state.hasReachedMax ? 0 : 1),
              ),
            );
          },
        ),
      ),
    );
  }
}