import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/config/router/app_router.dart';
import '../../../../../core/utils/theme/app_color.dart';
import '../../create_post/view/create_post_screen.dart';
import '../../home_screen/view/home_screen.dart';
import '../../profile_screen/view/profile_screen.dart';
import '../../story_screen/view/story_screen.dart';
import '../view_model/main_lay_out_view_model.dart';

@RoutePage()
class MainLayoutView extends StatelessWidget {
  const MainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainLayoutViewModel(),
      child: const MainLayoutViewBody(),
    );
  }
}

class MainLayoutViewBody extends StatefulWidget {
  const MainLayoutViewBody({super.key});

  @override
  State<MainLayoutViewBody> createState() => _MainLayoutViewBodyState();
}

class _MainLayoutViewBodyState extends State<MainLayoutViewBody>
    with TickerProviderStateMixin {
  late AnimationController _hideAnimationController;
  late Animation<double> _hideAnimation;

  // Scroll controller management
  final Map<int, ScrollController> _scrollControllers = {};
  bool _isBottomNavVisible = true;
  bool _isKeyboardVisible = false;

  // Scroll behavior tracking
  double _lastScrollOffset = 0.0;
  bool _isScrollingDown = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollControllers();

    // Listen to keyboard visibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToKeyboard();
    });
  }

  void _initializeAnimations() {
    _hideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _hideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hideAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeScrollControllers() {
    // Initialize scroll controllers for each tab
    for (int i = 0; i < 4; i++) {
      _scrollControllers[i] = ScrollController();
      _scrollControllers[i]!.addListener(() => _onScroll(i));
    }
  }

  void _listenToKeyboard() {
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;

    if (isKeyboardOpen != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = isKeyboardOpen;
      });

      if (isKeyboardOpen) {
        _hideBottomNavBar();
      } else {
        _showBottomNavBar();
      }
    }
  }

  void _onScroll(int tabIndex) {
    final controller = _scrollControllers[tabIndex];
    if (controller == null || !controller.hasClients) return;

    final currentOffset = controller.offset;
    final scrollDelta = currentOffset - _lastScrollOffset;

    // Enhanced scroll direction detection with sensitivity threshold
    const double scrollSensitivity = 10.0;

    if (scrollDelta.abs() > scrollSensitivity) {
      final isScrollingDown = scrollDelta > 0;

      if (isScrollingDown != _isScrollingDown) {
        _isScrollingDown = isScrollingDown;

        // Hide/show bottom nav based on scroll direction
        if (isScrollingDown && _isBottomNavVisible && !_isKeyboardVisible) {
          _hideBottomNavBar();
        } else if (!isScrollingDown && !_isBottomNavVisible && !_isKeyboardVisible) {
          _showBottomNavBar();
        }
      }

      _lastScrollOffset = currentOffset;
    }

    // Auto-show bottom nav when near top
    if (currentOffset <= 100 && !_isBottomNavVisible && !_isKeyboardVisible) {
      _showBottomNavBar();
    }
  }

  void _showBottomNavBar() {
    if (!_isBottomNavVisible) {
      setState(() {
        _isBottomNavVisible = true;
      });
      _hideAnimationController.reverse();
    }
  }

  void _hideBottomNavBar() {
    if (_isBottomNavVisible) {
      setState(() {
        _isBottomNavVisible = false;
      });
      _hideAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _hideAnimationController.dispose();

    // Dispose scroll controllers
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainLayoutViewModel>(context);

    // Listen to keyboard changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToKeyboard();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: viewModel.currentIndex,
        children: [
          // Home with scroll controller
          HomeView(scrollController: _scrollControllers[0]),

          // Create Post
          const CreatePostView(),

          // Stories
          const StoryView(),

          // Profile
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: _buildCleanBottomNavBar(context, viewModel),
    );
  }

  Widget _buildCleanBottomNavBar(
      BuildContext context,
      MainLayoutViewModel viewModel,
      ) {
    return AnimatedBuilder(
      animation: _hideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * _hideAnimation.value),
          child: Container(
            height: 70 + MediaQuery.of(context).padding.bottom,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabItem(
                      context: context,
                      index: 0,
                      currentIndex: viewModel.currentIndex,
                      icon: CupertinoIcons.house,
                      selectedIcon: CupertinoIcons.house_fill,
                      label: 'Home',
                      onTap: () => _onTabTapped(0, viewModel),
                    ),
                    _buildTabItem(
                      context: context,
                      index: 1,
                      currentIndex: viewModel.currentIndex,
                      icon: CupertinoIcons.plus_square,
                      selectedIcon: CupertinoIcons.plus_square_fill,
                      label: 'Create',
                      onTap: () => _onTabTapped(1, viewModel),
                    ),
                    _buildTabItem(
                      context: context,
                      index: 2,
                      currentIndex: viewModel.currentIndex,
                      icon: CupertinoIcons.play_circle,
                      selectedIcon: CupertinoIcons.play_circle_fill,
                      label: 'Stories',
                      onTap: () => _onTabTapped(2, viewModel),
                    ),
                    _buildTabItem(
                      context: context,
                      index: 3,
                      currentIndex: viewModel.currentIndex,
                      icon: CupertinoIcons.person,
                      selectedIcon: CupertinoIcons.person_fill,
                      label: 'Profile',
                      onTap: () => _onTabTapped(3, viewModel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;
    final tabColors = _getTabColors(index);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? tabColors['background'] : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: tabColors['primary']!.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? selectedIcon : icon,
                      key: ValueKey('${index}_${isSelected}'),
                      size: isSelected ? 22 : 20,
                      color: isSelected ? tabColors['primary'] : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 10 : 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? tabColors['primary'] : Colors.grey.shade500,
                ),
                child: FittedBox(child: Text(label)),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(top: 2),
                width: isSelected ? 20 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: tabColors['primary'],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Color> _getTabColors(int index) {
    switch (index) {
      case 0: // Home
        return {
          'primary': Colors.blue.shade600,
          'background': Colors.blue.shade50,
        };
      case 1: // Create
        return {
          'primary': Colors.purple.shade600,
          'background': Colors.purple.shade50,
        };
      case 2: // Stories
        return {
          'primary': Colors.orange.shade600,
          'background': Colors.orange.shade50,
        };
      case 3: // Profile
        return {
          'primary': Colors.green.shade600,
          'background': Colors.green.shade50,
        };
      default:
        return {
          'primary': Colors.blue.shade600,
          'background': Colors.blue.shade50,
        };
    }
  }

  void _onTabTapped(int index, MainLayoutViewModel viewModel) {
    if (index == viewModel.currentIndex) {
      // Double tap - scroll to top and show bottom nav
      _scrollToTop(index);
      _showBottomNavBar();
    } else {
      // Switch tabs
      viewModel.setTabIndex(index);
      _showBottomNavBar(); // Always show nav when switching tabs
    }
  }

  void _scrollToTop(int index) {
    final controller = _scrollControllers[index];
    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Get scroll controller for external access
  ScrollController? getScrollController(int index) {
    return _scrollControllers[index];
  }

  // Public method to control bottom nav visibility
  void setBottomNavVisibility(bool visible) {
    if (visible != _isBottomNavVisible && !_isKeyboardVisible) {
      setState(() {
        _isBottomNavVisible = visible;
      });

      if (visible) {
        _hideAnimationController.reverse();
      } else {
        _hideAnimationController.forward();
      }
    }
  }
}