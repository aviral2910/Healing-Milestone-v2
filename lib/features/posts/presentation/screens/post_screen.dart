import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/shared/widgets/story_card.dart';
import '../../../../core/models/category_model.dart';
import '../../../../core/presentation/widgets/user_badge.dart';
import '../../../../core/presentation/widgets/verified_story_badge.dart';
import '../../../../core/widgets/shared_headers.dart';
import '../../../../core/models/story_model.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
import '../../../../logo/healing_milestone_logo.dart';
import '../../../../main.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class _SliverTagsDelegate extends SliverPersistentHeaderDelegate {
  final List<String> tags;
  final String selectedTag;
  final ValueChanged<String> onTagSelected;
  final double height;

  _SliverTagsDelegate({
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
    this.height = 56,
  });

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor, // matches background
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                final isSelected = tag == selectedTag;
                final isAll = tag == 'All';
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => onTagSelected(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : const Color(0xFF2A2A2A),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isAll ? 'All' : '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? Colors.black
                                : const Color(0xFFA1A1A6),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTagsDelegate oldDelegate) {
    return oldDelegate.tags != tags || oldDelegate.selectedTag != selectedTag;
  }
}

class PostScreen extends ConsumerWidget {
  final ScrollController? scrollController;
  final bool isActiveTab;
  final VoidCallback? onSearchTapped;

  const PostScreen({
    Key? key,
    this.scrollController,
    this.isActiveTab = true,
    this.onSearchTapped,
  }) : super(key: key);

  String _truncateContent(String text, int length) {
    if (text.length <= length) return text;
    int end = text.lastIndexOf(' ', length);
    if (end == -1) end = length;
    return '${text.substring(0, end)}...';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesStreamProvider);
    final categories = []; // Replace with actual categories if needed, or keep empty
    final selectedTag = ref.watch(selectedTagProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return AnimationLimiter(
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          CommonSliverAppBar(isHeroEnabled: isActiveTab),
          CommonSearchBarSliver(
            includeWelcomeText: true,
            displayName: user?.displayName ?? 'Guest',
            hintText: 'Search stories, topics, people...',
            onTap: onSearchTapped,
          ),
          
          storiesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: const Color(0xFF2A2A2A)),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load stories',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFA1A1A6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (allStories) {
              // Extract top tags using all stories
              final tagFrequency = <String, int>{};
              for (var story in allStories) {
                for (var tag in story.hashtagsList) {
                  tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
                }
              }

              final sortedTags = tagFrequency.keys.toList()
                ..sort((a, b) => tagFrequency[b]!.compareTo(tagFrequency[a]!));

              final topTags = ['All', ...sortedTags.take(9)];

              // Filter stories based on selected tag
              final filteredStories = selectedTag == 'All'
                  ? allStories
                  : allStories
                      .where((s) => s.hashtagsList.contains(selectedTag))
                      .toList();

              if (allStories.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_mosaic_outlined, size: 64, color: const Color(0xFF2A2A2A)),
                        const SizedBox(height: 16),
                        Text(
                          'No stories yet',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFFA1A1A6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share a milestone.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFA1A1A6).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverMainAxisGroup(
                slivers: [
                  // Tags Header (Pinned)
                  if (topTags.length > 1)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTagsDelegate(
                        tags: topTags,
                        selectedTag: selectedTag,
                        onTagSelected: (tag) =>
                            ref.read(selectedTagProvider.notifier).state = tag,
                      ),
                    ),

                  // Divider for the main feed
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 32.0, bottom: 24.0),
                      child: Text(
                        'All Stories',
                        style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
                      ),
                    ),
                  ),

                  if (filteredStories.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'No stories found for #$selectedTag',
                            style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFFA1A1A6)),
                          ),
                        ),
                      ),
                    )
                  else
                    // Vertical Feed of Posts
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final story = filteredStories[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 24.0),
                                    child: StoryCard(
                                      story: story,
                                      content: _truncateContent(story.description, 180),
                                      onTap: () {
                                        context.push('/story/${story.storyId}');
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: filteredStories.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100), // bottom padding for scrolling
                  ),
                ],
              );
            },
          ),
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
    required this.title,
    required this.stories,
    required this.truncateContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 32.0, 20.0, 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              if (stories.length > 2)
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 450, // Height for the horizontal cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: 300,
                        child: _MiniStoryCard(
                          story: story,
                          content: truncateContent(story.description, 120),
                          onTap: () {
                            context.push('/story/${story.storyId}');
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniStoryCard extends ConsumerStatefulWidget {
  final StoryModel story;
  final String content;
  final VoidCallback onTap;

  const _MiniStoryCard({
    required this.story,
    required this.content,
    required this.onTap,
  });

  @override
  ConsumerState<_MiniStoryCard> createState() => __MiniStoryCardState();
}

class __MiniStoryCardState extends ConsumerState<_MiniStoryCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    final userAsync = ref.watch(userByIdProvider(widget.story.authorId));

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
                  height: 150, // Reduced from 180 to prevent overflow
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
                            child: userAsync.when(
                              data: (user) {
                                final displayName = user?.displayName;
                                final username = user?.username;
                                
                                String authorText = 'Author ${widget.story.authorId}';
                                if (!widget.story.displayAuthorName) {
                                  authorText = 'Anonymous';
                                } else if (displayName != null && displayName.isNotEmpty) {
                                  authorText = displayName;
                                } else if (username != null && username.isNotEmpty) {
                                  authorText = '@$username';
                                }

                                return Text(
                                  authorText,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xFFA1A1A6), // Titanium
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                              loading: () => Text(
                                !widget.story.displayAuthorName ? 'Anonymous' : 'Loading...',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 13,
                                  color: const Color(0xFFA1A1A6), // Titanium
                                ),
                              ),
                              error: (_, __) => Text(
                                !widget.story.displayAuthorName ? 'Anonymous' : 'Author',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 13,
                                  color: const Color(0xFFA1A1A6), // Titanium
                                ),
                              ),
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

              SizedBox(
                height: 8,
              ),

              // Title Header
              Padding(
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
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 8),
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
              Spacer(),
              if (widget.story.hashtagsList.isNotEmpty) ...[
                const SizedBox(height: 16),
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
                const SizedBox(height: 12), // Reduced from 24
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
