import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_loader.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/journey_providers.dart';
import '../widgets/timeline_node.dart';
import '../widgets/gratitude_tree.dart';
import '../widgets/time_capsule_card.dart';
import '../providers/time_capsule_provider.dart';

import '../../../../core/widgets/shared_headers.dart';
import '../widgets/log_milestone_overlay.dart';
import '../widgets/create_journey_overlay.dart';
import 'journey_detail_screen.dart';
import 'all_checkins_screen.dart';

class MyPathScreen extends ConsumerWidget {
  const MyPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final floatingMilestonesAsync = ref.watch(myFloatingMilestonesProvider);
    final journeysAsync = ref.watch(myJourneysProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const CommonSliverAppBar(),

          // Gratitude Tree Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              child: Column(
                children: [
                  GratitudeTree(gratitudeScore: 100),
                  const SizedBox(height: 8),
                  Text(
                    'Your tree is blooming',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gratitude grows here.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Capsule Vault Entry Card
                  Consumer(
                    builder: (context, ref, child) {
                      final capsulesAsync = ref.watch(myTimeCapsulesProvider);
                      final capsules = capsulesAsync.value ?? [];
                      final hasCapsules = capsules.isNotEmpty;
                      final lockedCount = capsules
                          .where((c) => c.isLocked)
                          .length;

                      // Find if any capsule is ready to open to prioritize it on the dashboard
                      final readyCapsule = hasCapsules
                          ? capsules
                                .where((c) => !c.isLocked && !c.isOpened)
                                .firstOrNull
                          : null;

                      return TimeCapsuleCard(
                        activeCapsule: readyCapsule,
                        lockedCount: lockedCount,
                        onOpen: () {
                          context.push('/time-capsules-vault');
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // My Journeys (Folders) Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'My Journeys',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // My Journeys Horizontal List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 170, // Increased height for more breathing room
              child: journeysAsync.when(
                data: (journeys) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: journeys.length + 1, // +1 for "Start New"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Start New Journey Card
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: GestureDetector(
                            onTap: () => CreateJourneyOverlay.show(context),
                            child: Container(
                              width: 140, // Match visual weight
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Start New',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                          letterSpacing: 0.2,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final journey = journeys[index - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => JourneyDetailScreen(
                                  journeyId: journey.id,
                                  title: journey.title,
                                  categories: journey.categories,
                                  visibility: journey.visibility,
                                  isMine: true,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 150, // Wider for long titles
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.surface,
                                  theme.colorScheme.surfaceContainerHigh
                                      .withValues(alpha: 0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.folder_open_rounded,
                                        color: theme.colorScheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                      ),
                                      child: SizedBox(
                                        height: 32,
                                        width: 32,
                                        child: PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_horiz_rounded,
                                            size: 20,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              CreateJourneyOverlay.show(
                                                context,
                                                journey: journey,
                                              );
                                            } else if (value == 'delete') {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Delete Journey',
                                                  ),
                                                  content: const Text(
                                                    'Are you sure you want to delete this journey and all its check-ins?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                try {
                                                  await ref
                                                      .read(
                                                        journeyRepositoryProvider,
                                                      )
                                                      .deleteJourney(
                                                        journey.id,
                                                      );
                                                  ref.invalidate(
                                                    myJourneysProvider,
                                                  );
                                                  ref.invalidate(
                                                    myFloatingMilestonesProvider,
                                                  );
                                                  ref.invalidate(
                                                    recommendedMilestonesProvider,
                                                  );
                                                  ref.invalidate(
                                                    followingMilestonesProvider,
                                                  );
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Failed to delete journey: $e',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      journey.title,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                            height: 1.3,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: AppLoader()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),

          // Floating Check-ins Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 36.0, 24.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Check-Ins',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllCheckinsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timeline Milestones (Floating only)
          Consumer(
            builder: (context, ref, child) {
              final floatingMilestonesAsync = ref.watch(
                myFloatingMilestonesProvider,
              );
              return floatingMilestonesAsync.when(
                data: (allMilestones) {
                  final milestones = allMilestones.take(5).toList();
                  if (milestones.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            'No check-ins yet. Tap + to log your mood.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // Backend already returns sorted newest first
                  final sortedMilestones = milestones;

                  return SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 8,
                      top: 16,
                      bottom: 100,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final milestone = sortedMilestones[index];
                        return TimelineNode(
                          milestone: milestone,
                          isReversed: true,
                        );
                      }, childCount: sortedMilestones.length),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: AppLoader(),
                    ),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err')),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          LogMilestoneOverlay.show(context);
        },
        elevation: 8,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Check In',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
