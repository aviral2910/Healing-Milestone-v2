import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/journey_providers.dart';
import '../widgets/together_feed_card.dart';
import '../widgets/walking_with_carousel.dart';
import '../../../../core/widgets/shared_headers.dart';

class TogetherFeedScreen extends ConsumerStatefulWidget {
  const TogetherFeedScreen({super.key});

  @override
  ConsumerState<TogetherFeedScreen> createState() => _TogetherFeedScreenState();
}

class _TogetherFeedScreenState extends ConsumerState<TogetherFeedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final feedAsync = ref.watch(togetherFeedProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated Mesh Gradient Background
          // AnimatedBuilder(
          //   animation: _bgController,
          //   builder: (context, child) {
          //     return Stack(
          //       children: [
          //         Positioned(
          //           top: -100 + (50 * _bgController.value),
          //           left: -100 - (50 * _bgController.value),
          //           child: Container(
          //             width: 400,
          //             height: 400,
          //             decoration: BoxDecoration(
          //               shape: BoxShape.circle,
          //               color: theme.colorScheme.primary.withValues(alpha: 0.15),
          //             ),
          //           ),
          //         ),
          //         Positioned(
          //           bottom: -50 - (50 * _bgController.value),
          //           right: -100 + (50 * _bgController.value),
          //           child: Container(
          //             width: 300,
          //             height: 300,
          //             decoration: BoxDecoration(
          //               shape: BoxShape.circle,
          //               color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
          //             ),
          //           ),
          //         ),
          //       ],
          //     );
          //   },
          // ),

          // Blur Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),

          RefreshIndicator(
            edgeOffset: 110,
            onRefresh: () async {
              ref.invalidate(followingJourneysProvider);
              await ref.refresh(togetherFeedProvider.future);
            },
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                const CommonSliverAppBar(),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Together Feed',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.volunteer_activism_rounded,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Support and be supported. Hold any card to send a spark to someone.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Horizontal Carousel of Walking With / Followed Journeys
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: WalkingWithCarousel(),
                  ),
                ),

                feedAsync.when(
                  data: (feed) {
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
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
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
                        child: CircularProgressIndicator(),
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
        ],
      ),
    );
  }
}
