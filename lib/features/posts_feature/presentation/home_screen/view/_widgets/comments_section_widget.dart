import 'package:flutter/material.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_interaction_handler.dart';
import 'add_comment_input_widget.dart';
import 'comment_item_widget.dart';

class CommentsSectionWidget extends StatelessWidget {
  final Post post;

  const CommentsSectionWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final handler = PostInteractionHandler.of(context);
    final postId = post.id ?? 0;
    final comments = post.comments ?? [];
    final showComments = handler.isCommentsVisible(postId);

    if (!showComments) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...comments.take(5).map((comment) => CommentItemWidget(comment: comment)),
          if (comments.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () => handler.navigateToCommentsScreen(context, post),
                child: Text(
                  'View ${comments.length - 5} more comments',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          AddCommentInputWidget(post: post),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}