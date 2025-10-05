import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';
import 'comment.dart';
import 'location.dart';

class Post {
  final int? id;
  final int? commentsCount;
  final String? imageUrl;
  final String? caption;
  final DateTime? createdAt;
  final int? userId;
  final User? user;
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
    this.user,
    this.likesCount,
    this.isLikedByUser,
    this.location,
    this.comments,
    this.commentsCount,
  });

  Post copyWith({
    int? id,
    String? imageUrl,
    String? caption,
    DateTime? createdAt,
    int? userId,
    User? user,
    int? likesCount,
    bool? isLikedByUser,
    Location? location,
    List<Comment>? comments,
    int? commentsCount,
  }) {
    return Post(
      id: id ?? this.id,
      commentsCount: commentsCount ?? this.commentsCount,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      likesCount: likesCount ?? this.likesCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      location: location ?? this.location,
      comments: comments ?? this.comments,
    );
  }
}