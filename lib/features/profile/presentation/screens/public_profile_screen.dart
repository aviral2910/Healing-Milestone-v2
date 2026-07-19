import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/story_model.dart';
import '../../../../shared/widgets/story_card.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String userId;

  const PublicProfileScreen({Key? key, required this.userId}) : super(key: key);

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userByIdProvider(userId));
    final userStoriesAsync = ref.watch(userStoriesProvider(userId));

    return Scaffold(
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        error: (err, stack) => const Center(child: Text('Failed to load user profile.', style: TextStyle(color: Colors.red))),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found.'));
          }
          
          return DefaultTabController(
            length: 1, // Only show stories for now on public profiles
            child: SafeArea(
              top: true,
              bottom: false,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      title: Text(
                        user.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      centerTitle: true,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      elevation: 0,
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
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary,
                                            Colors.amber
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
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
                                      if (user.isVerified) ...[
                                        const SizedBox(width: 4),
                                        Icon(Icons.verified,
                                            color: theme.colorScheme.primary,
                                            size: 20),
                                      ],
                                    ],
                                  ),
                                  if (user.username != null && user.username!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '@${user.username}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary),
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
                                color: const Color(0xFF151515),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF2A2A2A)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
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
                                      color: const Color(0xFF2A2A2A)),
                                  _StatColumn(
                                      label: 'Followers',
                                      count: _formatCount(user.followersCount)),
                                  Container(
                                      width: 1,
                                      height: 40,
                                      color: const Color(0xFF2A2A2A)),
                                  _StatColumn(
                                      label: 'Following',
                                      count: _formatCount(user.followingCount)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Action Buttons
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement Follow Logic
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  'Follow',
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
                          indicator: BoxDecoration(
                            color:
                                theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          indicatorPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor: const Color(0xFFA1A1A6),
                          dividerColor:
                              Colors.transparent, // Remove the ugly default line
                          tabs: const [
                            Tab(
                              icon:
                                  Icon(Icons.auto_awesome_mosaic_rounded, size: 24),
                              text: "Stories",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: userStoriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
                  error: (err, stack) => const Center(child: Text('Failed to load stories', style: TextStyle(color: Colors.red))),
                  data: (stories) {
                    return TabBarView(
                      children: [
                        _StoryList(stories: stories),
                      ],
                    );
                  },
                ),
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
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
          ),
          child: const Text(
            'No stories found.',
            style: TextStyle(color: Color(0xFFA1A1A6)),
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
                        onTap: () => context.push('/story/${story.storyId}'),
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

  const _StatColumn({Key? key, required this.label, required this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          count,
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFFF5F5F7),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFFA1A1A6),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
