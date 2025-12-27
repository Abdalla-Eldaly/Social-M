// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CreatePostView]
class CreatePostRoute extends PageRouteInfo<void> {
  const CreatePostRoute({List<PageRouteInfo>? children})
      : super(CreatePostRoute.name, initialChildren: children);

  static const String name = 'CreatePostRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreatePostView();
    },
  );
}

/// generated route for
/// [HomeView]
class HomeRoute extends PageRouteInfo<HomeRouteArgs> {
  HomeRoute({
    Key? key,
    ScrollController? scrollController,
    List<PageRouteInfo>? children,
  }) : super(
          HomeRoute.name,
          args: HomeRouteArgs(key: key, scrollController: scrollController),
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HomeRouteArgs>(
        orElse: () => const HomeRouteArgs(),
      );
      return HomeView(key: args.key, scrollController: args.scrollController);
    },
  );
}

class HomeRouteArgs {
  const HomeRouteArgs({this.key, this.scrollController});

  final Key? key;

  final ScrollController? scrollController;

  @override
  String toString() {
    return 'HomeRouteArgs{key: $key, scrollController: $scrollController}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HomeRouteArgs) return false;
    return key == other.key && scrollController == other.scrollController;
  }

  @override
  int get hashCode => key.hashCode ^ scrollController.hashCode;
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MainLayoutView]
class MainLayoutRoute extends PageRouteInfo<void> {
  const MainLayoutRoute({List<PageRouteInfo>? children})
      : super(MainLayoutRoute.name, initialChildren: children);

  static const String name = 'MainLayoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainLayoutView();
    },
  );
}

/// generated route for
/// [OnboardingView]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
      : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingView();
    },
  );
}

/// generated route for
/// [PostDetailsView]
class PostDetailsRoute extends PageRouteInfo<PostDetailsRouteArgs> {
  PostDetailsRoute({
    Key? key,
    required int postId,
    Post? initialPost,
    List<PageRouteInfo>? children,
  }) : super(
          PostDetailsRoute.name,
          args: PostDetailsRouteArgs(
            key: key,
            postId: postId,
            initialPost: initialPost,
          ),
          initialChildren: children,
        );

  static const String name = 'PostDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostDetailsRouteArgs>();
      return PostDetailsView(
        key: args.key,
        postId: args.postId,
        initialPost: args.initialPost,
      );
    },
  );
}

class PostDetailsRouteArgs {
  const PostDetailsRouteArgs({
    this.key,
    required this.postId,
    this.initialPost,
  });

  final Key? key;

  final int postId;

  final Post? initialPost;

  @override
  String toString() {
    return 'PostDetailsRouteArgs{key: $key, postId: $postId, initialPost: $initialPost}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDetailsRouteArgs) return false;
    return key == other.key &&
        postId == other.postId &&
        initialPost == other.initialPost;
  }

  @override
  int get hashCode => key.hashCode ^ postId.hashCode ^ initialPost.hashCode;
}

/// generated route for
/// [ProfileView]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileView();
    },
  );
}

/// generated route for
/// [RegisterView]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
      : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterView();
    },
  );
}

/// generated route for
/// [SearchView]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
      : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchView();
    },
  );
}

/// generated route for
/// [StoryView]
class StoryRoute extends PageRouteInfo<void> {
  const StoryRoute({List<PageRouteInfo>? children})
      : super(StoryRoute.name, initialChildren: children);

  static const String name = 'StoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StoryView();
    },
  );
}
