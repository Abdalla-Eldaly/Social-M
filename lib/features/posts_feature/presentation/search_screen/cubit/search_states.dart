// search_states.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/hastag.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/entities/user.dart';

enum SearchCategory { all, accounts, hashtags, posts }

// Unified search result model
class SearchResult {
  final String id;
  final SearchResultType type;
  final dynamic data; // Can be Post, User, or Hashtag
  final String searchableText;
  final String? imageUrl;
  final String? subtitle;
  final int? interactionCount;

  const SearchResult({
    required this.id,
    required this.type,
    required this.data,
    required this.searchableText,
    this.imageUrl,
    this.subtitle,
    this.interactionCount,
  });

  factory SearchResult.fromPost(Post post) {
    return SearchResult(
      id: post.id.toString(),
      type: SearchResultType.post,
      data: post,
      searchableText: '${post.caption ?? ''} ${post.user?.username ?? ''}',
      imageUrl: post.imageUrl,
      subtitle: post.user?.username,
      interactionCount: post.likesCount,
    );
  }

  factory SearchResult.fromUser(User user) {
    return SearchResult(
      id: user.id.toString(),
      type: SearchResultType.user,
      data: user,
      searchableText: '${user.username ?? ''} ${user.username ?? ''} ${user.bio ?? ''}',
      imageUrl: user.profileImageUrl,
      subtitle: user.username,
      interactionCount: user.followersCount,
    );
  }

  factory SearchResult.fromHashtag(Hashtag hashtag) {
    return SearchResult(
      id: hashtag.id.toString(),
      type: SearchResultType.hashtag,
      data: hashtag,
      searchableText: hashtag.name,
      imageUrl: null,
      subtitle: '${hashtag.postCount ?? 0} posts',
      interactionCount: hashtag.postCount,
    );
  }
}

enum SearchResultType { post, user, hashtag }

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<SearchResult> recentSearches;
  final List<SearchResult> suggestedUsers;
  final List<SearchResult> trendingHashtags;

  const SearchInitial({
    this.recentSearches = const [],
    this.suggestedUsers = const [],
    this.trendingHashtags = const [],
  });

  @override
  List<Object?> get props => [recentSearches, suggestedUsers, trendingHashtags];
}

class SearchLoading extends SearchState {
  final String query;
  final List<SearchResult> previousResults;

  const SearchLoading({
    required this.query,
    this.previousResults = const [],
  });

  @override
  List<Object?> get props => [query, previousResults];
}

class SearchSuccess extends SearchState {
  final String query;
  final List<SearchResult> allResults;
  final SearchCategory activeCategory;
  final Map<SearchResultType, List<SearchResult>> categorizedResults;
  final bool hasMoreResults;
  final bool isLoadingMore;

  const SearchSuccess({
    required this.query,
    required this.allResults,
    required this.activeCategory,
    required this.categorizedResults,
    this.hasMoreResults = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    query,
    allResults,
    activeCategory,
    categorizedResults,
    hasMoreResults,
    isLoadingMore,
  ];

  // Get filtered results based on active category
  List<SearchResult> get filteredResults {
    switch (activeCategory) {
      case SearchCategory.all:
        return allResults;
      case SearchCategory.accounts:
        return categorizedResults[SearchResultType.user] ?? [];
      case SearchCategory.hashtags:
        return categorizedResults[SearchResultType.hashtag] ?? [];
      case SearchCategory.posts:
        return categorizedResults[SearchResultType.post] ?? [];
    }
  }

  // Get top results for each category (Instagram-style)
  Map<SearchResultType, List<SearchResult>> get topResults {
    return {
      SearchResultType.user: (categorizedResults[SearchResultType.user] ?? [])
          .take(3).toList(),
      SearchResultType.hashtag: (categorizedResults[SearchResultType.hashtag] ?? [])
          .take(3).toList(),
      SearchResultType.post: (categorizedResults[SearchResultType.post] ?? [])
          .take(6).toList(),
    };
  }

  SearchSuccess copyWith({
    String? query,
    List<SearchResult>? allResults,
    SearchCategory? activeCategory,
    Map<SearchResultType, List<SearchResult>>? categorizedResults,
    bool? hasMoreResults,
    bool? isLoadingMore,
  }) {
    return SearchSuccess(
      query: query ?? this.query,
      allResults: allResults ?? this.allResults,
      activeCategory: activeCategory ?? this.activeCategory,
      categorizedResults: categorizedResults ?? this.categorizedResults,
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SearchError extends SearchState {
  final String message;
  final String? query;

  const SearchError({
    required this.message,
    this.query,
  });

  @override
  List<Object?> get props => [message, query];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}