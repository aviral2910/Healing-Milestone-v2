import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/journey_providers.dart';
import '../widgets/together_feed_card.dart';
import '../widgets/walking_with_carousel.dart';
import '../../../../core/widgets/shared_headers.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class TogetherFeedScreen extends ConsumerStatefulWidget {
  const TogetherFeedScreen({super.key});

  @override
  ConsumerState<TogetherFeedScreen> createState() => _TogetherFeedScreenState();
}

class _TogetherFeedScreenState extends ConsumerState<TogetherFeedScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final feedAsync = ref.watch(togetherFeedProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        edgeOffset: 110,
        onRefresh: () async {
          ref.invalidate(followingJourneysProvider);
          await ref.refresh(togetherFeedProvider.future);
        },
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              ref.read(togetherFeedProvider.notifier).fetchNextPage();
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              const CommonSliverAppBar(),

              // Horizontal Carousel of Walking With / Followed Journeys
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.0, top: 16),
                  child: WalkingWithCarousel(),
                ),
              ),

              feedAsync.when(
                data: (state) {
                  final feed = state.items;
                  if (feed.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 64,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No community posts yet.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 100,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final milestone = feed[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TogetherFeedCard(
                            milestone: milestone,
                            index: index,
                          ),
                        );
                      }, childCount: feed.length),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: const AppLoader(),
                    ),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
