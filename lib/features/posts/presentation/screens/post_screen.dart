import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/category_model.dart';
import '../../../../core/presentation/widgets/user_badge.dart';
import '../../../../core/presentation/widgets/verified_story_badge.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../core/models/story_model.dart';
import '../../../../logo/healing_milestone_logo.dart';
import '../../../../main.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../shared/widgets/story_card.dart';

class PostScreen extends ConsumerWidget {
  const PostScreen({Key? key}) : super(key: key);

  String _truncateContent(String text, int length) {
    if (text.length <= length) return text;
    int end = text.lastIndexOf(' ', length);
    if (end == -1) end = length;
    return '${text.substring(0, end)}...';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStories = ref.watch(dummyStoriesProvider);
    final categories = ref.watch(dummyCategoriesProvider);
    final theme = Theme.of(context);

    return AnimationLimiter(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            centerTitle: false,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: HealingMilestonesLogoWidget(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    ref.read(uatModeProvider.notifier).state = !ref.read(uatModeProvider);
                  },
                  child: const Text('UAT'),
                ),
              ),
            ],
          ),
          // Horizontal Categories
          ...categories.map((category) {
            final categoryStories = allStories
                .where((s) => category.storiesList.contains(s.storyId))
                .toList();
            
            return SliverToBoxAdapter(
              child: _HorizontalCategorySection(
                title: category.categoryName,
                stories: categoryStories,
                truncateContent: _truncateContent,
              ),
            );
          }).toList(),

          // Divider for the main feed
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, top: 64.0, bottom: 24.0),
              child: Text(
                'All Stories',
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
              ),
            ),
          ),

          // Infinite Vertical Scrolling Feed
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final story = allStories[index];
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
                                    context.push('/story/${story.storyId}'),
                                content: _truncateContent(story.description, 150),
                              ),
                            ),
                            if (index < allStories.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Divider(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2), 
                                  thickness: 1
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: allStories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
    );
  }
}

class _HorizontalCategorySection extends StatelessWidget {
  final String title;
  final List<StoryModel> stories;
  final String Function(String, int) truncateContent;

  const _HorizontalCategorySection({
    Key? key,
    required this.title,
    required this.stories,
    required this.truncateContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (stories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 56.0, bottom: 24.0),
          child: Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
          ),
        ),
        SizedBox(
          height:
              440, // Height accommodates 180px image + title + description + hashtags
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 340, // Increased width for horizontal cards
                          child: _HorizontalFeedCard(
                            story: story,
                            onTap: () =>
                                context.push('/story/${story.storyId}'),
                            content: truncateContent(story.description, 100),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizontalFeedCard extends StatefulWidget {
  final StoryModel story;
  final VoidCallback onTap;
  final String content;

  const _HorizontalFeedCard({
    Key? key,
    required this.story,
    required this.onTap,
    required this.content,
  }) : super(key: key);

  @override
  State<_HorizontalFeedCard> createState() => _HorizontalFeedCardState();
}

class _HorizontalFeedCardState extends State<_HorizontalFeedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(
                0xFF151515), // Slightly lighter than pure black for depth
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E1E), Color(0xFF0F0F0F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Header (Top of the card)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  widget.story.mainImage,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),

              // Author Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      backgroundImage: NetworkImage(
                          'https://api.dicebear.com/7.x/avataaars/png?seed=${widget.story.authorId}'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              !widget.story.displayAuthorName
                                  ? 'Anonymous'
                                  : 'Author ${widget.story.authorId}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 13,
                                color: const Color(0xFFA1A1A6), // Titanium
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          UserBadge(
                            role: widget.story.authorRole,
                            isVerified: widget.story.isAuthorVerified,
                            iconSize: 14,
                          ),
                        ],
                      ),
                    ),
                    if (widget.story.isVerifiedStory)
                      const VerifiedStoryBadge(),
                  ],
                ),
              ),

              // Title Header
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.story.heading.isNotEmpty
                            ? widget.story.heading
                            : 'A Healing Journey',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 20,
                          color: const Color(0xFFF5F5F7), // Frost white
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: const Color(0xFFA1A1A6), // Titanium
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Read more',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.story.hashtagsList.isNotEmpty) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: widget.story.hashtagsList.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Interaction Footer
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    InteractionButton(
                        icon: Icons.favorite_border,
                        label: '2.4k',
                        color: theme.colorScheme.primary), // Golden
                    const SizedBox(width: 16),
                    InteractionButton(
                        icon: Icons.chat_bubble_outline,
                        label: '142',
                        color: const Color(0xFFA1A1A6)),
                    const Spacer(),
                    const Icon(Icons.bookmark_border,
                        color: Color(0xFFA1A1A6), size: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// The original massive vertical StoryCard remains unchanged below
// -------------------------------------------------------------

