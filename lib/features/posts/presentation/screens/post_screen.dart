import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/shared/widgets/story_card.dart';
import '../../../../core/widgets/shared_headers.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
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
  }) : height = 56;

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
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
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
                                ? (theme.colorScheme.primary
                                            .computeLuminance() >
                                        0.25
                                    ? Colors.black
                                    : Colors.white)
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
          Divider(color: Theme.of(context).dividerColor, height: 1),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTagsDelegate oldDelegate) {
    return oldDelegate.tags != tags || oldDelegate.selectedTag != selectedTag;
  }
}

class PostScreen extends HookConsumerWidget {
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
    useAutomaticKeepAlive();
    final storiesAsync = ref.watch(paginatedStoriesProvider);
    final isPaginating =
        ref.watch(paginatedStoriesProvider.notifier).isLoadingMore;
    final hasMore = ref.watch(paginatedStoriesProvider.notifier).hasMore;

    final targetController =
        scrollController ?? PrimaryScrollController.maybeOf(context);

    useEffect(() {
      if (targetController == null) return null;

      void listener() {
        if (!targetController.hasClients) return;
        for (final position in targetController.positions) {
          if (position.pixels >= position.maxScrollExtent - 500) {
            if (!isPaginating && hasMore) {
              ref.read(paginatedStoriesProvider.notifier).fetchNextPage();
            }
            break;
          }
        }
      }

      targetController.addListener(listener);
      return () => targetController.removeListener(listener);
    }, [targetController, isPaginating, hasMore, ref]);

    final categories =
        []; // Replace with actual categories if needed, or keep empty
    final selectedTag = ref.watch(selectedTagProvider);
    // Removed user watch for performance
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        onRefresh: () async {
          await ref.read(paginatedStoriesProvider.notifier).refresh();
          // ignore: unused_result
          ref.refresh(recommendedStoriesProvider);
        },
        child: AnimationLimiter(
          child: CustomScrollView(
            key: const PageStorageKey<String>('timeline_scroll_key'),
            controller:
                scrollController, // If null, inherits PrimaryScrollController
            slivers: [
              Consumer(builder: (context, ref, child) {

                final user = ref.watch(currentUserProvider);

                return CommonSearchBarSliver(

                  includeWelcomeText: false,

                  displayName: user?.displayName ?? 'Guest',

                  hintText: 'Search stories, topics, people...',

                  onTap: onSearchTapped,

                );

              }),
              storiesAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFD4AF37))),
                ),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Theme.of(context).dividerColor),
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
                  // Extract top tags using all stories, memoized to prevent recomputation on tag select
                  final topTags = useMemoized(() {
                    final tagFrequency = <String, int>{};
                    for (var story in allStories) {
                      for (var tag in story.hashtagsList) {
                        tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
                      }
                    }

                    final sortedTags = tagFrequency.keys.toList()
                      ..sort(
                          (a, b) => tagFrequency[b]!.compareTo(tagFrequency[a]!));

                    return ['All', ...sortedTags.take(9)];
                  }, [allStories]);

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
                            Icon(Icons.auto_awesome_mosaic_outlined,
                                size: 64,
                                color: Theme.of(context).dividerColor),
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
                                color: const Color(0xFFA1A1A6)
                                    .withValues(alpha: 0.7),
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
                          pinned: false,
                          delegate: _SliverTagsDelegate(
                            tags: topTags,
                            selectedTag: selectedTag,
                            onTagSelected: (tag) => ref
                                .read(selectedTagProvider.notifier)
                                .state = tag,
                          ),
                        ),

                      if (filteredStories.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No stories found for #$selectedTag',
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(color: const Color(0xFFA1A1A6)),
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
                                        padding:
                                            const EdgeInsets.only(bottom: 32.0),
                                        child: StoryCard(
                                          story: story,
                                          content: _truncateContent(
                                              story.description, 180),
                                          onTap: () {
                                            context.push(AppRoutes.storyDetail(
                                                story.storyId));
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
                      if (isPaginating)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFD4AF37)),
                            ),
                          ),
                        ),
                      if (!hasMore && allStories.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: Text(
                                "You've reached the end!",
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100), // Bottom padding
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
