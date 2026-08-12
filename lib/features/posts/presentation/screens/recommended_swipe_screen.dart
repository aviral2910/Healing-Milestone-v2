import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/theme/app_theme.dart';
import 'package:healing_milestones/core/widgets/shared_headers.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/shared/widgets/swipe_story_card.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../main.dart';

class RecommendedSwipeScreen extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final bool isActiveTab;
  final VoidCallback onSearchTapped;

  const RecommendedSwipeScreen({
    Key? key,
    required this.scrollController,
    required this.isActiveTab,
    required this.onSearchTapped,
  }) : super(key: key);

  @override
  ConsumerState<RecommendedSwipeScreen> createState() => _RecommendedSwipeScreenState();
}

class _RecommendedSwipeScreenState extends ConsumerState<RecommendedSwipeScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
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
          physics: const NeverScrollableScrollPhysics(),
          controller: widget.scrollController,
          slivers: [
            if (storiesAsync.isLoading)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
              )
            else if (storiesAsync.hasError)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Theme.of(context).dividerColor),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load recommendations',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFA1A1A6),
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
    List<StoryModel?> allStories,
    ThemeData theme,
    String selectedTag,
  ) {
    // Filter stories based on selected tag
    final filteredStories = selectedTag == 'All'
        ? allStories.where((s) => s != null).cast<StoryModel>().toList()
        : allStories.where((s) => s != null && s.hashtagsList.contains(selectedTag)).cast<StoryModel>().toList();

    return [
      if (filteredStories.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No recommendations found for #$selectedTag',
                style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFFA1A1A6)),
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
                key: const PageStorageKey('recommended_swipe_page_view'),
                controller: _pageController, // We will update the PageController in initState to viewportFraction: 1.0
                scrollDirection: Axis.vertical,
                physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
                itemCount: filteredStories.length,
                itemBuilder: (context, index) {
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
}
