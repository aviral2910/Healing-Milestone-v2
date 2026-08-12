import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/posts/presentation/screens/recommended_swipe_screen.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';

import '../../../../features/posts/presentation/screens/post_screen.dart';
import '../../../../features/search/presentation/screens/search_screen.dart';
import '../../../../features/awareness/presentation/screens/health_awareness_screen.dart';
import '../../../../features/support_chat/presentation/screens/messages_screen.dart';
import '../../../../features/auth/data/auth_provider.dart';
import '../../../../features/support_chat/presentation/providers/chat_providers.dart';
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
  final ScrollController _recommendedScrollController = ScrollController();
  final ScrollController _messagesScrollController = ScrollController();
  final ScrollController _searchScrollController = ScrollController();
  final ScrollController _awarenessScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
    _recommendedScrollController.dispose();
    _messagesScrollController.dispose();
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
      } else if (index == 1 && _recommendedScrollController.hasClients) {
        _recommendedScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (index == 2 && _messagesScrollController.hasClients) {
        _messagesScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (index == 3 && _searchScrollController.hasClients) {
        _searchScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (index == 4 && _awarenessScrollController.hasClients) {
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
    final authState = ref.watch(authProvider).value;
    final isAuthenticated = authState?.status == AuthStatus.authenticated;

    int unreadCount = 0;
    if (isAuthenticated) {
      final chatIdAsync = ref.watch(supportChatIdProvider);
      final chatId = chatIdAsync.value;
      if (chatId != null) {
        final chatAsync = ref.watch(supportChatStreamProvider(chatId));
        if (chatAsync.value != null) {
          final currentUser = ref.watch(currentUserProvider);
          if (currentUser != null) {
            unreadCount = chatAsync.value!.unreadCount[currentUser.userId] ?? 0;
          }
        }
      }
    }

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          _onBottomNavTapped(0);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: false, // Solid background
        body: IndexedStack(
          index: _currentIndex,
          children: [
            PostScreen(
              scrollController: _postsScrollController,
              isActiveTab: _currentIndex == 0,
              onSearchTapped: () => _onBottomNavTapped(3),
            ),
            RecommendedSwipeScreen(
              scrollController: _recommendedScrollController,
              isActiveTab: _currentIndex == 1,
              onSearchTapped: () => _onBottomNavTapped(3),
            ),
            MessagesScreen(
              scrollController: _messagesScrollController,
              isActiveTab: _currentIndex == 2,
            ),
            SearchScreen(
              scrollController: _searchScrollController,
              isActiveTab: _currentIndex == 3,
            ),
            HealthAwarenessScreen(
              scrollController: _awarenessScrollController,
              isActiveTab: _currentIndex == 4,
              onSearchTapped: () => _onBottomNavTapped(3),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).scaffoldBackgroundColor, // dynamic background
            border: Border(
              top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5), // Very thin border
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
                    icon: Icons.auto_awesome_outlined,
                    activeIcon: Icons.auto_awesome,
                    index: 1,
                    theme: theme,
                  ),
                  _buildNavItem(
                    icon: Icons.send_outlined,
                    activeIcon: Icons.send,
                    index: 2,
                    theme: theme,
                    unreadCount: unreadCount,
                    angle: -0.5, // Tilts the paper plane upwards
                  ),
                  _buildNavItem(
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search,
                    index: 3,
                    theme: theme,
                  ),
                  _buildNavItem(
                    icon: Icons.health_and_safety_outlined,
                    activeIcon: Icons.health_and_safety,
                    index: 4,
                    theme: theme,
                  ),
                ],
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
    int unreadCount = 0,
    double angle = 0.0,
  }) {
    final isSelected = _currentIndex == index;
    Widget iconWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Transform.rotate(
        angle: angle,
        child: Icon(
          isSelected ? activeIcon : icon,
          key: ValueKey<bool>(isSelected),
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
    );

    if (unreadCount > 0) {
      iconWidget = Badge(
        isLabelVisible: true,
        label: Text(unreadCount > 9 ? '9+' : unreadCount.toString()),
        child: iconWidget,
      );
    }

    return GestureDetector(
      onTap: () => _onBottomNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70, // Slightly reduced to fit 5 items comfortably
        alignment: Alignment.center,
        child: iconWidget,
      ),
    );
  }
}
