import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/guest_auth_wall.dart';

import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/home/presentation/screens/inspire_screen.dart';
import 'package:healing_milestones/features/journey/presentation/screens/my_path_screen.dart';
import 'package:healing_milestones/features/journey/presentation/screens/together_feed_screen.dart';
import 'package:healing_milestones/features/profile/presentation/screens/profile_screen.dart';

import '../../../../features/support_chat/presentation/screens/messages_screen.dart';
import '../../../../features/auth/data/auth_provider.dart';
import '../../../../features/support_chat/presentation/providers/chat_providers.dart';
import '../providers/home_tab_provider.dart';
import '../../../../core/widgets/lazy_indexed_stack.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ScrollController _timelineScrollController = ScrollController();
  final ScrollController _forYouScrollController = ScrollController();
  final ScrollController _awarenessScrollController = ScrollController();
  final ScrollController _messagesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      final currentTab = ref.read(homeTabProvider);
      if (_tabController.index != currentTab) {
        ref.read(homeTabProvider.notifier).state = _tabController.index;
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
    final currentTab = ref.read(homeTabProvider);
    if (index == currentTab) {
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
      ref.read(homeTabProvider.notifier).state = index;
      _tabController.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider).value;
    final isAuthenticated = authState?.status == AuthStatus.authenticated;
    final currentIndex = ref.watch(homeTabProvider);
    
    // Sync tab controller if the provider changes from outside
    if (_tabController.index != currentIndex) {
      _tabController.animateTo(currentIndex);
    }

    // unreadCount logic moved to Consumer

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          _onBottomNavTapped(0);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: false,
        body: LazyIndexedStack(
          index: currentIndex,
          children: [
            InspireScreen(
              timelineScrollController: _timelineScrollController,
              forYouScrollController: _forYouScrollController,
              awarenessScrollController: _awarenessScrollController,
              isActiveTab: currentIndex == 0,
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
            isAuthenticated 
                ? const MyPathScreen()
                : const GuestAuthWallWidget(
                    title: 'Track Your Healing',
                    subtitle: 'Create an account to start your personal journey and grow your gratitude tree.',
                  ),
            // Tab 4: Connect (Messages)
            isAuthenticated 
                ? MessagesScreen(
                    scrollController: _messagesScrollController,
                    isActiveTab: currentIndex == 3,
                  )
                : const GuestAuthWallWidget(
                    title: 'Join the Conversation',
                    subtitle: 'Create an account to securely message doctors and connect with patients.',
                  ),
            // Tab 5: Vault (Profile)
            isAuthenticated 
                ? const ProfileScreen()
                : const GuestAuthWallWidget(
                    title: 'Your Profile',
                    subtitle: 'Create an account to save stories, track milestones, and manage your preferences.',
                  ),
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
                  Consumer(builder: (context, ref, child) {

                    int unreadCount = 0;

                    if (isAuthenticated) {

                      final chatStatusAsync = ref.watch(supportChatStatusProvider);

                      final chatId = chatStatusAsync.value;

                      if (chatId != null && chatId.isNotEmpty) {

                        final chatAsync = ref.watch(supportChatStreamProvider(chatId));

                        if (chatAsync.value != null) {

                          final currentUser = ref.read(currentUserProvider);

                          if (currentUser != null) {

                            unreadCount = chatAsync.value!.unreadCount[currentUser.userId] ?? 0;

                          }

                        }

                      }

                    }

                    return _buildNavItem(

                      icon: Icons.forum_outlined,

                      activeIcon: Icons.forum_rounded,

                      index: 3,

                      theme: theme,

                      unreadCount: unreadCount,

                    );

                  }),
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
    final isSelected = ref.read(homeTabProvider) == index;
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
