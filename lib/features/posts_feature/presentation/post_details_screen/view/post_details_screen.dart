// post_details_screen.dart
import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:social_m_app/core/utils/theme/app_color.dart';
import 'package:social_m_app/core/providers/user_provider.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/utils/Functions/unauthorized_handler.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/comment.dart';
import '../cubit/post_details_cubit.dart';
import '../cubit/post_details_states.dart';

@RoutePage()
class PostDetailsView extends StatelessWidget {
  final int postId;
  final Post? initialPost;

  const PostDetailsView({
    super.key,
    required this.postId,
    this.initialPost,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<PostDetailsCubit>();
        cubit.setContext(context); // Set context for unauthorized handling
        cubit.loadPostDetails(postId);
        return cubit;
      },
      child: _PostDetailsContent(initialPost: initialPost),
    );
  }
}

class _PostDetailsContent extends StatefulWidget {
  final Post? initialPost;

  const _PostDetailsContent({this.initialPost});

  @override
  State<_PostDetailsContent> createState() => _PostDetailsContentState();
}

class _PostDetailsContentState extends State<_PostDetailsContent>
    with TickerProviderStateMixin, UnauthorizedMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();
  late AnimationController _likeAnimationController;
  late AnimationController _bookmarkAnimationController;
  late Animation<double> _likeAnimation;
  late Animation<double> _bookmarkAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bookmarkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _likeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));

    _bookmarkAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bookmarkAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    _likeAnimationController.dispose();
    _bookmarkAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<PostDetailsCubit, PostDetailsState>(
        listener: (context, state) {
          // Handle comment errors (non-auth errors)
          if (state is PostDetailsCommentError) {
            _handleCommentError(context, state);
          }
        },
        builder: (context, state) {
          if (state is PostDetailsLoading && widget.initialPost == null) {
            return _buildLoadingState();
          } else if (state is PostDetailsLoaded || widget.initialPost != null) {
            final post = state is PostDetailsLoaded ? state.post : widget.initialPost!;
            final isLiked = state is PostDetailsLoaded ? state.isLiked : (post.isLikedByUser ?? false);
            final isBookmarked = state is PostDetailsLoaded ? state.isBookmarked : false;
            final isFollowing = state is PostDetailsLoaded ? state.isFollowing : false;
            final isRefreshing = state is PostDetailsLoaded ? state.isRefreshing : false;
            final totalCommentCount = state is PostDetailsLoaded
                ? state.totalCommentCount
                : (post.comments?.length ?? 0);

            return _buildPostDetails(
              context,
              post,
              isLiked,
              isBookmarked,
              isFollowing,
              state is PostDetailsLoaded ? state.allComments : post.comments ?? [],
              state is PostDetailsLoaded ? state.isAddingComment : false,
              totalCommentCount,
              isRefreshing,
            );
          } else if (state is PostDetailsError) {
            return _buildErrorState(state.message);
          }
          return _buildLoadingState();
        },
      ),
      bottomNavigationBar: _buildCommentInputBar(),
    );
  }

  void _handleCommentError(BuildContext context, PostDetailsCommentError state) {
    // Only handle non-auth errors here (auth errors are handled by UnauthorizedHandler)
    if (!_isUnauthorizedError(state.errorMessage)) {
      // Restore failed comment text
      if (state.failedCommentText.isNotEmpty) {
        _commentController.text = state.failedCommentText;
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.white),
              SizedBox(width: 8),
              Expanded(child: Text(state.errorMessage)),
            ],
          ),
          backgroundColor: AppColors.errorRed,
          action: state.failedCommentText.isNotEmpty
              ? SnackBarAction(
            label: 'Retry',
            textColor: AppColors.white,
            onPressed: () {
              context.read<PostDetailsCubit>().retryFailedComment(state.failedCommentText);
            },
          )
              : null,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );

      // Clear error state
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<PostDetailsCubit>().clearCommentError();
        }
      });
    }
  }

  bool _isUnauthorizedError(String errorMessage) {
    final unauthorizedKeywords = [
      'unauthorized',
      'unauthenticated',
      '401',
      'token expired',
      'invalid token',
      'authentication required',
      'login required',
    ];

    final lowerError = errorMessage.toLowerCase();
    return unauthorizedKeywords.any((keyword) => lowerError.contains(keyword));
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PostDetailsCubit>().refreshPost();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostDetails(
      BuildContext context,
      Post post,
      bool isLiked,
      bool isBookmarked,
      bool isFollowing,
      List<Comment> comments,
      bool isAddingComment,
      int totalCommentCount,
      bool isRefreshing,
      ) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<PostDetailsCubit>().refreshPost();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context, post.user, isFollowing),
          if (isRefreshing)
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.fieldFill,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostImage(post.imageUrl),
                _buildActionButtons(context, isLiked, isBookmarked),
                _buildPostInfo(post, isLiked),
                _buildCommentSection(comments, totalCommentCount),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, User? user, bool isFollowing) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      pinned: true,
      leadingWidth: 30,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            backgroundImage: user?.profileImageUrl != null
                ? CachedNetworkImageProvider(user!.profileImageUrl!)
                : null,
            child: user?.profileImageUrl == null
                ? Text(
              user?.username?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user?.username ?? 'Unknown User',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            if (userProvider.isAuthenticated &&
                user?.id != userProvider.currentUser?.id &&
                !isFollowing) {
              return AuthRequiredWrapper(
                action: 'follow this user',
                onTap: () {
                  context.read<PostDetailsCubit>().toggleFollow();
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: null, // Handled by wrapper
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'share':
                context.read<PostDetailsCubit>().sharePost();
                break;
              case 'report':
                _showReportDialog(context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 12),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report, size: 20, color: AppColors.errorRed),
                  SizedBox(width: 12),
                  Text('Report', style: TextStyle(color: AppColors.errorRed)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 400,
        color: AppColors.fieldFill,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      height: 400,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.fieldFill,
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.broken_image,
              size: 64,
              color: AppColors.textSecondary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLiked, bool isBookmarked) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Like button with auth wrapper
          AuthRequiredWrapper(
            action: 'like this post',
            onTap: () {
              context.read<PostDetailsCubit>().toggleLike();
              HapticFeedback.lightImpact();
              _likeAnimationController.forward().then((_) {
                _likeAnimationController.reverse();
              });
            },
            child: AnimatedBuilder(
              animation: _likeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _likeAnimation.value,
                  child: IconButton(
                    onPressed: null, // Handled by wrapper
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? AppColors.red : AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),

          // Comment button (no auth required to focus input)
          IconButton(
            onPressed: () {
              _focusCommentInput();
            },
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),

          // Share button (no auth required)
          IconButton(
            onPressed: () {
              context.read<PostDetailsCubit>().sharePost();
            },
            icon: const Icon(
              Icons.send_outlined,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),

          const Spacer(),

          // Bookmark button with auth wrapper
          AuthRequiredWrapper(
            action: 'bookmark this post',
            onTap: () {
              context.read<PostDetailsCubit>().toggleBookmark();
              HapticFeedback.lightImpact();
              _bookmarkAnimationController.forward().then((_) {
                _bookmarkAnimationController.reverse();
              });
            },
            child: AnimatedBuilder(
              animation: _bookmarkAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bookmarkAnimation.value,
                  child: IconButton(
                    onPressed: null, // Handled by wrapper
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? AppColors.primary : AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostInfo(Post post, bool isLiked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.likesCount != null && post.likesCount! > 0)
            Text(
              '${_formatCount(post.likesCount!)} likes',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (post.caption != null && post.caption!.isNotEmpty) ...[
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${post.user?.username ?? ''} ',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: post.caption,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (post.createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatDate(post.createdAt!),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentSection(List<Comment> comments, int totalCommentCount) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (totalCommentCount > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Comments ($totalCommentCount)',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...comments.map((comment) => _buildCommentItem(comment)),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'No comments yet',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Be the first to comment!',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return BlocBuilder<PostDetailsCubit, PostDetailsState>(
      builder: (context, state) {
        final isPending = state is PostDetailsLoaded && state.isCommentPending(comment.id ?? 0);

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isPending ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.grey,
                    backgroundImage: comment.user?.profileImageUrl != null
                        ? CachedNetworkImageProvider(comment.user!.profileImageUrl!)
                        : null,
                    child: comment.user?.profileImageUrl == null
                        ? Text(
                      comment.user?.username?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                  if (isPending)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedOpacity(
                  opacity: isPending ? 0.8 : 1.0,
                  duration: Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${comment.user?.username ?? 'Unknown'} ',
                              style: TextStyle(
                                color: isPending ? AppColors.primary : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: comment.content ?? '',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (comment.createdAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Text(
                                _formatDate(comment.createdAt!),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              if (isPending) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Posting...',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.grey.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: userProvider.isLoggedIn
                          ? 'Add a comment...'
                          : 'Login to add comments...',
                      hintStyle: TextStyle(
                        color: userProvider.isLoggedIn
                            ? AppColors.textSecondary
                            : AppColors.textSecondary.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: userProvider.isLoggedIn
                          ? AppColors.fieldFill
                          : AppColors.fieldFill.withOpacity(0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    enabled: userProvider.isLoggedIn,
                    maxLines: null,
                    maxLength: 500,
                    buildCounter: (context, {required currentLength, maxLength, required isFocused}) {
                      return null;
                    },
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) => _submitComment(),
                    onChanged: (value) => setState(() {}), // Trigger rebuild for send button state
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<PostDetailsCubit, PostDetailsState>(
                  builder: (context, state) {
                    final isAddingComment = state is PostDetailsLoaded && state.isAddingComment;
                    final canSend = userProvider.isLoggedIn &&
                        _commentController.text.trim().isNotEmpty &&
                        !isAddingComment;

                    return AuthRequiredWrapper(
                      action: 'add a comment',
                      onTap: canSend ? _submitComment : null,
                      requiresAuth: true,
                      child: IconButton(
                        onPressed: canSend ? () => _submitComment() : null,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isAddingComment
                              ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          )
                              : Icon(
                            key: const ValueKey('send'),
                            Icons.send,
                            color: canSend ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _focusCommentInput() {
    _commentFocusNode.requestFocus();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _submitComment() {
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      context.read<PostDetailsCubit>().addComment(comment);
      _commentController.clear();

      // Don't unfocus immediately - let user see the pending comment first
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _commentFocusNode.unfocus();
        }
      });

      // Auto-scroll to show the new comment
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients && mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showReportDialog(BuildContext context) async {
    final shouldProceed = await checkAuth(
      action: 'report this post',
      onLoginSuccess: () => _showReportDialog(context),
    );

    if (!shouldProceed) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Post'),
          content: const Text('Are you sure you want to report this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<PostDetailsCubit>().reportPost();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post reported successfully'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
              child: const Text(
                'Report',
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}