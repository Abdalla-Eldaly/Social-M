import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_m_app/core/di/di.dart';
import 'package:social_m_app/core/utils/theme/app_dialogs.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/cubit/post_cubit.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/cubit/post_state.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/utils/navigation/animated_page_wrapper.dart';
import '_widget/post_widget.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  late final PostCubit _postCubit;

  // Configuration constants
  static const double _loadMoreThreshold = 200.0;
  static const Duration _scrollDebounceDelay = Duration(milliseconds: 100);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  void _initializeComponents() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize user provider
    final userProvider = getIt<UserProvider>();
    userProvider.initializeAuth();
  }

  void _onScroll() {
    if (!mounted) return;

    final position = _scrollController.position;
    final shouldLoadMore = position.pixels >=
        position.maxScrollExtent - _loadMoreThreshold;

    if (shouldLoadMore && _canLoadMore()) {
      _postCubit.fetchPosts();
    }
  }

  bool _canLoadMore() {
    final currentState = _postCubit.state;
    return currentState is! PostLoadingMore &&
        currentState is! PostLoading &&
        (currentState is! PostLoaded || !currentState.hasReachedMax);
  }

  Future<void> _onRefresh() async {
    await _postCubit.fetchPosts(isRefresh: true);
  }

  void _onRetry() {
    context.read<PostCubit>().retryFetchPosts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnimatedPageWrapper(
      transitionType: PageTransitionType.scaleWithFade,
      duration: const Duration(milliseconds: 200),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocProvider(
          create: (context) {
            _postCubit = getIt<PostCubit>()..fetchPosts();
            return _postCubit;
          },
          child: BlocConsumer<PostCubit, PostState>(
            listener: _handleStateChanges,
            builder: (context, state) => _buildBody(context, state),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Home",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.search_outlined),
          onPressed: () {
            // Navigate to search
          },
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, PostState state) {
    if (state is PostError && state.currentPosts.isEmpty) {
      AppDialogs.showErrorToast(state.failure.message);
    }
  }

  Widget _buildBody(BuildContext context, PostState state) {
    // Initial loading state
    if (_isInitialLoading(state)) {
      return _buildLoadingIndicator();
    }

    final posts = _extractPosts(state);

    // Empty state with error
    if (posts.isEmpty && state is PostError) {
      return _buildErrorState(state);
    }

    // Empty state without error
    if (posts.isEmpty) {
      return _buildEmptyState();
    }

    // Posts list
    return _buildPostsList(context, state, posts);
  }

  bool _isInitialLoading(PostState state) {
    return state is PostInitial ||
        (state is PostLoading && state.isFirstFetch);
  }

  List<Post> _extractPosts(PostState state) {
    return switch (state) {
      PostLoaded() => state.paginatedPosts.items ?? [],
      PostLoadingMore() => state.currentPosts,
      PostError() => state.currentPosts,
      _ => <Post>[],
    };
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 16),
          Text(
            "Loading posts...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PostError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Oops! Something went wrong",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.failure.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.post_add_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No posts yet",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Be the first to share something amazing!",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _onRefresh(),
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, PostState state, List<Post> posts) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Optional: Add a sliver app bar for better UX
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Posts list
          SliverList.separated(
            itemCount: posts.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: PostCard(
                post: posts[index],
                // onTap: () => _onPostTap(posts[index]),
                // onLike: () => _onPostLike(posts[index]),
                // onComment: () => _onPostComment(posts[index]),
                // onShare: () => _onPostShare(posts[index]),
              ),
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),

          // Loading more indicator
          SliverToBoxAdapter(
            child: _buildLoadMoreIndicator(state),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator(PostState state) {
    final shouldShowLoadingMore = state is PostLoadingMore ||
        (state is PostLoaded && !state.hasReachedMax);

    if (!shouldShowLoadingMore) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  // Post interaction handlers
  void _onPostTap(Post post) {
    // Navigate to post details
    // context.router.push(PostDetailRoute(postId: post.id));
  }

  void _onPostLike(Post post) {
    // _postCubit.toggleLike(post.id);
  }

  void _onPostComment(Post post) {
    // Navigate to comments or show comment bottom sheet
  }

  void _onPostShare(Post post) {
    // Handle share functionality
  }
}