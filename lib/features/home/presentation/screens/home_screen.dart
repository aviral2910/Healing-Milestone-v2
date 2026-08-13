import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/home/presentation/screens/inspire_screen.dart';
import 'package:healing_milestones/features/journey/presentation/screens/my_path_screen.dart';
import 'package:healing_milestones/features/journey/presentation/screens/together_feed_screen.dart';

import '../../../../features/search/presentation/screens/search_screen.dart';
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

  final ScrollController _timelineScrollController = ScrollController();
  final ScrollController _forYouScrollController = ScrollController();
  final ScrollController _awarenessScrollController = ScrollController();
  final ScrollController _messagesScrollController = ScrollController();

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
    _timelineScrollController.dispose();
    _forYouScrollController.dispose();
    _awarenessScrollController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentIndex) {
      // Scroll to top if already on the active tab (basic implementation for Inspire and Connect)
      if (index == 0) {
        // Can't easily know which top tab is active from here without more state,
        // so we scroll Timeline as default fallback, or maybe we shouldn't worry for now.
        if (_timelineScrollController.hasClients) {
          _timelineScrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else if (index == 3 && _messagesScrollController.hasClients) {
        _messagesScrollController.animateTo(
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
        extendBody: false,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            InspireScreen(
              timelineScrollController: _timelineScrollController,
              forYouScrollController: _forYouScrollController,
              awarenessScrollController: _awarenessScrollController,
              isActiveTab: _currentIndex == 0,
              onSearchTapped: () {
                // Navigate to search screen
                context.push(
                  '/search',
                ); // Ensure you have a top-level route or manage it otherwise
              },
            ),
            // Tab 2: Together (Journeys)
            const TogetherFeedScreen(),
            // Tab 3: My Path (Gratitude Tree & Milestones)
            const MyPathScreen(),
            // Tab 4: Connect (Messages)
            MessagesScreen(
              scrollController: _messagesScrollController,
              isActiveTab: _currentIndex == 3,
            ),
            // Placeholder for Tab 5: Vault (Profile)
            const Center(child: Text("Vault coming soon")),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    index: 0,
                    theme: theme,
                  ),
                  _buildNavItem(
                    icon: Icons.timeline,
                    activeIcon: Icons.timeline_rounded,
                    index: 1,
                    theme: theme,
                  ),
                  _buildNavItem(
                    icon: Icons.eco_outlined,
                    activeIcon: Icons.eco_rounded,
                    index: 2,
                    theme: theme,
                  ),
                  _buildNavItem(
                    icon: Icons.forum_outlined,
                    activeIcon: Icons.forum_rounded,
                    index: 3,
                    theme: theme,
                    unreadCount: unreadCount,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
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
  }) {
    final isSelected = _currentIndex == index;
    Widget iconWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Icon(
        isSelected ? activeIcon : icon,
        key: ValueKey<bool>(isSelected),
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
        size: 28,
        shadows: isSelected
            ? [
                Shadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  blurRadius: 12.0,
                ),
              ]
            : null,
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
        width: 70,
        alignment: Alignment.center,
        child: iconWidget,
      ),
    );
  }
}
