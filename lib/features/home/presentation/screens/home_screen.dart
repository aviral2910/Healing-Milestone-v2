import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../features/posts/presentation/screens/post_screen.dart';
import '../../../../features/search/presentation/screens/search_screen.dart';
import '../../../../features/awareness/presentation/screens/health_awareness_screen.dart';
import '../../../../main.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final ScrollController _postsScrollController = ScrollController();
  final ScrollController _searchScrollController = ScrollController();
  final ScrollController _awarenessScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postsScrollController.dispose();
    _searchScrollController.dispose();
    _awarenessScrollController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentIndex) {
      // Scroll to top if already on the active tab
      if (index == 0 && _postsScrollController.hasClients) {
        _postsScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (index == 1 && _searchScrollController.hasClients) {
        _searchScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (index == 2 && _awarenessScrollController.hasClients) {
        _awarenessScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
      _tabController.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          _onBottomNavTapped(0);
        }
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: false, // Solid background
          body: IndexedStack(
            index: _currentIndex,
            children: [
              PostScreen(
                scrollController: _postsScrollController,
                isActiveTab: _currentIndex == 0,
                onSearchTapped: () => _onBottomNavTapped(1),
              ),
              SearchScreen(
                scrollController: _searchScrollController,
                isActiveTab: _currentIndex == 1,
              ),
              HealthAwarenessScreen(
                scrollController: _awarenessScrollController,
                isActiveTab: _currentIndex == 2,
                onSearchTapped: () => _onBottomNavTapped(1),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0A0A0A), // Solid dark background
              border: Border(
                top: BorderSide(
                    color: Color(0xFF2A2A2A), width: 0.5), // Very thin border
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.feed_outlined,
                      activeIcon: Icons.feed,
                      index: 0,
                      theme: theme,
                    ),
                    _buildNavItem(
                      icon: Icons.search_outlined,
                      activeIcon: Icons.search,
                      index: 1,
                      theme: theme,
                    ),
                    _buildNavItem(
                      icon: Icons.health_and_safety_outlined,
                      activeIcon: Icons.health_and_safety,
                      index: 2,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required ThemeData theme,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 80,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Icon(
            isSelected ? activeIcon : icon,
            key: ValueKey<bool>(isSelected),
            color: isSelected
                ? theme.colorScheme.primary
                : const Color(0xFF5A5A5C),
            size: 28,
            shadows: isSelected
                ? [
                    Shadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                      blurRadius: 16.0,
                    )
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
