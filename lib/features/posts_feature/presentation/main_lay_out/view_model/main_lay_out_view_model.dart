import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MainLayoutViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isBottomNavVisible = true;
  bool _isKeyboardVisible = false;

  // Scroll state management
  final Map<int, double> _tabScrollOffsets = {};
  final Map<int, bool> _tabScrollStates = {};

  // Navigation history for better UX
  final List<int> _navigationHistory = [0];

  // Getters
  int get currentIndex => _currentIndex;
  bool get isBottomNavVisible => _isBottomNavVisible;
  bool get isKeyboardVisible => _isKeyboardVisible;
  List<int> get navigationHistory => List.unmodifiable(_navigationHistory);

  // Get scroll offset for specific tab
  double getTabScrollOffset(int index) => _tabScrollOffsets[index] ?? 0.0;

  // Get scroll state for specific tab
  bool getTabScrollState(int index) => _tabScrollStates[index] ?? false;

  // Set tab index with navigation history
  void setTabIndex(int index) {
    if (index == _currentIndex) return;

    final previousIndex = _currentIndex;
    _currentIndex = index;

    // Update navigation history
    _updateNavigationHistory(index);

    debugPrint('Tab changed from $previousIndex to $index');
    notifyListeners();
  }

  void _updateNavigationHistory(int index) {
    // Remove if already exists to avoid duplicates
    _navigationHistory.remove(index);
    // Add to end (most recent)
    _navigationHistory.add(index);

    // Keep only last 5 tabs for memory efficiency
    if (_navigationHistory.length > 5) {
      _navigationHistory.removeAt(0);
    }
  }

  // Get previous tab from history
  int? getPreviousTab() {
    if (_navigationHistory.length > 1) {
      return _navigationHistory[_navigationHistory.length - 2];
    }
    return null;
  }

  // Bottom navigation visibility control
  void setBottomNavVisibility(bool visible) {
    if (_isBottomNavVisible != visible) {
      _isBottomNavVisible = visible;
      debugPrint('Bottom nav visibility: $visible');
      notifyListeners();
    }
  }

  // Keyboard visibility control
  void setKeyboardVisibility(bool visible) {
    if (_isKeyboardVisible != visible) {
      _isKeyboardVisible = visible;

      // Auto-hide bottom nav when keyboard is visible
      if (visible) {
        setBottomNavVisibility(false);
      }

      debugPrint('Keyboard visibility: $visible');
      notifyListeners();
    }
  }

  // Update scroll offset for a specific tab
  void updateTabScrollOffset(int index, double offset) {
    _tabScrollOffsets[index] = offset;
    // Don't notify listeners for scroll offset changes to avoid rebuilds
  }

  // Update scroll state for a specific tab
  void updateTabScrollState(int index, bool isScrolling) {
    if (_tabScrollStates[index] != isScrolling) {
      _tabScrollStates[index] = isScrolling;
      debugPrint('Tab $index scroll state: $isScrolling');
      // Notify only if it affects UI behavior
      notifyListeners();
    }
  }

  // Handle scroll direction changes
  void handleScrollDirectionChange(int tabIndex, ScrollDirection direction) {
    // Only handle if it's the current tab
    if (tabIndex != _currentIndex) return;

    switch (direction) {
      case ScrollDirection.reverse:
      // Scrolling down - hide bottom nav
        if (_isBottomNavVisible && !_isKeyboardVisible) {
          setBottomNavVisibility(false);
        }
        break;
      case ScrollDirection.forward:
      // Scrolling up - show bottom nav
        if (!_isBottomNavVisible && !_isKeyboardVisible) {
          setBottomNavVisibility(true);
        }
        break;
      case ScrollDirection.idle:
      // No action needed
        break;
    }
  }

  // Handle when user reaches top of scroll
  void handleScrolledToTop(int tabIndex) {
    if (tabIndex == _currentIndex && !_isBottomNavVisible && !_isKeyboardVisible) {
      setBottomNavVisibility(true);
    }
  }

  // Reset scroll states (useful for logout/login)
  void resetScrollStates() {
    _tabScrollOffsets.clear();
    _tabScrollStates.clear();
    _isBottomNavVisible = true;
    _isKeyboardVisible = false;
    notifyListeners();
  }

  // Get readable tab name
  String getTabName(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Create';
      case 2:
        return 'Stories';
      case 3:
        return 'Profile';
      default:
        return 'Unknown';
    }
  }

  // Check if tab should preserve scroll position
  bool shouldPreserveScrollPosition(int index) {
    // Preserve scroll position for content tabs
    return index == 0 || index == 2 || index == 3;
  }

  // Handle back button behavior
  bool handleBackButton() {
    final previousTab = getPreviousTab();
    if (previousTab != null && previousTab != _currentIndex) {
      setTabIndex(previousTab);
      return true; // Handled
    }
    return false; // Not handled, exit app
  }

  @override
  void dispose() {
    debugPrint('MainLayoutViewModel disposed');
    super.dispose();
  }
}