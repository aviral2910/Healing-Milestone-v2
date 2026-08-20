import 'package:healing_milestones/core/models/offset_paginated_state.dart';
import '../../data/models/journey_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
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

class _TogetherFeedScreenState extends ConsumerState<TogetherFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CommonSliverAppBar(
              onSearchTapped: () => context.push(AppRoutes.search),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  dividerColor: theme.dividerColor,
                  tabs: const [
                    Tab(text: 'For You'),
                    Tab(text: 'Following'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _TogetherFeedTab(
              milestoneProvider: recommendedMilestonesProvider,
              journeyProvider: recommendedJourneysProvider,
              carouselTitle: 'Recommended',
            ),
            _TogetherFeedTab(
              milestoneProvider: followingMilestonesProvider,
              journeyProvider: followingJourneysProvider,
              carouselTitle: 'Following',
            ),
          ],
        ),
      ),
    );
  }
}

class _TogetherFeedTab extends ConsumerWidget {
  final dynamic milestoneProvider;
  final dynamic journeyProvider;
  final String carouselTitle;

  const _TogetherFeedTab({
    required this.milestoneProvider,
    required this.journeyProvider,
    required this.carouselTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final AsyncValue<OffsetPaginatedState<JourneyMilestoneModel>> feedAsync = ref.watch(milestoneProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(journeyProvider);
        await ref.refresh(milestoneProvider.future);
      },
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 200) {
            ref.read(milestoneProvider.notifier).fetchNextPage();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 16),
                child: WalkingWithCarousel(
                  provider: journeyProvider,
                  title: carouselTitle,
                ),
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
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No community posts yet.',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == feed.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(child: AppLoader.small()),
                        );
                      }
                      
                      final milestone = feed[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TogetherFeedCard(milestone: milestone),
                      );
                    }, childCount: feed.length + (state.isEnd ? 0 : 1)),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: AppLoader()),
              ),
              error: (e, st) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Failed to load feed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
