import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_m_app/core/utils/theme/app_images.dart';
import 'package:social_m_app/core/utils/widgets/custom_cached_image.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';
import 'package:social_m_app/features/posts_feature/presentation/home_screen/view/_widgets/post_options_widget.dart';

class PostHeaderWidget extends StatelessWidget {
  final Post post;

  const PostHeaderWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: post.user?.profileImageUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedImage(
                imageUrl: post.user!.profileImageUrl!,
                width: 50,
                height: 50,
              ),
            )

                : Icon(
              Icons.person,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.user?.username ?? 'unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (post.location != null)
                  Row(
                    children: [
                    SvgPicture.asset(SvgPath.location,width: 22,height: 22,),
                      const SizedBox(width: 4),
                      Text(
                        'Altitude: ${post.location?.altitude?.toStringAsFixed(1) ?? '0.0'}m',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => PostOptionsWidget.show(context, post),
          ),


        ],
      ),
    );
  }
}