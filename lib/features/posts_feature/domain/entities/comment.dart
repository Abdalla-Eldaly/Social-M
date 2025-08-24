import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';

class Comment {
  final int? id;
  final String? content;
  final DateTime? createdAt;
  final int? userId;
  final User? user;

  Comment({
    this.id,
    this.content,
    this.createdAt,
    this.userId,
    this.user,
  });
}