import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
import 'package:healing_milestones/core/models/paginated_response.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/shared/widgets/swipe_story_card.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import '../../../../main.dart';

class RecommendedSwipeScreen extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final bool isActiveTab;
  final VoidCallback onSearchTapped;

  const RecommendedSwipeScreen({
    Key? key,
    this.scrollController,
    required this.isActiveTab,
    required this.onSearchTapped,
  }) : super(key: key);

  @override
  ConsumerState<RecommendedSwipeScreen> createState() =>
      _RecommendedSwipeScreenState();
}

class _RecommendedSwipeScreenState extends ConsumerState<RecommendedSwipeScreen>
    with AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  final Set<String> _viewedStoryIds = {};
  int _currentPage = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;

    // Fetch next page if nearing the end (within 500 pixels)
    if (_pageController.position.pixels >=
        _pageController.position.maxScrollExtent - 500) {
      ref.read(recommendedStoriesProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  String _truncateContent(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final storiesAsync = ref.watch(recommendedStoriesProvider);
    final selectedTag = ref.watch(selectedTagProvider);
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        onRefresh: () async {
          // Refresh the recommended stories
          return await ref.refresh(recommendedStoriesProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: widget.scrollController,
          slivers: [
            if (storiesAsync.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                ),
              )
            else if (storiesAsync.hasError)
              SliverFillRemaining(
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
                            .read(recommendedStoriesProvider.notifier)
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
              )
            else if (storiesAsync.hasValue)
              ..._buildSuccessSlivers(
                context,
                ref,
                storiesAsync.value!,
                theme,
                selectedTag,
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSuccessSlivers(
    BuildContext context,
    WidgetRef ref,
    PaginatedResponse<StoryModel> paginatedResponse,
    ThemeData theme,
    String selectedTag,
  ) {
    // Filter stories based on selected tag
    final filteredStories = selectedTag == 'All'
        ? paginatedResponse.items
        : paginatedResponse.items
              .where((s) => s.hashtagsList.contains(selectedTag))
              .toList();

    return [
      if (filteredStories.isEmpty && !paginatedResponse.isEnd)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            ),
          ),
        )
      else if (filteredStories.isEmpty && paginatedResponse.isEnd)
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildCaughtUpCard(theme),
        )
      else
        SliverFillRemaining(
          hasScrollBody: true,
          child: Builder(
            builder: (context) {
              final itemCount = paginatedResponse.isEnd
                  ? filteredStories.length + 1
                  : filteredStories.length;

              return PageView.builder(
                key: const PageStorageKey('recommended_swipe_page_view'),
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const PageScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: itemCount,
                onPageChanged: (index) {
                  if (index < filteredStories.length) {
                    final storyId = filteredStories[index].storyId;
                    final userId = ref.read(authProvider).value?.authUser?.uid;
                    if (userId != null) {
                      ref
                          .read(storyRepositoryProvider)
                          .markStoryAsViewed(storyId, userId);
                    }
                  }
                },
                itemBuilder: (context, index) {
                  if (index == filteredStories.length) {
                    return _buildCaughtUpCard(theme);
                  }

                  final story = filteredStories[index];

                  return SwipeStoryCard(
                    story: story,
                    content: _truncateContent(story.description, 200),
                    onTap: () {
                      context.push(AppRoutes.storyDetail(story.storyId));
                    },
                  );
                },
              );
            },
          ),
        ),
    ];
  }

  Widget _buildCaughtUpCard(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(height: 24),
            Text(
              "You're caught up!",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Take time for your own healing journey today.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFA1A1A6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
