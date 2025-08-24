import 'package:flutter/material.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_actions_widget.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_caption_widget.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_header_widget.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_image_widget.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_time_widget.dart';

import 'comments_section_widget.dart';
import 'comments_toggle_widget.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeaderWidget(post: post),
          PostImageWidget(post: post),
          PostActionsWidget(post: post),
          PostCaptionWidget(post: post),
          CommentsToggleWidget(post: post),
          CommentsSectionWidget(post: post),
          PostTimeWidget(post: post),
        ],
      ),
    );
  }
}