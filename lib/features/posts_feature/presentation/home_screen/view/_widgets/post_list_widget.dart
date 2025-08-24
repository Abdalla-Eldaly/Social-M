import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_widget.dart';
  import '../../cubit/post_cubit.dart';
import '../../cubit/post_state.dart';
import 'loading_home_screen.dart';

class PostListWidget extends StatelessWidget {
  const PostListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostLoading && state.isFirstFetch) {
          return const HomeScreenLoading();
        } else if (state is PostError) {
          return _buildErrorWidget(context, state);
        } else {
          return _buildPostsList(context, state);
        }
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, PostError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            state.failure.message ?? 'Failed to load posts. Please try again.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<PostCubit>().fetchPosts(isRefresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, PostState state) {
    final posts = (state is PostLoaded) ? state.paginatedPosts.items ?? [] : <Post>[];

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: posts.length + ((state is PostLoaded && !state.hasReachedMax) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < posts.length) {
          return PostWidget(post: posts[index]);
        } else {
          context.read<PostCubit>().fetchPosts();
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}