import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_m_app/core/utils/widgets/custom_cached_image.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';
import 'package:social_m_app/features/posts_feature/presentation/profile_screen/cubit/profile_cubit.dart';
import 'package:social_m_app/features/posts_feature/presentation/profile_screen/cubit/posts_state.dart';

Widget buildStatsSection(BuildContext context, dynamic state) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildAnimatedStatItem(
          state.posts?.length.toString() ?? '0',
          'Posts',
          Icons.grid_on_rounded,
          Colors.orange,
          onTap: null,
        ),
        buildStatDivider(),
        buildAnimatedStatItem(
          state.user.followersCount?.toString() ?? '0',
          'Followers',
          Icons.people_rounded,
          Colors.green,
          onTap: () => _showFollowersBottomSheet(context, state),
        ),
        buildStatDivider(),
        buildAnimatedStatItem(
          state.user.followingCount?.toString() ?? '0',
          'Following',
          Icons.person_add_rounded,
          Colors.purple,
          onTap: () => _showFollowingBottomSheet(context, state),
        ),
      ],
    ),
  );
}

Widget buildAnimatedStatItem(
    String count,
    String label,
    IconData icon,
    Color color, {
      VoidCallback? onTap,
    }) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: onTap != null ? color.withOpacity(0.05) : Colors.transparent,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildStatDivider() {
  return Container(
    height: 40,
    width: 1,
    color: Colors.grey[300],
  );
}

 void _showFollowersBottomSheet(BuildContext context, ProfileAuthenticated state) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Followers',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.followers?.length ?? 0}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _buildFollowersContent(state, scrollController),
            ),
          ],
        ),
      ),
    ),
  );
}

// Following Bottom Sheet
void _showFollowingBottomSheet(BuildContext context, ProfileAuthenticated state) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Following',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.following?.length ?? 0}',
                      style: TextStyle(
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _buildFollowingContent(state, scrollController),
            ),
          ],
        ),
      ),
    ),
  );
}

// Followers Content Widget
Widget _buildFollowersContent(ProfileAuthenticated state, ScrollController scrollController) {
  if (state.followersError != null) {
    return _buildErrorState(
      'Unable to load followers',
      state.followersError!,
      Icons.people_outline,
      Colors.green,
    );
  }

  if (state.followers == null) {
    return _buildLoadingState('Loading followers...', Colors.green);
  }

  if (state.followers!.isEmpty) {
    return _buildEmptyState(
      'No followers yet',
      'When people follow you, they\'ll appear here',
      Icons.people_outline,
      Colors.green,
    );
  }

  return ListView.builder(
    controller: scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: state.followers!.length,
    itemBuilder: (context, index) {
      final user = state.followers![index];
      return _buildUserListItem(user, Colors.green);
    },
  );
}

// Following Content Widget
Widget _buildFollowingContent(ProfileAuthenticated state, ScrollController scrollController) {
  if (state.followingError != null) {
    return _buildErrorState(
      'Unable to load following',
      state.followingError!,
      Icons.person_add_outlined,
      Colors.purple,
    );
  }

  if (state.following == null) {
    return _buildLoadingState('Loading following...', Colors.purple);
  }

  if (state.following!.isEmpty) {
    return _buildEmptyState(
      'Not following anyone',
      'Discover and follow users to see them here',
      Icons.person_add_outlined,
      Colors.purple,
    );
  }

  return ListView.builder(
    controller: scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: state.following!.length,
    itemBuilder: (context, index) {
      final user = state.following![index];
      return _buildUserListItem(user, Colors.purple);
    },
  );
}

// User List Item Widget
Widget _buildUserListItem(User user, Color themeColor) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Row(
      children: [
        // Profile Picture
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                themeColor.withOpacity(0.8),
                themeColor.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
              ? ClipOval(
            child: CachedImage(
             imageUrl:  user.profileImageUrl??'',
              width: 50,
              height: 50,
               ),
          )
              : _buildDefaultAvatar(user, themeColor),
        ),
        const SizedBox(width: 16),
        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username ?? 'Unknown User',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (user.username != null) ...[
                const SizedBox(height: 2),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (user.bio != null && user.bio!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  user.bio!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        // Action Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: themeColor.withOpacity(0.3)),
          ),
          child: Text(
            'View',
            style: TextStyle(
              color: themeColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

// Default Avatar Widget
Widget _buildDefaultAvatar(User user, Color themeColor) {
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          themeColor.withOpacity(0.8),
          themeColor.withOpacity(0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Text(
        _getInitials(user.username ?? 'U'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ),
  );
}

// Get initials from name
String _getInitials(String name) {
  List<String> nameParts = name.trim().split(' ');
  if (nameParts.length >= 2) {
    return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
  } else if (nameParts.isNotEmpty) {
    return nameParts[0][0].toUpperCase();
  }
  return 'U';
}

// Loading State Widget
Widget _buildLoadingState(String message, Color themeColor) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: CircularProgressIndicator(
            color: themeColor,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// Empty State Widget
Widget _buildEmptyState(String title, String subtitle, IconData icon, Color themeColor) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 60,
            color: themeColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

// Error State Widget
Widget _buildErrorState(String title, String error, IconData icon, Color themeColor) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[400],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // ElevatedButton.icon(
        //   onPressed: () => Navigator.of(context).pop(),
        //   icon: const Icon(Icons.refresh),
        //   label: const Text('Try Again'),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: themeColor,
        //     foregroundColor: Colors.white,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(25),
        //     ),
        //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        //   ),
        // ),
      ],
    ),
  );
}

// Alternative: Full Screen Pages for Followers/Following
class FollowersScreen extends StatelessWidget {
  const FollowersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Followers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthenticated) {
            return _buildFollowersPageContent(state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFollowersPageContent(ProfileAuthenticated state) {
    if (state.followersError != null) {
      return _buildErrorState(
        'Unable to load followers',
        state.followersError!,
        Icons.people_outline,
        Colors.green,
      );
    }

    if (state.followers == null) {
      return _buildLoadingState('Loading followers...', Colors.green);
    }

    if (state.followers!.isEmpty) {
      return _buildEmptyState(
        'No followers yet',
        'When people follow you, they\'ll appear here',
        Icons.people_outline,
        Colors.green,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.followers!.length,
      itemBuilder: (context, index) {
        final user = state.followers![index];
        return _buildUserListItem(user, Colors.green);
      },
    );
  }
}

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Following',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthenticated) {
            return _buildFollowingPageContent(state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFollowingPageContent(ProfileAuthenticated state) {
    if (state.followingError != null) {
      return _buildErrorState(
        'Unable to load following',
        state.followingError!,
        Icons.person_add_outlined,
        Colors.purple,
      );
    }

    if (state.following == null) {
      return _buildLoadingState('Loading following...', Colors.purple);
    }

    if (state.following!.isEmpty) {
      return _buildEmptyState(
        'Not following anyone',
        'Discover and follow users to see them here',
        Icons.person_add_outlined,
        Colors.purple,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.following!.length,
      itemBuilder: (context, index) {
        final user = state.following![index];
        return _buildUserListItem(user, Colors.purple);
      },
    );
  }
}

// Search Widget for Users (Optional Enhancement)
class UserSearchWidget extends StatefulWidget {
  final List<User> users;
  final Function(List<User>) onSearchResults;
  final Color themeColor;

  const UserSearchWidget({
    Key? key,
    required this.users,
    required this.onSearchResults,
    required this.themeColor,
  }) : super(key: key);

  @override
  State<UserSearchWidget> createState() => _UserSearchWidgetState();
}

class _UserSearchWidgetState extends State<UserSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      widget.onSearchResults(widget.users);
    } else {
      final filteredUsers = widget.users.where((user) {
        final name = user.username?.toLowerCase() ?? '';
        final username = user.username?.toLowerCase() ?? '';
        return name.contains(query) || username.contains(query);
      }).toList();
      widget.onSearchResults(filteredUsers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search users...',
          prefixIcon: Icon(Icons.search, color: widget.themeColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

