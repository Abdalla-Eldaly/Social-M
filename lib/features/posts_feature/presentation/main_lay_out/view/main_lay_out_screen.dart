import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/config/router/app_router.dart';
import '../../../../../core/utils/theme/app_color.dart';
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
  late AnimationController _fabAnimationController;
  late AnimationController _bottomBarAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _bottomBarSlideAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _bottomBarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bottomBarAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _bottomBarAnimationController.forward();
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _bottomBarAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainLayoutViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBody: true,
      body: Stack(
        children: [
          AutoTabsScaffold(
            homeIndex: 0,
            inheritNavigatorObservers: true,
            lazyLoad: true,
            routes: const [
              HomeRoute(),
              CreatePostRoute(),
              StoryRoute(),
              ProfileRoute(),
            ],
            bottomNavigationBuilder: (context, tabsRouter) {
              return SlideTransition(
                position: _bottomBarSlideAnimation,
                child: _buildEnhancedBottomNavBar(context, viewModel, tabsRouter),
              );
            },
          ),

        ],
      ),
    );
  }
  Widget _buildEnhancedBottomNavBar(
      BuildContext context,
      MainLayoutViewModel viewModel,
      TabsRouter tabsRouter,
      ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
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
                  onTap: () => _onTabTapped(0, viewModel, tabsRouter),
                ),
                _buildTabItem(
                  context: context,
                  index: 1,
                  currentIndex: viewModel.currentIndex,
                  icon: CupertinoIcons.plus_square,
                  selectedIcon: CupertinoIcons.plus_square_fill,
                  label: 'Create',
                  onTap: () => _onTabTapped(1, viewModel, tabsRouter),
                ),
                _buildTabItem(
                  context: context,
                  index: 2,
                  currentIndex: viewModel.currentIndex,
                  icon: CupertinoIcons.play_circle,
                  selectedIcon: CupertinoIcons.play_circle_fill,
                  label: 'Stories',
                  onTap: () => _onTabTapped(2, viewModel, tabsRouter),
                ),
                _buildTabItem(
                  context: context,
                  index: 3,
                  currentIndex: viewModel.currentIndex,
                  icon: CupertinoIcons.person,
                  selectedIcon: CupertinoIcons.person_fill,
                  label: 'Profile',
                  onTap: () => _onTabTapped(3, viewModel, tabsRouter),
                ),
              ],
            ),
          ),
        ),
      ),
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

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced vertical padding
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
                    width: 36, // Reduced size
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
                    key: ValueKey(isSelected),
                    size: isSelected ? 22 : 20, // Reduced icon size
                    color: isSelected ? tabColors['primary'] : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2), // Reduced spacing
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 10 : 9, // Reduced font size
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

  void _onTabTapped(int index, MainLayoutViewModel viewModel, TabsRouter tabsRouter) {
    // Add custom transition animations or special handling
    if (index == viewModel.currentIndex) {
      // Double tap to scroll to top or refresh
      _handleDoubleTap(index);
    } else {
      viewModel.setTabIndex(index);
      tabsRouter.setActiveIndex(index);
    }
  }

  void _handleDoubleTap(int index) {
    // Handle double tap actions like scroll to top
    switch (index) {
      case 0:
      // Scroll home feed to top
        break;
      case 2:
      // Refresh stories
        break;
      case 3:
      // Scroll profile to top
        break;
    }
  }
}

// Alternative Enhanced Bottom Navigation with Custom Painter
class EnhancedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const EnhancedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<EnhancedBottomNavBar> createState() => _EnhancedBottomNavBarState();
}

class _EnhancedBottomNavBarState extends State<EnhancedBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
            height: 75,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Selection indicator background
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  left: _getIndicatorPosition(),
                  top: 8,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getSelectedGradient(),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Tab items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAdvancedTabItem(
                      index: 0,
                      icon: CupertinoIcons.house,
                      selectedIcon: CupertinoIcons.house_fill,
                      label: 'Home',
                    ),
                    _buildAdvancedTabItem(
                      index: 1,
                      icon: CupertinoIcons.plus_circle,
                      selectedIcon: CupertinoIcons.plus_circle_fill,
                      label: 'Create',
                    ),
                    _buildAdvancedTabItem(
                      index: 2,
                      icon: CupertinoIcons.play_circle,
                      selectedIcon: CupertinoIcons.play_circle_fill,
                      label: 'Stories',
                    ),
                    _buildAdvancedTabItem(
                      index: 3,
                      icon: CupertinoIcons.person,
                      selectedIcon: CupertinoIcons.person_fill,
                      label: 'Profile',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedTabItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap(index);
        _animationController.reset();
        _animationController.forward();
      },
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey('$index-$isSelected'),
                size: isSelected ? 28 : 24,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 9 : 8,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  double _getIndicatorPosition() {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = (screenWidth - 80) / 4; // Account for margins and spacing
    return 20 + (tabWidth * widget.currentIndex) + (tabWidth - 60) / 2;
  }

  List<Color> _getSelectedGradient() {
    switch (widget.currentIndex) {
      case 0:
        return [Colors.blue.shade400, Colors.blue.shade600];
      case 1:
        return [Colors.purple.shade400, Colors.purple.shade600];
      case 2:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case 3:
        return [Colors.green.shade400, Colors.green.shade600];
      default:
        return [Colors.blue.shade400, Colors.blue.shade600];
    }
  }
}

// Notification Badge Widget for future use
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? badgeColor;

  const NotificationBadge({
    super.key,
    required this.child,
    this.count = 0,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.red.shade500,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Custom Tab Transition Effects
class CustomTabTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const CustomTabTransition({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}