import 'package:flutter/material.dart';
import 'package:social_m_app/core/utils/widgets/custom_cached_image.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/comment.dart';

class CommentItemWidget extends StatelessWidget {
  final Comment comment;

  const CommentItemWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CircleAvatar(
          //   radius: 12,
          //   backgroundColor: Colors.grey[300],
          //   child: comment.user?.profileImageUrl != null
          //       ? CachedImage(
          //     imageUrl: comment.user!.profileImageUrl!,
          //      width: 24,
          //     height: 24,
          //      : true,
          //   )
          //       : Icon(
          //     Icons.person,
          //     size: 14,
          //     color: Colors.grey[600],
          //   ),
          // ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      // TextSpan(
                      //   text: '${comment.user?.username ?? 'unknown'} ',
                      //   style: const TextStyle(
                      //     fontWeight: FontWeight.w600,
                      //     color: Colors.black,
                      //     fontSize: 13,
                      //   ),
                      // ),
                      TextSpan(
                        text: comment.content ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(comment.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Handle comment like
            },
            child: Icon(
              Icons.favorite_border,
              size: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}