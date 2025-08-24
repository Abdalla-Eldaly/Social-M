import 'package:flutter/material.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/comment.dart';

class PostInteractionHandler extends StatefulWidget {
  final Widget child;

  const PostInteractionHandler({super.key, required this.child});

  @override
  PostInteractionHandlerState createState() => PostInteractionHandlerState();

  static PostInteractionHandlerState of(BuildContext context) {
    return context.findAncestorStateOfType<PostInteractionHandlerState>()!;
  }
}

class PostInteractionHandlerState extends State<PostInteractionHandler>
    with TickerProviderStateMixin {
  final Map<int, bool> _likedPosts = {};
  final Map<int, int> _likeCounts = {};
  final Map<int, bool> _bookmarkedPosts = {};
  final Map<int, AnimationController> _heartControllers = {};
  final Map<int, Animation<double>> _heartAnimations = {};
  final Map<int, bool> _showComments = {};

  AnimationController _getHeartController(int postId) {
    if (!_heartControllers.containsKey(postId)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      final animation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
      _heartControllers[postId] = controller;
      _heartAnimations[postId] = animation;
    }
    return _heartControllers[postId]!;
  }

  Animation<double>? getHeartAnimation(int postId) => _heartAnimations[postId];

  bool isLiked(int postId) => _likedPosts[postId] ?? false;
  bool isBookmarked(int postId) => _bookmarkedPosts[postId] ?? false;
  bool isCommentsVisible(int postId) => _showComments[postId] ?? false;
  int getLikeCount(int postId) => _likeCounts[postId] ?? 0;

  void handleDoubleTapLike(Post post) {
    final postId = post.id ?? 0;
    if (!(_likedPosts[postId] ?? false)) {
      handleLike(post);
    }
    final controller = _getHeartController(postId);
    controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        controller.reverse();
      });
    });
  }

  void handleLike(Post post) {
    final postId = post.id ?? 0;
    setState(() {
      _likedPosts[postId] ??= post.isLikedByUser ?? false;
      _likeCounts[postId] ??= post.likesCount ?? 0;

      final wasLiked = _likedPosts[postId]!;
      _likedPosts[postId] = !wasLiked;
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + (wasLiked ? -1 : 1);
    });
    final controller = _getHeartController(postId);
    controller.forward().then((_) => controller.reverse());

    // TODO: Call backend API to persist like
  }

  void handleShare(Post post) {
    _showSnackBar(context, 'Post shared successfully!');
    // TODO: Implement share functionality
  }

  void handleBookmark(Post post) {
    final postId = post.id ?? 0;
    setState(() {
      _bookmarkedPosts[postId] ??= false;
      _bookmarkedPosts[postId] = !_bookmarkedPosts[postId]!;
    });
    final isBookmarked = _bookmarkedPosts[postId]!;
    _showSnackBar(
      context,
      isBookmarked ? 'Post saved to bookmarks' : 'Post removed from bookmarks',
    );

    // TODO: Call backend API to persist bookmark
  }

  void toggleComments(Post post) {
    final postId = post.id ?? 0;
    setState(() {
      _showComments[postId] ??= false;
      _showComments[postId] = !_showComments[postId]!;
    });
  }

  void navigateToCommentsScreen(BuildContext context, Post post) {
    _showSnackBar(context, 'Navigate to comments screen');
    // TODO: Implement navigation using auto_route
  }

  void addComment(Post post, String text) {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      content: text,
      createdAt: DateTime.now(),
      user: null, // TODO: pass current user
    );

    setState(() {
      // post. = [...(post.comments ?? []), newComment];
    });

    _showSnackBar(context, 'Comment added');
    // TODO: Call backend API to persist comment
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    for (final controller in _heartControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
