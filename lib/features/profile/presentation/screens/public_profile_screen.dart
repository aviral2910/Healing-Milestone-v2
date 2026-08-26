import 'package:cached_network_image/cached_network_image.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/chat/presentation/providers/chat_providers.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
import '../../../../core/models/story_model.dart';
import '../../../../core/presentation/widgets/user_badge.dart';
import '../../../../shared/widgets/story_card.dart';
import '../../../../shared/widgets/qr_share_preview.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';
import '../../../../features/journey/presentation/widgets/public_journey_carousel.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const PublicProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userByIdProvider(widget.userId));

    return Scaffold(
      body: userAsync.when(
        loading: () => Center(child: const AppLoader.small()),
        error: (err, stack) => const Center(
          child: Text(
            'Failed to load user profile.',
            style: TextStyle(color: Colors.red),
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found.'));
          }

          return SafeArea(
            top: true,
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    // title: Text(
                    //   user.displayName,
                    //   style: const TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    centerTitle: true,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          showProfileShareOptions(context, user.userId);
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Centered Profile Header
                          Center(
                            child: Column(
                              children: [
                                Hero(
                                  tag: 'profile-avatar-${user.userId}',
                                  child: AppAvatar(
                                    imageUrl: user.profilePicture,
                                    radius: 50,
                                    role: user.role,
                                    showRing: true,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      user.displayName,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    UserBadge(
                                      role: user.role,
                                      isVerified: user.isVerified,
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                                if (user.username != null &&
                                    user.username!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '@${user.username}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                                if (user.specialty != null &&
                                    user.specialty!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF00B4D8,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF00B4D8,
                                        ).withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      user.specialty!.toUpperCase(),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: const Color(0xFF00B4D8),
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.0,
                                          ),
                                    ),
                                  ),
                                ],
                                if (user.bio != null &&
                                    user.bio!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    user.bio!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.4,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Stats Row
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: theme.dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatColumn(
                                  label: 'Stories',
                                  count: user.ownStories.length.toString(),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: theme.dividerColor,
                                ),
                                _StatColumn(
                                  label: 'Followers',
                                  count: _formatCount(user.followersCount),
                                  onTap: () {
                                    context.push(
                                      AppRoutes.userList,
                                      extra: {
                                        'title': 'Followers',
                                        'targetUserId': user.userId,
                                        'listType': 'followers',
                                      },
                                    );
                                  },
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: theme.dividerColor,
                                ),
                                _StatColumn(
                                  label: 'Following',
                                  count: _formatCount(user.followingCount),
                                  onTap: () {
                                    context.push(
                                      AppRoutes.userList,
                                      extra: {
                                        'title': 'Following',
                                        'targetUserId': user.userId,
                                        'listType': 'following',
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Action Buttons
                          Consumer(
                            builder: (context, ref, child) {
                              final currentUser = ref.watch(
                                currentUserProvider,
                              );
                              final isFollowing =
                                  ref
                                      .watch(isFollowingProvider(user.userId))
                                      .value ??
                                  false;

                              return Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (currentUser == null) {
                                          context.push(AppRoutes.login);
                                        } else {
                                          await ref
                                              .read(authProvider.notifier)
                                              .toggleFollow(user.userId);
                                          ref.invalidate(
                                            isFollowingProvider(user.userId),
                                          );
    
                                          // Await the refresh to prevent UI flickering
                                          await ref.refresh(
                                            userStreamProvider(
                                              currentUser.userId,
                                            ).future,
                                          );
                                          ref.invalidate(
                                            userByIdProvider(user.userId),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isFollowing
                                            ? theme.dividerColor
                                            : theme.colorScheme.primary,
                                        foregroundColor: isFollowing
                                            ? theme.textTheme.bodyMedium?.color
                                            : (theme.colorScheme.primary
                                                          .computeLuminance() >
                                                      0.25
                                                  ? Colors.black
                                                  : Colors.white),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child: Text(
                                        isFollowing ? 'Following' : 'Follow',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (currentUser == null) {
                                          context.push(AppRoutes.login);
                                          return;
                                        }
                                        try {
                                          // Request chat permission from FastAPI
                                          await ref.read(chatRepositoryProvider).requestChat(user.userId);
                                          // In a real app we'd get the roomId back and navigate. 
                                          // For now, let's just show a snackbar or navigate to inbox.
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Chat request sent! Check your inbox.')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Could not start chat: $e')),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primaryContainer,
                                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child: const Text(
                                        'Message',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: PublicJourneyCarousel(userId: user.userId, userName: user.displayName),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        indicatorPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.unselectedWidgetColor,
                        dividerColor:
                            Colors.transparent, // Remove the ugly default line
                        tabs: const [
                          Tab(
                            icon: Icon(
                              Icons.auto_awesome_mosaic_rounded,
                              size: 24,
                            ),
                          ),
                          Tab(icon: Icon(Icons.person_pin_rounded, size: 24)),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Stories Tab
                  Consumer(
                    builder: (context, ref, child) {
                      final userStoriesAsync = ref.watch(
                        userStoriesProvider(widget.userId),
                      );
                      return userStoriesAsync.when(
                        loading: () => Center(child: const AppLoader.small()),
                        error: (err, stack) => const Center(
                          child: Text(
                            'Failed to load stories',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        data: (stories) => _StoryList(stories: stories),
                      );
                    },
                  ),
                  // Tagged Tab
                  Consumer(
                    builder: (context, ref, child) {
                      final taggedStoriesAsync = ref.watch(
                        userTaggedStoriesProvider(widget.userId),
                      );
                      return taggedStoriesAsync.when(
                        loading: () => Center(child: const AppLoader.small()),
                        error: (err, stack) => const Center(
                          child: Text(
                            'Failed to load tagged stories',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        data: (stories) => _StoryList(stories: stories),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StoryList extends StatelessWidget {
  final List<StoryModel> stories;

  const _StoryList({Key? key, required this.stories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          child: Text(
            'No stories found.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        final theme = Theme.of(context);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: StoryCard(
                story: story,
                onTap: () => context.push(AppRoutes.storyDetail(story.storyId)),
                content: story.shortDescription,
              ),
            ),
            if (index < stories.length - 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Divider(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  thickness: 1,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String count;
  final VoidCallback? onTap;

  const _StatColumn({
    Key? key,
    required this.label,
    required this.count,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            count,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
