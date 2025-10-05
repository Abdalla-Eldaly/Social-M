import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_m_app/core/utils/theme/app_color.dart';
import 'package:social_m_app/core/utils/widgets/custom_cached_image.dart';
import '../../../../../core/di/di.dart';
import '../../../domain/entities/hastag.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/entities/user.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_states.dart';

@RoutePage()
class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SearchCubit>(),
      child: const _SearchViewContent(),
    );
  }
}

class _SearchViewContent extends StatefulWidget {
  const _SearchViewContent({Key? key}) : super(key: key);

  @override
  State<_SearchViewContent> createState() => _SearchViewContentState();
}

class _SearchViewContentState extends State<_SearchViewContent>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _searchBarController;
  late AnimationController _resultsController;
  late AnimationController _categoryController;

  late Animation<double> _searchBarAnimation;
  late Animation<double> _resultsAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupListeners();
  }

  void _setupAnimations() {
    _searchBarController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _categoryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _searchBarAnimation = CurvedAnimation(
      parent: _searchBarController,
      curve: Curves.easeOutCubic,
    );

    _resultsAnimation = CurvedAnimation(
      parent: _resultsController,
      curve: Curves.easeOutQuart,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_resultsAnimation);
  }

  void _setupListeners() {
    _searchFocusNode.addListener(_onSearchFocusChange);
    _scrollController.addListener(_onScroll);
  }

  void _onSearchFocusChange() {
    setState(() {
      _isSearchActive = _searchFocusNode.hasFocus;
    });

    if (_isSearchActive) {
      _searchBarController.forward();
      _resultsController.forward();
    } else if (_searchController.text.isEmpty) {
      _searchBarController.reverse();
      _resultsController.reverse();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more results when near bottom
      context.read<SearchCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _searchBarController.dispose();
    _resultsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAnimatedSearchBar(),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return _buildDiscoverContent(state);
                  } else if (state is SearchLoading) {
                    return _buildLoadingState(state);
                  } else if (state is SearchSuccess) {
                    return _buildSearchResults(state);
                  } else if (state is SearchError) {
                    return _buildErrorState(state);
                  } else if (state is SearchEmpty) {
                    return _buildEmptyState(state);
                  }
                  return _buildDiscoverContent(const SearchInitial());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _searchBarAnimation,
        builder: (context, child) {
          return Row(
            children: [
IconButton(onPressed: () {
Navigator.pop(context);
}, icon: const Icon(Icons.arrow_back)),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: AppColors.fieldFill,
                    border: Border.all(
                      color: _isSearchActive
                          ? AppColors.primary.withOpacity(0.3)
                          : AppColors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: _isSearchActive
                        ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ]
                        : [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: AnimatedRotation(
                          turns: _searchBarAnimation.value * 0.5,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            context.read<SearchCubit>().search(value);
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              context.read<SearchCubit>().search('');
                            },
                            child: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDiscoverContent(SearchInitial state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.recentSearches.isNotEmpty) ...[
            _buildSectionHeader('Recent Searches', Icons.history),
            const SizedBox(height: 16),
            _buildRecentSearches(state.recentSearches),
            const SizedBox(height: 32),
          ],
          if (state.trendingHashtags.isNotEmpty) ...[
            _buildSectionHeader('Trending Hashtags', Icons.trending_up),
            const SizedBox(height: 16),
            _buildTrendingGrid(state.trendingHashtags),
            const SizedBox(height: 32),
          ],
          if (state.suggestedUsers.isNotEmpty) ...[
            _buildSectionHeader('Suggested for You', Icons.person_outline),
            const SizedBox(height: 16),
            _buildSuggestedList(state.suggestedUsers),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(SearchLoading state) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _resultsAnimation,
        child: Column(
          children: [
            // Show previous results while loading
            if (state.previousResults.isNotEmpty) ...[
              _buildCategoryTabs(SearchCategory.all),
              Expanded(
                child: _buildResultsList(state.previousResults, false),
              ),
            ] else ...[
              const SizedBox(height: 100),
              _buildLoadingIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchSuccess state) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _resultsAnimation,
        child: Column(
          children: [
            _buildCategoryTabs(state.activeCategory),
            Expanded(
              child: _buildResultsList(
                state.filteredResults,
                state.hasMoreResults,
                isLoadingMore: state.isLoadingMore,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(SearchCategory activeCategory) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: SearchCategory.values.map((category) {
          final isActive = activeCategory == category;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<SearchCubit>().switchCategory(category);
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isActive ? AppColors.primary : AppColors.fieldFill,
                  border: !isActive
                      ? Border.all(color: AppColors.grey.withOpacity(0.5))
                      : null,
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _getCategoryName(category),
                    style: TextStyle(
                      color: isActive ? AppColors.white : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsList(
      List<SearchResult> results,
      bool hasMore, {
        bool isLoadingMore = false,
      }) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: results.length + (hasMore || isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= results.length) {
          return _buildLoadMoreIndicator(isLoadingMore);
        }

        return AnimatedContainer(
          duration: Duration(milliseconds: 100 * (index % 10)),
          curve: Curves.easeOutQuart,
          child: _buildResultItem(results[index], index),
        );
      },
    );
  }

  Widget _buildResultItem(SearchResult result, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white,
        border: Border.all(
          color: AppColors.grey.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Hero(
          tag: 'result_${result.id}',
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: _getGradientColors(result.type),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: result.imageUrl != null
                  ? CachedImage(
              imageUrl:   result.imageUrl!,


              )
                  : Icon(
                _getIconForType(result.type),
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
        ),
        title: Text(
          _getDisplayTitle(result),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          result.subtitle ?? '',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),

        onTap: () {
          HapticFeedback.lightImpact();
          context.read<SearchCubit>().selectResult(context,result);
        },
      ),
    );
  }

  Widget _buildRecentSearches(List<SearchResult> recentSearches) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentSearches.length,
        itemBuilder: (context, index) {
          final result = recentSearches[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    gradient: LinearGradient(
                      colors: _getGradientColors(result.type),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: result.imageUrl != null
                        ? CachedImage(
                     imageUrl:  result.imageUrl!,

                    )
                        : Icon(
                      _getIconForType(result.type),
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getDisplayTitle(result),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingGrid(List<SearchResult> trendingHashtags) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: trendingHashtags.length.clamp(0, 6),
      itemBuilder: (context, index) {
        final hashtag = trendingHashtags[index];
        return GestureDetector(
          onTap: () {
            context.read<SearchCubit>().selectResult(context,hashtag);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.fieldFill,
              border: Border.all(color: AppColors.grey.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.white.withOpacity(0.9),
                      border: Border.all(color: AppColors.grey.withOpacity(0.5)),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.tag,
                        color: AppColors.textSecondary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getDisplayTitle(hashtag),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        hashtag.subtitle ?? '',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedList(List<SearchResult> suggestedUsers) {
    return Column(
      children: suggestedUsers.take(5).map((user) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.white,
            border: Border.all(
              color: AppColors.grey.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [AppColors.accentBlue, AppColors.primary],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: user.imageUrl != null
                      ? CachedImage(
                   imageUrl:  user.imageUrl!,

                  )
                      : const Icon(
                    Icons.person,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayTitle(user),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user.subtitle ?? 'Suggested for you',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<SearchCubit>().selectResult(context,user);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorState(SearchError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (state.query != null) {
                context.read<SearchCubit>().search(state.query!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(SearchEmpty state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "${state.query}"',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching for something else',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isLoadingMore) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoadingMore
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        )
            : const SizedBox.shrink(),
      ),
    );
  }

  // Helper methods
  String _getCategoryName(SearchCategory category) {
    switch (category) {
      case SearchCategory.all:
        return 'All';
      case SearchCategory.accounts:
        return 'Accounts';
      case SearchCategory.hashtags:
        return 'Tags';
      case SearchCategory.posts:
        return 'Posts';
    }
  }

  List<Color> _getGradientColors(SearchResultType type) {
    switch (type) {
      case SearchResultType.user:
        return [AppColors.primary, AppColors.accentBlue];
      case SearchResultType.hashtag:
        return [AppColors.successGreen, AppColors.primary];
      case SearchResultType.post:
        return [AppColors.warningYellow, AppColors.primary];
    }
  }

  IconData _getIconForType(SearchResultType type) {
    switch (type) {
      case SearchResultType.user:
        return Icons.person;
      case SearchResultType.hashtag:
        return Icons.tag;
      case SearchResultType.post:
        return Icons.image;
    }
  }

  String _getDisplayTitle(SearchResult result) {
    switch (result.type) {
      case SearchResultType.user:
        final user = result.data as User;
        return user.username ?? 'Unknown User';
      case SearchResultType.hashtag:
        final hashtag = result.data as Hashtag;
        return hashtag.name;
      case SearchResultType.post:
        final post = result.data as Post;
        return post.caption ?? 'Post by ${post.user?.username ?? "Unknown"}';
    }
  }

}