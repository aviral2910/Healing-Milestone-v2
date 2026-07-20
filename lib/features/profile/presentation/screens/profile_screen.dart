import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:healing_milestones/core/presentation/widgets/logout_button.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/story_model.dart';
import '../../../../shared/widgets/story_card.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../../core/presentation/widgets/user_badge.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final user = ref.watch(currentUserProvider);
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final bool isProOrOrg = user.role == UserRole.healthcareProfessional ||
        user.role == UserRole.organization;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                snap: true,
                title: const Text(
                  'Profile',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor:
                            theme.colorScheme.primary.computeLuminance() > 0.25
                                ? Colors.black
                                : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                      ),
                      onPressed: () {
                        context.push(AppRoutes.create);
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16),
                          SizedBox(width: 4),
                          Text('Create',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      context.push(AppRoutes.settings,
                          extra: MenuContext.profile);
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
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                      theme.scaffoldBackgroundColor,
                                  backgroundImage: NetworkImage(
                                    user.profilePicture ??
                                        'https://api.dicebear.com/7.x/avataaars/png?seed=${user.userId}',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user.displayName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
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
                                    color: theme.colorScheme.primary),
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
                              color: theme.shadowColor.withValues(alpha: 0.5),
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
                                count: user.ownStories.length.toString()),
                            Container(
                                width: 1,
                                height: 40,
                                color: Theme.of(context).dividerColor),
                            _StatColumn(
                                label: 'Followers',
                                count: _formatCount(user.followersCount),
                                onTap: () {
                                  context.push(AppRoutes.userList, extra: {
                                    'title': 'Followers',
                                    'userIds': user.followersList,
                                  });
                                }),
                            Container(
                                width: 1,
                                height: 40,
                                color: Theme.of(context).dividerColor),
                            _StatColumn(
                                label: 'Following',
                                count: _formatCount(user.followingCount),
                                onTap: () {
                                  context.push(AppRoutes.userList, extra: {
                                    'title': 'Following',
                                    'userIds': user.followingList,
                                  });
                                }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push(AppRoutes.editProfile);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            foregroundColor: theme.colorScheme.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    indicatorPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.unselectedWidgetColor,
                    dividerColor:
                        Colors.transparent, // Remove the ugly default line
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.auto_awesome_mosaic_rounded, size: 24),
                      ),
                      Tab(
                        icon: Icon(Icons.person_pin_rounded, size: 24),
                      ),
                      Tab(
                        icon: Icon(Icons.bookmark_rounded, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Own Stories
              Consumer(builder: (context, ref, child) {
                final userStoriesAsync =
                    ref.watch(userStoriesProvider(user.userId));
                return userStoriesAsync.when(
                  loading: () => Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor)),
                  error: (err, stack) => const Center(
                      child: Text('Failed to load stories',
                          style: TextStyle(color: Colors.red))),
                  data: (stories) => _StoryList(stories: stories),
                );
              }),
              // Tagged Stories
              Consumer(builder: (context, ref, child) {
                final taggedAsync =
                    ref.watch(userTaggedStoriesProvider(user.userId));
                return taggedAsync.when(
                  loading: () => Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor)),
                  error: (err, stack) => const Center(
                      child: Text('Failed to load tagged stories',
                          style: TextStyle(color: Colors.red))),
                  data: (stories) => _StoryList(stories: stories),
                );
              }),
              // Bookmarks
              Consumer(builder: (context, ref, child) {
                final bookmarkedAsync = ref
                    .watch(bookmarkedStoriesProvider(user.bookmarkedStories));
                return bookmarkedAsync.when(
                  loading: () => Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor)),
                  error: (err, stack) => const Center(
                      child: Text('Failed to load bookmarks',
                          style: TextStyle(color: Colors.red))),
                  data: (stories) => _StoryList(stories: stories),
                );
              }),
            ],
          ),
        ),
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
            style:
                TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          final theme = Theme.of(context);
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 100.0,
              child: FadeInAnimation(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: StoryCard(
                        story: story,
                        onTap: () =>
                            context.push(AppRoutes.storyDetail(story.storyId)),
                        content: story.shortDescription,
                      ),
                    ),
                    if (index < stories.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Divider(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.2),
                            thickness: 1),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String count;
  final VoidCallback? onTap;

  const _StatColumn(
      {Key? key, required this.label, required this.count, this.onTap})
      : super(key: key);

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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
