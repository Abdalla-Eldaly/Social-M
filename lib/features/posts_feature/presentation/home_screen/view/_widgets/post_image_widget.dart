import 'package:flutter/material.dart';
import 'package:social_m_app/core/utils/widgets/custom_cached_image.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_interaction_handler.dart';

class PostImageWidget extends StatelessWidget {
  final Post post;

  const PostImageWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final handler = PostInteractionHandler.of(context);
    final postId = post.id ?? 0;

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onDoubleTap: () => handler.handleDoubleTapLike(post),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: CachedImage(
              imageUrl: post.imageUrl ?? '',
              width: double.infinity,
              ),
          ),
        ),
        AnimatedBuilder(
          animation: handler.getHeartAnimation(postId) ?? const AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            final animation = handler.getHeartAnimation(postId);
            if (animation == null || animation.value == 0.8) {
              return const SizedBox.shrink();
            }
            return Transform.scale(
              scale: animation.value,
              child: Icon(
                Icons.favorite,
                color: Colors.red.withOpacity(0.8),
                size: 80,
              ),
            );
          },
        ),
      ],
    );
  }
}