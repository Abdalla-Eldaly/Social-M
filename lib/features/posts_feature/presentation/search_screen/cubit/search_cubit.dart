// search_cubit.dart
import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/features/posts_feature/presentation/search_screen/cubit/search_states.dart';

import '../../../../../core/config/router/app_router.dart';
import '../../../domain/usecases/search_hastags_use_case.dart';
import '../../../domain/usecases/search_posts_use_case.dart';
import '../../../domain/usecases/search_users_use_case.dart';

@injectable
class SearchCubit extends Cubit<SearchState> {
  final SearchPostsUseCase _searchPostsUseCase;
  final SearchUsersUseCase _searchUsersUseCase;
  final SearchHashTagsUseCase _searchHashTagsUseCase;

  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  static const int _resultsPerPage = 20;

  // Search history and suggestions
  final List<SearchResult> _recentSearches = [];
  final Map<String, List<SearchResult>> _searchCache = {};
  static const int _maxCacheSize = 50;
  static const int _maxRecentSearches = 20;

  String? _lastQuery;
  int _currentPage = 1;
  final Set<String> _activeSearches = {};

  SearchCubit(
      this._searchPostsUseCase,
      this._searchUsersUseCase,
      this._searchHashTagsUseCase,
      ) : super(const SearchInitial()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Load recent searches, suggested users, and trending hashtags
      final suggestedUsers = await _loadSuggestedUsers();
      final trendingHashtags = await _loadTrendingHashtags();

      emit(SearchInitial(
        recentSearches: _recentSearches,
        suggestedUsers: suggestedUsers,
        trendingHashtags: trendingHashtags,
      ));
    } catch (e) {
      emit(const SearchInitial());
    }
  }

  void search(String query) {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      _clearSearch();
      return;
    }

    // Don't search if query hasn't changed
    if (_lastQuery == trimmedQuery && state is SearchSuccess) {
      return;
    }

    _lastQuery = trimmedQuery;
    _debounceTimer?.cancel();

    // Immediate search for quick feedback
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(trimmedQuery);
    });
  }

  Future<void> _performSearch(String query) async {
    if (_activeSearches.contains(query)) return;

    _activeSearches.add(query);
    _currentPage = 1;

    try {
      // Check cache first
      final cached = _getCachedResults(query);
      if (cached != null && cached.isNotEmpty) {
        _emitSuccessState(query, cached);
        _activeSearches.remove(query);
        return;
      }

      // Show loading with previous results if available
      final previousResults = state is SearchSuccess
          ? (state as SearchSuccess).allResults
          : <SearchResult>[];

      emit(SearchLoading(query: query, previousResults: previousResults));

      // Search all types concurrently
      final futures = await Future.wait([
        _searchUsers(query),
        _searchHashtags(query),
        _searchPosts(query),
      ]);

      final usersResult = futures[0];
      final hashtagsResult = futures[1];
      final postsResult = futures[2];

      // Check for errors
      final error = _extractError(usersResult) ??
          _extractError(hashtagsResult) ??
          _extractError(postsResult);

      if (error != null) {
        emit(SearchError(message: error, query: query));
        _activeSearches.remove(query);
        return;
      }

      // Extract successful results
      final users = _extractUsers(usersResult);
      final hashtags = _extractHashtags(hashtagsResult);
      final posts = _extractPosts(postsResult);

      // Combine and sort results
      final allResults = _combineAndSortResults(users, hashtags, posts, query);

      if (allResults.isEmpty) {
        emit(SearchEmpty(query: query));
      } else {
        _cacheResults(query, allResults);
        _emitSuccessState(query, allResults);
      }

    } catch (e) {
      emit(SearchError(
        message: 'Something went wrong. Please try again.',
        query: query,
      ));
    } finally {
      _activeSearches.remove(query);
    }
  }

  void switchCategory(SearchCategory category) {
    final currentState = state;
    if (currentState is SearchSuccess) {
      emit(currentState.copyWith(activeCategory: category));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! SearchSuccess ||
        !currentState.hasMoreResults ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      _currentPage++;

      // Search for more results
      final futures = await Future.wait([
        _searchUsers(currentState.query, page: _currentPage),
        _searchHashtags(currentState.query, page: _currentPage),
        _searchPosts(currentState.query, page: _currentPage),
      ]);

      final users = _extractUsers(futures[0]);
      final hashtags = _extractHashtags(futures[1]);
      final posts = _extractPosts(futures[2]);

      final newResults = _combineAndSortResults(users, hashtags, posts, currentState.query);

      if (newResults.isEmpty) {
        emit(currentState.copyWith(
          hasMoreResults: false,
          isLoadingMore: false,
        ));
        return;
      }

      final updatedResults = [...currentState.allResults, ...newResults];
      final categorizedResults = _categorizeResults(updatedResults);

      emit(currentState.copyWith(
        allResults: updatedResults,
        categorizedResults: categorizedResults,
        hasMoreResults: newResults.length >= _resultsPerPage,
        isLoadingMore: false,
      ));

    } catch (e) {
      _currentPage--; // Rollback page increment
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  void selectResult(BuildContext context ,SearchResult result) {
    final router = AutoRouter.of(context);

    _addToRecentSearches(result);
    // Handle navigation based on result type
    switch (result.type) {
      case SearchResultType.user:
      // Navigate to user profile
        break;
      case SearchResultType.post:
        router.push(PostDetailsRoute(postId: int.parse(result.id)));
        break;
      case SearchResultType.hashtag:
      // Navigate to hashtag posts
        break;
    }
  }

  // void clearRecentSearches() {
  //   _recentSearches.clear();
  //   if (state is SearchInitial) {
  //     final current = state as SearchInitial;
  //     emit(current.copyWith(recentSearches: []));
  //   }
  // }
  //
  // void removeFromRecentSearches(SearchResult result) {
  //   _recentSearches.removeWhere((item) => item.id == result.id);
  //   if (state is SearchInitial) {
  //     final current = state as SearchInitial;
  //     emit(current.copyWith(recentSearches: List.from(_recentSearches)));
  //   }
  // }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _lastQuery = null;
    _currentPage = 1;
    _loadInitialData();
  }

  // Helper methods for API calls
  Future<dynamic> _searchUsers(String query, {int page = 1}) async {
    return await _searchUsersUseCase(query,  );
  }

  Future<dynamic> _searchHashtags(String query, {int page = 1}) async {
    final hashtag = query.startsWith('#') ? query : query;
    return await _searchHashTagsUseCase(hashtag,  );
  }

  Future<dynamic> _searchPosts(String query, {int page = 1}) async {
    return await _searchPostsUseCase(query,);
  }

  // Helper methods for result processing
  List<SearchResult> _extractUsers(dynamic result) {
    return result.fold(
          (error) => <SearchResult>[],
          (users) => users.map<SearchResult>((user) => SearchResult.fromUser(user)).toList(),
    );
  }

  List<SearchResult> _extractHashtags(dynamic result) {
    return result.fold(
          (error) => <SearchResult>[],
          (hashtags) => hashtags.map<SearchResult>((hashtag) => SearchResult.fromHashtag(hashtag)).toList(),
    );
  }

  List<SearchResult> _extractPosts(dynamic result) {
    return result.fold(
          (error) => <SearchResult>[],
          (posts) => posts.map<SearchResult>((post) => SearchResult.fromPost(post)).toList(),
    );
  }

  String? _extractError(dynamic result) {
    return result.fold(
          (error) => error.message,
          (success) => null,
    );
  }

  List<SearchResult> _combineAndSortResults(
      List<SearchResult> users,
      List<SearchResult> hashtags,
      List<SearchResult> posts,
      String query,
      ) {
    final allResults = [...users, ...hashtags, ...posts];

    // Sort by relevance (Instagram-like algorithm)
    allResults.sort((a, b) {
      // Prioritize exact matches
      final aExact = _isExactMatch(a.searchableText, query);
      final bExact = _isExactMatch(b.searchableText, query);

      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;

      // Then by prefix matches
      final aPrefix = _isPrefixMatch(a.searchableText, query);
      final bPrefix = _isPrefixMatch(b.searchableText, query);

      if (aPrefix && !bPrefix) return -1;
      if (!aPrefix && bPrefix) return 1;

      // Then by interaction count (popularity)
      final aCount = a.interactionCount ?? 0;
      final bCount = b.interactionCount ?? 0;

      return bCount.compareTo(aCount);
    });

    return allResults;
  }

  Map<SearchResultType, List<SearchResult>> _categorizeResults(List<SearchResult> results) {
    final categorized = <SearchResultType, List<SearchResult>>{};

    for (final result in results) {
      categorized.putIfAbsent(result.type, () => []).add(result);
    }

    return categorized;
  }

  bool _isExactMatch(String text, String query) {
    return text.toLowerCase().contains(query.toLowerCase());
  }

  bool _isPrefixMatch(String text, String query) {
    return text.toLowerCase().startsWith(query.toLowerCase());
  }

  void _emitSuccessState(String query, List<SearchResult> results) {
    final categorizedResults = _categorizeResults(results);

    emit(SearchSuccess(
      query: query,
      allResults: results,
      activeCategory: SearchCategory.all,
      categorizedResults: categorizedResults,
      hasMoreResults: results.length >= _resultsPerPage,
    ));
  }

  // Cache management
  void _cacheResults(String query, List<SearchResult> results) {
    if (_searchCache.length >= _maxCacheSize) {
      _searchCache.remove(_searchCache.keys.first);
    }
    _searchCache[query] = results;
  }

  List<SearchResult>? _getCachedResults(String query) {
    return _searchCache[query];
  }

  // Recent searches management
  void _addToRecentSearches(SearchResult result) {
    _recentSearches.removeWhere((item) => item.id == result.id);
    _recentSearches.insert(0, result);

    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches.removeLast();
    }
  }

  // Mock data loaders (implement with actual API calls)
  Future<List<SearchResult>> _loadSuggestedUsers() async {
    // Implement actual API call for suggested users
    return [];
  }

  Future<List<SearchResult>> _loadTrendingHashtags() async {
    // Implement actual API call for trending hashtags
    return [];
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _activeSearches.clear();
    _searchCache.clear();
    return super.close();
  }
}