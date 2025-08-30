import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:social_m_app/core/config/router/app_router.dart';
import 'package:social_m_app/core/di/di.dart';
import 'package:social_m_app/core/utils/theme/app_color.dart';
import 'package:social_m_app/core/utils/theme/app_dialogs.dart';
import 'package:social_m_app/core/utils/theme/app_images.dart';
import 'package:social_m_app/core/utils/widgets/custom_cached_image.dart';
import '../../../../../../core/providers/user_provider.dart';
import '../../../../domain/entities/post_entity.dart';
import '../../cubit/comment_cubit.dart';
import '../../cubit/post_cubit.dart';
import '../../cubit/post_state.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  String _formatTimestamp(DateTime? createdAt) {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
   final userProvider = context.read<UserProvider>();
    final isGuest = userProvider.isGuest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: CachedImage(
                  imageUrl:
                  post.user?.profileImageUrl ?? 'https://via.placeholder.com/40',
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user?.username ?? 'Unknown',
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (post.location != null)
                      Text(
                        post.location!.altitude.toString(),
                        style: textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  if (isGuest) {
                    AppDialogs.showInfoDialog(
                      message: 'Please log in to access post options.',
                      posAction: () {
                        context.replaceRoute(const LoginRoute());
                      },
                      posActionTitle: 'Log In',
                      negativeAction: () {},
                      negativeActionTitle: 'Cancel',
                      context: context,
                    );
                  } else {

                  }
                },
              ),
            ],
          ),
        ),

        // Post image
        if (post.imageUrl != null)
          CachedImage(
            imageUrl: post.imageUrl!,
            height: 400,
            width: double.infinity,
          ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: isGuest
                    ? () {
                  AppDialogs.showInfoDialog(
                    message: 'Please log in to like posts.',
                    posAction: () {
                      context.replaceRoute(LoginRoute());
                    },
                    posActionTitle: 'Log In',
                    negativeAction: () {},
                    negativeActionTitle: 'Cancel',
                    context: context,
                  );
                }
                    : () {
                  context.read<PostCubit>().togglePostLike(
                    post.id ?? -1,
                    !(post.isLikedByUser ?? false),
                  );
                },
                child: SvgPicture.asset(
                  SvgPath.love,
                  colorFilter: ColorFilter.mode(
                    (post.isLikedByUser ?? false)
                        ? AppColors.red
                        : AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: isGuest
                    ? () {
                  AppDialogs.showInfoDialog(
                    message: 'Please log in to comment.',
                    posAction: () {
                      context.replaceRoute(LoginRoute());
                    },
                    posActionTitle: 'Log In',
                    negativeAction: () {},
                    negativeActionTitle: 'Cancel',
                    context: context,
                  );
                }
                    : () => _showCommentsBottomSheet(context, post),
                child: SvgPicture.asset(
                  SvgPath.comment,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),

        // Likes count
        if (post.likesCount != null && post.likesCount! > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${post.likesCount} ${post.likesCount == 1 ? 'like' : 'likes'}',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

        // Caption
        if (post.caption != null && post.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: post.user?.username ?? 'Unknown',
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: post.caption,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

        // Comments preview (restricted for guests)
        if (!isGuest)
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              final comments = (state is PostLoaded
                  ? state.paginatedPosts.items
                  ?.firstWhere((p) => p.id == post.id, orElse: () => post)
                  .comments
                  : post.comments) ??
                  [];

              if (comments.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _showCommentsBottomSheet(context, post),
                        child: Text(
                          'View all ${comments.length} comments',
                          style: textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                      ...comments.take(2).map(
                            (comment) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: CachedImage(
                                  imageUrl: comment.user?.profileImageUrl ??
                                      'https://via.placeholder.com/30',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                        comment.user?.username ?? 'Unknown',
                                        style: textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const TextSpan(text: ' '),
                                      TextSpan(
                                        text: comment.content,
                                        style: textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

        // Timestamp
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            _formatTimestamp(post.createdAt),
            style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  void _showCommentsBottomSheet(BuildContext context, Post post) {
    final postCubit = context.read<PostCubit>();
    final userProvider = context.read<UserProvider>();

    // Prevent showing comment sheet for guests
    if (userProvider.isGuest) {
      AppDialogs.showInfoDialog(
        message: 'Please log in to view or add comments.',
        posAction: () {
          context.replaceRoute(LoginRoute());
        },
        posActionTitle: 'Log In',
        negativeAction: () {},
        negativeActionTitle: 'Cancel',
        context: context,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider(
          create: (context) => getIt<CommentCubit>(),
          child: _CommentBottomSheet(
            post: post,
            postCubit: postCubit,
          ),
        );
      },
    );
  }
}

class _CommentBottomSheet extends StatefulWidget {
  final Post post;
  final PostCubit postCubit;

  const _CommentBottomSheet({required this.post, required this.postCubit});

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use context.read to avoid rebuilds
    final userProvider = context.read<UserProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // Comments list
                Expanded(
                  child: BlocListener<CommentCubit, CommentState>(
                    listener: (context, state) {
                      if (state is CommentAddedSuccess) {
                        _commentController.clear();
                        widget.postCubit.updatePostWithNewComment(
                          widget.post.id ?? -1,
                          state.newComment,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Comment added successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is CommentError) {
                        AppDialogs.showFailDialog(
                          message: state.message,
                          negativeAction: () {},
                          negativeActionTitle: 'Cancel',
                          posAction: () {},
                          posActionTitle: 'OK',
                          context: context,
                        );
                      }
                    },
                    child: BlocBuilder<PostCubit, PostState>(
                      bloc: widget.postCubit,
                      builder: (context, state) {
                        final comments = (state is PostLoaded
                            ? state.paginatedPosts.items?.firstWhere(
                                (p) => p.id == widget.post.id,
                            orElse: () => widget.post)
                            ?.comments
                            : widget.post.comments) ??
                            [];

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: CachedImage(
                                  imageUrl: comment.user?.profileImageUrl ??
                                      'https://via.placeholder.com/30',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                              title: Text(comment.user?.username ?? "Unknown"),
                              subtitle: Text(comment.content ?? ""),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Comment Input
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: BlocBuilder<CommentCubit, CommentState>(
                    builder: (context, state) {
                      final isLoading = state is CommentLoading;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              enabled: !isLoading && !userProvider.isGuest,
                              decoration: InputDecoration(
                                hintText: userProvider.isGuest
                                    ? "Log in to comment"
                                    : "Add a comment...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: isLoading
                                ? const CircularProgressIndicator(strokeWidth: 2)
                                : const Icon(Icons.send, color: Colors.blue),
                            onPressed: isLoading || userProvider.isGuest
                                ? null
                                : () {
                              if (_commentController.text.isNotEmpty) {
                                context.read<CommentCubit>().addComment(
                                  widget.post.id ?? -1,
                                  _commentController.text,
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}