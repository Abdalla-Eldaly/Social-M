import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';

import 'comment.dart';
import 'location.dart';

class Post {
  final int? id;
  final String? imageUrl;
  final String? caption;
  final DateTime? createdAt;
  final int? userId;
  final User? user; // Add this
  final int? likesCount;
  final bool? isLikedByUser;
  final Location? location;
  final List<Comment>? comments;

  Post({
    this.id,
    this.imageUrl,
    this.caption,
    this.createdAt,
    this.userId,
    this.user, // Add this
    this.likesCount,
    this.isLikedByUser,
    this.location,
    this.comments,
  });
}