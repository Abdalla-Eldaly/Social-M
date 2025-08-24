import 'package:flutter/material.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_interaction_handler.dart';

class PostActionsWidget extends StatelessWidget {
  final Post post;

  const PostActionsWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final handler = PostInteractionHandler.of(context);
    final postId = post.id ?? 0;
    final isLiked = handler.isLiked(postId);
    final isBookmarked = handler.isBookmarked(postId);
    final likeCount = handler.getLikeCount(postId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => handler.handleLike(post),
            child: AnimatedBuilder(
              animation: handler.getHeartAnimation(postId) ?? const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.scale(
                  scale: (handler.getHeartAnimation(postId)?.value ?? 1.0) * 0.8 + 0.2,
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.black,
                    size: 24,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$likeCount',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => handler.toggleComments(post),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black,
              size: 24,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => handler.handleBookmark(post),
            child: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
