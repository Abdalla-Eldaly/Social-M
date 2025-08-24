import 'package:flutter/material.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_interaction_handler.dart';

class CommentsToggleWidget extends StatelessWidget {
  final Post post;

  const CommentsToggleWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final handler = PostInteractionHandler.of(context);
    final postId = post.id ?? 0;
    final commentsCount = post.comments?.length ?? 0;
    final showComments = handler.isCommentsVisible(postId);

    if (commentsCount > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: GestureDetector(
          onTap: () => handler.toggleComments(post),
          child: Text(
            showComments
                ? 'Hide comments'
                : commentsCount > 2
                ? 'View all $commentsCount comments'
                : 'View ${commentsCount == 1 ? '1 comment' : '$commentsCount comments'}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}