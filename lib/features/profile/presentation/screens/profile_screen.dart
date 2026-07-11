import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../core/models/story_model.dart';
import '../../../../shared/widgets/story_card.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(dummyUserProvider);
    final allStories = ref.watch(dummyStoriesProvider);
    final theme = Theme.of(context);

    // Map story IDs to actual StoryModels
    final ownStories = user.ownStories
        .map((id) => allStories.firstWhere((s) => s.storyId == id,
            orElse: () => allStories.first))
        .toList();

    final likedStories = user.likedStories
        .map((id) => allStories.firstWhere((s) => s.storyId == id,
            orElse: () => allStories.first))
        .toList();

    final bookmarkedStories = user.bookmarkedStories
        .map((id) => allStories.firstWhere((s) => s.storyId == id,
            orElse: () => allStories.first))
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {},
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
                            Container(
                              padding: const EdgeInsets.all(3),
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
                                backgroundColor: theme.scaffoldBackgroundColor,
                                backgroundImage: NetworkImage(
                                    'https://api.dicebear.com/7.x/avataaars/png?seed=${user.userId}'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user.userName,
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
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textTheme.bodySmall?.color),
                            ),
                            if (user.phoneNumber?.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Text(
                                user.phoneNumber!,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodySmall?.color),
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
                          onPressed: () {},
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
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: -16, vertical: 8),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: const Color(0xFFA1A1A6),
                    dividerColor:
                        Colors.transparent, // Remove the ugly default line
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_mosaic_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Stories',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Liked',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Saved',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _StoryList(stories: ownStories),
              _StoryList(stories: likedStories),
              _StoryList(stories: bookmarkedStories),
            ],
          ),
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

    return ListView.builder(
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
                onTap: () => context.push('/story/${story.storyId}'),
                content: story.shortDescription,
              ),
            ),
            if (index < stories.length - 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Divider(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    thickness: 1),
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
