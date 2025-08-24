import 'package:flutter/material.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';

class PostCaptionWidget extends StatelessWidget {
  final Post post;

  const PostCaptionWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.caption != null && post.caption!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${post.user?.username ?? 'unknown'} ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: post.caption ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}