import 'package:flutter/material.dart';
import 'dart:ui';
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

import '../../../medical_vault/presentation/providers/medical_vault_providers.dart';
import '../../../medical_vault/presentation/screens/mix_view_builder_screen.dart';
import '../../../medical_vault/presentation/screens/mix_view_share_screen.dart';
import 'package:intl/intl.dart';

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
                  const SizedBox(height: 12),
                  // Medical Vault Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Stack(
                      children: [
                        // Subtle glow behind the card
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  blurRadius: 24,
                                  spreadRadius: -4,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Main Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Material(
                              color: theme.colorScheme.surface.withValues(alpha: 0.7),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                                side: BorderSide(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(28),
                                onTap: () {
                                  context.push('/medical-vault');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // TOP ROW: Badge and Icon
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "MEDICAL VAULT",
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Icon
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.medical_information_rounded,
                                              color: theme.colorScheme.primary,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // BOTTOM: Info Area
                                      Text(
                                        "Store, organize, and securely share your clinical reports and tests.",
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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

          // Active Doctor Shares
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, _) {
                final viewsAsync = ref.watch(mixViewsProvider);
                
                return viewsAsync.when(
                  data: (views) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Health Snapshots',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 170, // Match My Journeys height
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: views.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // Start New Health Snapshot Card
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.push('/health-snapshot/create');
                                    },
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
                                            'Create Snapshot',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.colorScheme.primary,
                                                  letterSpacing: 0.2,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final view = views[index - 1];
                              final isExpiringSoon = view.expiresAt.difference(DateTime.now()).inHours < 24;
                              // Health Snapshot Card (Match My Journeys existing card)
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MixViewShareScreen(viewId: view.id),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 150, // Match My Journeys width
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.surface,
                                          theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: theme.dividerColor.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.health_and_safety_rounded,
                                                color: theme.colorScheme.primary,
                                                size: 24,
                                              ),
                                            ),
                                            Icon(
                                              Icons.qr_code_rounded,
                                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          view.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.timer_outlined, 
                                              size: 14, 
                                              color: isExpiringSoon ? Colors.orange : theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isExpiringSoon ? 'Expiring soon' : DateFormat('MMM d').format(view.expiresAt),
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: isExpiringSoon ? Colors.orange : theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
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
