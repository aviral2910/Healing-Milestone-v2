import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/widgets/shared_headers.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/shared/widgets/swipe_story_card.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import '../../../../main.dart';

class PostSwipeScreen extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final bool isActiveTab;
  final VoidCallback onSearchTapped;

  const PostSwipeScreen({
    Key? key,
    required this.scrollController,
    required this.isActiveTab,
    required this.onSearchTapped,
  }) : super(key: key);

  @override
  ConsumerState<PostSwipeScreen> createState() => _PostSwipeScreenState();
}

class _PostSwipeScreenState extends ConsumerState<PostSwipeScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _truncateContent(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        onRefresh: () async {
          await ref.read(paginatedStoriesProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: widget.scrollController,
          slivers: [
            CommonSliverAppBar(isHeroEnabled: widget.isActiveTab),
            Consumer(
              builder: (context, ref, child) {
                final storiesAsync = ref.watch(paginatedStoriesProvider);
                final paginationState = ref.watch(paginatedStoriesProvider.notifier);
                final isPaginating = paginationState.isLoadingMore;
                final hasMore = paginationState.hasMore;
                final selectedTag = ref.watch(selectedTagProvider);
                final user = ref.watch(currentUserProvider);

                if (storiesAsync.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                    ),
                  );
                } else if (storiesAsync.hasError && !storiesAsync.hasValue) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).dividerColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to load',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFFA1A1A6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => ref
                                .read(paginatedStoriesProvider.notifier)
                                .refresh(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (storiesAsync.hasValue) {
                  return SliverMainAxisGroup(
                    slivers: _buildSuccessSlivers(
                      context,
                      ref,
                      storiesAsync.value!,
                      theme,
                      selectedTag,
                      isPaginating,
                      hasMore,
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSuccessSlivers(
    BuildContext context,
    WidgetRef ref,
    List<StoryModel?> allStories,
    ThemeData theme,
    String selectedTag,
    bool isPaginating,
    bool hasMore,
  ) {
    // Filter stories based on selected tag
    final filteredStories = selectedTag == 'All'
        ? allStories.where((s) => s != null).cast<StoryModel>().toList()
        : allStories
              .where((s) => s != null && s.hashtagsList.contains(selectedTag))
              .cast<StoryModel>()
              .toList();

    return [
      if (filteredStories.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No stories found for #$selectedTag',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFA1A1A6),
                ),
              ),
            ),
          ),
        )
      else
        SliverFillRemaining(
          hasScrollBody: true,
          child: Builder(
            builder: (context) {
              final pageViewWidth = MediaQuery.sizeOf(context).width;

              return PageView.builder(
                key: const PageStorageKey('swipe_page_view'),
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: filteredStories.length + (hasMore ? 1 : 0),
                onPageChanged: (index) {
                  if (index >= filteredStories.length - 2 &&
                      hasMore &&
                      !isPaginating) {
                    ref.read(paginatedStoriesProvider.notifier).fetchNextPage();
                  }
                },
                itemBuilder: (context, index) {
                  if (index >= filteredStories.length) {
                    final hasError = ref.read(paginatedStoriesProvider).hasError;
                    if (hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFA1A1A6)),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => ref.read(paginatedStoriesProvider.notifier).fetchNextPage(),
                              child: const Text('Tap to retry', style: TextStyle(color: Color(0xFFD4AF37))),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4AF37),
                      ),
                    );
                  }

                  final story = filteredStories[index];

                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 0.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                      }

                      double dx = 0.0;
                      double dy = 0.0;
                      double scale = 1.0;
                      double opacity = 1.0;
                      double rotation = 0.0;

                      if (value > 0) {
                        // Card sliding out to the left
                        // Native PageView moves it left. Let's just rotate it and fade it for a Tinder feel
                        dx = 0.0;
                        scale = 1.0;
                        dy = 0.0;
                        rotation = -value * 0.1;
                        opacity = (1 - value * 0.8).clamp(0.0, 1.0);
                      } else {
                        // Card sliding in from the right
                        // Parallax effect: moves slower than native
                        dx = value * pageViewWidth * 0.5;
                        scale = (1 + value * 0.1).clamp(0.9, 1.0);
                        dy = 0.0;
                        rotation = 0.0;
                        opacity = (1 + value).clamp(0.0, 1.0);
                      }

                      return Transform.translate(
                        offset: Offset(dx, dy),
                        child: Transform.scale(
                          scale: scale,
                          child: Transform.rotate(
                            angle: rotation,
                            child: Opacity(opacity: opacity, child: child),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 4.0,
                        right: 4.0,
                        top: 4.0,
                        bottom: 24.0,
                      ),
                      child: SwipeStoryCard(
                        story: story,
                        content: _truncateContent(story.description, 200),
                        onTap: () {
                          context.push(AppRoutes.storyDetail(story.storyId));
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
    ];
  }
}
