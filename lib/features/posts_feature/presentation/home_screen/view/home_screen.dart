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
  // Accept scroll controller from MainLayoutView
  final ScrollController? scrollController;

  const HomeView({
    super.key,
    this.scrollController,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final PostCubit _postCubit;
  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabAnimation;

  // Configuration constants
  static const double _loadMoreThreshold = 200.0;
  static const Duration _scrollDebounceDelay = Duration(milliseconds: 100);
  static const double _scrollToTopThreshold = 400.0;

  // Scroll state tracking
  bool _showScrollToTopFab = false;
  double _scrollOffset = 0.0;
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _initializeAnimations();
  }

  void _initializeComponents() {
    // Use provided scroll controller or create new one
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize user provider
    final userProvider = getIt<UserProvider>();
    userProvider.initializeAuth();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
  }

  void _onScroll() {
    if (!mounted) return;

    final position = _scrollController.position;
    _scrollOffset = position.pixels;

    // Handle scroll-to-top FAB visibility
    _updateScrollToTopFab(position.pixels);

    // Handle infinite scrolling with debouncing
    _handleInfiniteScrolling(position);
  }

  void _updateScrollToTopFab(double scrollOffset) {
    final shouldShow = scrollOffset > _scrollToTopThreshold;

    if (shouldShow != _showScrollToTopFab) {
      setState(() {
        _showScrollToTopFab = shouldShow;
      });

      if (shouldShow) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  void _handleInfiniteScrolling(ScrollPosition position) {
    final shouldLoadMore = position.pixels >=
        position.maxScrollExtent - _loadMoreThreshold;

    if (shouldLoadMore && _canLoadMore() && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      _postCubit.fetchPosts().then((_) {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  bool _canLoadMore() {
    final currentState = _postCubit.state;
    return currentState is! PostLoadingMore &&
        currentState is! PostLoading &&
        (currentState is! PostLoaded || !currentState.hasReachedMax);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoadingMore = false;
    });
    await _postCubit.fetchPosts(isRefresh: true);
  }

  void _onRetry() {
    setState(() {
      _isLoadingMore = false;
    });
    context.read<PostCubit>().retryFetchPosts();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    // Only dispose if we created the controller ourselves
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _fabAnimationController.dispose();
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
        floatingActionButton: _buildScrollToTopFab(),
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
      automaticallyImplyLeading: false, // Remove back button in main layout
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

  Widget _buildScrollToTopFab() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: Opacity(
            opacity: _fabAnimation.value,
            child: FloatingActionButton.small(
              onPressed: _scrollToTop,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              heroTag: "home_scroll_top", // Unique hero tag
              child: const Icon(
                Icons.keyboard_arrow_up,
                size: 20,
              ),
            ),
          ),
        );
      },
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
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        // Enable scroll position restoration
        key: const PageStorageKey('home_posts_scroll'),
        slivers: [
          // Top spacing
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Posts list with enhanced performance
          SliverList.separated(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PostCard(
                  post: posts[index],

                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),

          // Loading more indicator
          SliverToBoxAdapter(
            child: _buildLoadMoreIndicator(state),
          ),

          // Bottom spacing to account for fixed bottom navigation
          const SliverToBoxAdapter(
            child: SizedBox(height: 20), // Reduced since nav is now at bottom
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator(PostState state) {
    if (state is PostLoadingMore) {
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

    if (state is PostLoaded && state.hasReachedMax && state.paginatedPosts.items!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "That's all for now!",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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