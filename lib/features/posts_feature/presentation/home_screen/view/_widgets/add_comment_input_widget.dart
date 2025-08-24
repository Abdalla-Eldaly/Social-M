import 'package:flutter/material.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_interaction_handler.dart';

class AddCommentInputWidget extends StatelessWidget {
  final Post post;

  const AddCommentInputWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final handler = PostInteractionHandler.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 13),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  handler.addComment(post, text.trim());
                  controller.clear();
                }
              },
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                handler.addComment(post, controller.text.trim());
                controller.clear();
              }
            },
            child: const Text(
              'Post',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}