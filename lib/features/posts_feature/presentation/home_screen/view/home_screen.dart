import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_m_app/core/di/di.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/cubit/post_cubit.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/cubit/post_state.dart';

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
      if (_postCubit.state is! PostLoadingMore && _postCubit.state is! PostLoading) {
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
            if (state is PostInitial || (state is PostLoading && state.isFirstFetch)) {
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
                      onPressed: () => context.read<PostCubit>().retryFetchPosts(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<PostCubit>().fetchPosts(isRefresh: true),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  if (index < posts.length) {
                    final post = posts[index];
                    return _PostCard(post: post);
                  } else {
                    return (state is PostLoadingMore || (state is PostLoaded && !state.hasReachedMax))
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                        : const SizedBox.shrink();
                  }
                },
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemCount: posts.length + (state is PostLoaded && state.hasReachedMax ? 0 : 1),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              post.caption ?? "",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              post.createdAt.toString(),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}